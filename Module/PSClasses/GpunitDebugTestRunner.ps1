New-PSClass 'GpUnit.GpUnitDebugTestRunner' -Inherit 'GpUnit.TestRunnerBase' {

    method RunTest {
        param(
            $fixtureObject,
            $testCase
        )

        $private:testName = $testCase.DisplayName

        $ErrorActionPreference = "Stop"

        write-host (Get-Member -inputobject $fixtureObject | Fl * -force | out-string).Trim()
        write-host "running $testname"

        try {
            $testCase.Result = [GpUnit.TestResult]::InProgress
            [Void]$fixtureObject.$testName.Invoke()
            $testCase.Result = [GpUnit.TestResult]::Success
        } catch {
            $e = $_
            Write-Debug 'test failed'
            $testCase.Result = [GpUnit.TestResult]::Failed
            $testCase.Errors += $e
        }
    }

    method -override RunSessionTests {
        param (
            [object]$testSession
        )

        $initSuccessful = $false
        $initError = $null
        $creationTried = $false
        $creationSuccessful = $false
        $creationError = $null
        $fixtureClass = $null

        # test cases have a many-to-one relationship with testDefinitions,
        # which have a many-to-one relationship with testFixtures
        # a fixtureClass should only be created once foreach testFixture encountered
        # the fixtureInstance will be recreated from the fixtureClass for each testCase
        # this grouping represents these relationships, and allows for some control over what happens at each stage

        $testCaseFixtureGroups = $testSession.Tests | Group-Object -Property {$_.TestDefinition.TestFixture.Name}

        foreach($testCaseGroupByFixture in $testCaseFixtureGroups) {
            $testCases = $testCaseGroupByFixture.Group
            $testCaseDefinitionGroups = $testCases | Group-Object  -Property {$_.TestDefinition.FullName}

            # wrap the whole thing in a try so that we can cleanup references to the fixture class
            # and avoid a memory leak
            try {
                $fixtureClass = $null
                $fixtureClassInitializationSuccessful = $false

                # haxin
                # because of the relationships described above, we know that the testFixture
                # for any testcase at this stage in grouping are all the same testFixture
                $testFixture = $testCases[0].TestDefinition.TestFixture

                try {
                    # create the fixture class from the testFixture
                    # the fixtureInstance will be created from the fixtureClass each time
                    $fixtureClass = New-PSClassFromTestFixture $testFixture
                    $fixtureClassInitializationSuccessful = $true
                } catch {
                    # if we are unable to create the testClass, mark all tests as failed
                    # $initSuccessful will not be marked true, and as such, no test cases will run
                    $initError = $_
                    foreach($testDefinition in $testFixture.TestDefinitions) {
                        foreach($testCase in $testDefinition.TestCases) {
                            Write-Debug 'init failed on test class'
                            $testCase.Result = [GpUnit.TestResult]::Failed
                            $testFixture.TestRunSummary.Failed++
                            $testCase.Errors += $initError
                        }
                    }
                }

                # the rest is only possible if the fixtureClass was able to be created
                if($fixtureClassInitializationSuccessful) {
                    $this._RunFixtureTestCases($fixtureClass, $testCases);
                }
            } finally {
                if($fixtureClass -ne $null) {
                    $fixtureClass.Dispose()
                }
            }

            $testSession._Aggregate($testFixture.TestRunSummary)
        }
    }

    method _RunFixtureTestCases {
        param (
            $FixtureClass,
            $TestCases
        )

        $creationTried = $false
        $creationSuccessful = $false

        foreach($testCase in $TestCases) {
            $testDefinition = $testCase.TestDefinition
            $testFixture = $testDefinition.TestFixture

            # skip tests marked as such
            if($testDefinition.Skip) {
                $testFixture.TestRunSummary.Skipped += $testDefinition.TestCases.Count
                continue;
            }

            # only perform the further tests if we were able to successfully create the test object
            # from the class definition
            # do not run any further tests, just mark them as failed and record the error
            if($creationTried -and -not $creationSuccessful) {
                Write-Debug 'creation failed on prior test'
                $testCase.Result = [GpUnit.TestResult]::Failed
                $testFixture.TestRunSummary.Failed++
                $testCase.Errors += $creationError
                continue;
            }

            # start a stopwatch so we can track the duration the test takes to run
            $testTimer = [Diagnostics.StopWatch]::StartNew()

            try {
                # attempt to create the fixture (setup is constructor)
                # and dispose is teardown
                $creationTried = $true
                Invoke-Using ($fixtureObject = $FixtureClass.New()) {
                    # this is required because Invoke-Using uses scriptblocks
                    # and value-types are created in the child scope instead of set in the parent scope
                    (Get-Variable creationSuccessful).Value = $true

                    # run the test, performing any necessary test logic here
                    $this.RunTest($fixtureObject, $testCase)
                }
            } catch {
                $e = $_
                # a failure here indicates that the setup or teardown failed
                # we need to mark the test as failure, record the error
                # if creationSuccess is not be marked true, we will be skipping subsequent tests
                # we need to keep the error that occurred though and append it to subsequent testCases
                Write-Debug 'setup or teardown failed'
                $testCase.Result = [GpUnit.TestResult]::Failed
                $testFixture.TestRunSummary.Failed++
                $errorRecord = $e
                $testCase.Errors += $errorRecord
                if(-not $creationSuccessful) {
                    $creationError = $errorRecord
                }
            } finally {
                $testTimer.Stop()
            }

            $testCase.Time = $testTimer.ElapsedMilliseconds
            $testFixture.TestRunSummary.Time += $testCase.Time
            $testFixture.TestRunSummary.Failed += [int]($testCase.Result -eq [GpUnit.TestResult]::Failed)
        }
    }
}
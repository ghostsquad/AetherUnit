New-PSClass 'PondUnit.PondUnitDebugTestRunner' -Inherit 'PondUnit.TestRunnerBase' {

    method RunTest {
        param(
            $testFixture,
            $testCase
        )

        $private:testFixture = $testFixture
        $private:testCase = $testCase

        $TestName = $testCase.DisplayName

        try {
            $testCase.Result = [PondUnit.TestResult]::InProgress
            [Void]$testFixture.$TestName.Invoke()
            $testCase.Result = [PondUnit.TestResult]::Success
        } catch {
            write-host 'test failed' -foregroundcolor yellow
            $testCase.Result = [PondUnit.TestResult]::Failed
            $testCase.Errors += $_
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

        foreach($testGroup in $testSession.SelectedTestDictionary.Values) {
            # wrap the whole thing in a try so that we can cleanup references to the fixture class
            try {
                $testCases = $testGroup.Values

                try {
                    # since all test cases share the same fixtureMeta object, we can just pick the first one
                    # and create the test fixture (psclass) using the FixtureMeta property of the testCase
                    $firstTestCase = [System.Linq.Enumerable]::First($testCases)
                    $fixtureClass = CreateFixtureClassFromMeta $firstTestCase.FixtureMeta
                    $initSuccessful = $true
                } catch {
                    # if we are unable to create the testClass, mark all tests as failed
                    # $initSuccessful will not be marked true, and as such, no test cases will run
                    $initError = $_
                    foreach($testCase in $testCases) {
                        write-host 'init failed on test class' -foregroundcolor yellow
                        $testCase.Result = [PondUnit.TestResult]::Failed
                        $testCase.Errors += $initError
                    }
                }

                # the rest is only possible if the fixtureClass was able to be created
                if($initSuccessful) {
                    # run each test in the fixture, recreating the fixtureObject each time before
                    foreach($testCase in $testCases) {
                        # only perform the further tests if we were able to successfully create the test object
                        # from the class definition
                        # do not run any further tests, just mark them as failed and record the error
                        if($creationTried -and -not $creationSuccessful) {
                            write-host 'creation failed on prior test' -foregroundcolor yellow
                            $testCase.Result = [PondUnit.TestResult]::Failed
                            $testCase.Errors += $creationError
                            continue;
                        }

                        try {
                            # attempt to create the fixture (setup is constructor)
                            # and dispose is teardown
                            $creationTried = $true
                            Invoke-Using ($fixtureObject = $fixtureClass.New()) {
                                (Get-Variable creationSuccessful).Value = $true
                                # run the test, performing any necessary test logic here
                                $this.RunTest($fixtureObject, $testCase)
                            }
                        } catch {
                            # a failure here indicates that the setup or teardown failed
                            # we need to mark the test as failure, record the error
                            # if creationSuccess is not be marked true, we will be skipping subsequent tests
                            # we need to keep the error that occurred though and append it to subsequent testCases
                            write-host 'setup or teardown failed' -foregroundcolor yellow
                            $testCase.Result = [PondUnit.TestResult]::Failed
                            $errorRecord = $_
                            $testCase.Errors += $errorRecord
                            if(-not $creationSuccessful) {
                                $creationError = $errorRecord
                            }
                        }
                    }
                }
            } finally {
                # Cleanup the references to the fixture psClass
                if((test-path variable:fixtureClass) -and $fixtureClass -ne $null) {
                    $Global:__PSClassDefinitions__.Remove($fixtureClass.__ClassName)
                }
            }
        }
    }
}
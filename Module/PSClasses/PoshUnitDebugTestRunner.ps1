New-PSClass 'PoshUnit.PoshUnitDebugTestRunner' -Inherit 'PoshUnit.TestRunnerBase' {
    method InitializeFixtureClass {
        param (
            [ref]$FixtureClass,
            [object]$testCase,
            [ref][System.Management.Automation.ErrorRecord]$ErrorRecord
        )

        $initSuccessful = $false
        $ErrorRecord.Value = $null
        $FixtureClass.Value = $null

        try {
            $FixtureClass.Value = CreateFixtureClassFromMeta $testCase.Fixture
            $initSuccessful = $true
        } catch {
            $ErrorRecord.Value = $_
        }

        return $initSuccessful
    }

    method RunFixtureSetup {
        param (
            $FixtureClass,
            [ref][System.Management.Automation.ErrorRecord]$ErrorRecord
        )

        $setupSuccessful = $false
        $ErrorRecord.Value = $null

        try {
            $FixtureClass.Setup()
            $setupSuccessful = $true
        } catch {
            $ErrorRecord.Value = $_
        }

        return $setupSuccessful
    }

    method RunFixtureTeardown{
        param (
            $FixtureClass,
            [ref][System.Management.Automation.ErrorRecord]$ErrorRecord
        )

        $teardownSuccessful = $false
        $ErrorRecord.Value = $null

        try {
            $FixtureClass.Teardown()
            $teardownSuccessful = $true
        } catch {
            $ErrorRecord.Value = $_
        }

        return $teardownSuccessful
    }

    method RunTest {
        param(
            [ref]$testCase
        )

        $FixtureClass = $null

        [System.Management.Automation.ErrorRecord]$ErrorRecord = $null
        $initSuccessful = $this.InitializeFixtureClass([ref]$FixtureClass, $testCase.Value, [ref]$ErrorRecord)

        if(-not $initSuccessful) {
            $testCase.Value.Result = [PoshUnit.TestResult]::Failed
            $testCase.Value.ErrorRecord = $ErrorRecord
        } else {
            $setupSuccessful = $this.RunFixtureSetup($FixtureClass, [ref]$ErrorRecord)
            if(-not $setupSuccessful) {
                $testCase.Value.Result = [PoshUnit.TestResult]::Failed
                $testCase.Value.ErrorRecord = $ErrorRecord
            } else {
                $TestName = $testCase.DisplayName

                try {
                    $testCase.Value.Result = [PoshUnit.TestResult]::InProgress
                    [Void]$FixtureClass.$TestName.Invoke()
                    $testCase.Value.Result = [PoshUnit.TestResult]::Success
                } catch {
                    $testCase.Value.Result = [PoshUnit.TestResult]::Failed
                    $testCase.Value.ErrorRecord = $_
                }

                $teardownSuccessful = $this.RunFixtureTeardown($FixtureClass, [ref]$ErrorRecord)
                if(-not $teardownSuccessful) {
                    $testCase.Value.Result = [PoshUnit.TestResult]::Failed
                    $testCase.Value.ErrorRecord = $ErrorRecord
                }
            }
        }
    }

    method -override RunTests {
        param (
            [object[]]$testCases
        )

        foreach($testCase in $testCases) {
            $testCases += ($this.RunTest([ref]$testCase))
        }

        return $testCases
    }
}
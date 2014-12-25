New-PSClass 'PoshUnit.TestRunnerBase' {
    method RunTests {
        param (
            [object[]]$testCases
        )

        throw (New-Object System.NotImplementedException)
    }
}
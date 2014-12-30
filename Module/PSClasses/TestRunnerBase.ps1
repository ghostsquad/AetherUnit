New-PSClass 'PoshUnit.TestRunnerBase' {
    method RunSessionTests {
        param (
            [object]$testSession
        )

        throw (New-Object System.NotImplementedException)
    }
}
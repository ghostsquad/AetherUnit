New-PSClass 'PoshUnit.TestRunnerBase' {
    note _fixtureMeta
    note _testNamesToRun (New-Object System.Collections.Generic.Queue[object])

    constructor {
        param (
            $FixtureMeta
        )

        Guard-ArgumentIsPSClass 'Fixture' $Fixture 'PoshUnit.FixtureMeta'
        $this._fixtureMeta = $FixtureMeta
    }

    method RunTests {
        throw (New-Object System.NotImplementedException)
    }
}
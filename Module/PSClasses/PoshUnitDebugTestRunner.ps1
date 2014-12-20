New-PSClass 'PoshUnit.PoshUnitDebugTestRunner' -Inherit 'PoshUnit.TestRunnerBase' {
    method -override RunTests {
        foreach($private:test in $this._testNamesToRun) {
            try {
                $private:fixtureClass = CreateFixtureClassFromMeta $this._fixtureMeta
            } catch {
                #exception occurred during fixture class creation, this is most likely because of an internal bug
                throw (New-Object PoshUnit.FixtureInitializationException("Error creating fixture object from class!", $_))
            }

            try {
                using ($private:fixtureObject = $fixtureClass.New()) {
                    [Void]$fixtureObject.$test.Invoke()
                }
                $private:fixtureObject = $fixtureClass.New()
            } catch {

            }
        }
    }
}
Fixture "FactDiscoveryTests" {
    Fact 'TestCount' {
        $fixtures = Get-TestFixtures
        $sum = ($fixtures | Measure-Object Tests -Sum).Sum

        Assert-Equal $sum 1
    }
}


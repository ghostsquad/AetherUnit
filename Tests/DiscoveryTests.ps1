Fixture "DiscoveryTests" {
    Fact 'TestCount' {
        $fixtures = Get-TestFixtures
        $sum = ($fixtures | ?{$.Name -eq 'DiscoveryTests'} | Measure-Object Tests -Sum).Sum

        Assert-Equal $sum 4
    }

    Fact 'FactCount' {
        $fixtures = Get-TestFixtures
        $sum = ($fixtures | ?{$.Name -eq 'DiscoveryTests'} | %{$_.Tests} | ?{-not $_.Theory} | Measure-Object Tests -Sum).Sum

        Assert-Equal $sum 3
    }

    Fact 'TheoryCount' {
        $fixtures = Get-TestFixtures
        $sum = ($fixtures | ?{$.Name -eq 'DiscoveryTests'} | %{$_.Tests} | ?{ $_.Theory} | Measure-Object Tests -Sum).Sum

        Assert-Equal $sum 1
    }

    Theory 'i am a theory' {}
}

New-PSClass 'GpUnit.FixtureDiscovererBase' {
    method 'GetFixtures' {
        param (
            [string]$PathRoot
        )

        throw (New-Object System.NotImplementedException)
    }
}
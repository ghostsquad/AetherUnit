function Get-Tests {
    [cmdletbinding(DefaultParameterSetName='Path')]
    param (
        [Parameter(Position=0, ParameterSetName='Path')]
        [string]$Path = $PWD,
        [Parameter(Position=1, ParameterSetName='Path')]
        [string[]]$Patterns,
        [Parameter(Position=2, ParameterSetName='Path')]
        [string[]]$Traits,
        [Parameter(Position=2, ParameterSetName='Path')]
        [scriptblock]$Predicate = {$true},
        [Parameter(Position=0, ParameterSetName='Names')]
        [string[]]$Names
    )

    $discoverer = (Get-PSClass 'GpUnit.GpUnitFixtureDiscoverer').Default

    $fixtures = $discoverer.GetFixtures($Path)
    $tests = New-Object System.Collections.ArrayList
    foreach($fixture in $fixtures) {
        foreach($testDefinition in $fixture.TestDefinitions) {
            if($Predicate.Invoke($testDefinition)) {
                foreach($testCase in $testDefinition.TestCases) {
                    [Void]$tests.Add($testCase)
                }
            }
        }
    }

    if($tests.Count -le 1) {
        return ,$tests
    }

    return $tests
}
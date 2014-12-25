function Get-Tests {
    [cmdletbinding(DefaultParameterSetName='Path')]
    param (
        [Parameter(Position=0, ParameterSetName='Path')]
        [string]$Path = $PWD,
        [Parameter(Position=1, ParameterSetName='Path')]
        [string[]]$Patterns,
        [Parameter(Position=1, ParameterSetName='Path')]
        [string[]]$Traits,
        [Parameter(Position=0, ParameterSetName='Names')]
        [string[]]$Names
    )

    $fixtures = Get-TestFixtures -Path $Path
    $tests = New-Object System.Collections.ArrayList
    foreach($fixture in $fixtures) {
        [Void]$tests.AddRange($fixture.Tests)
    }

    return ,$tests
}
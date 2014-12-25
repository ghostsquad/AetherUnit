function Start-TestSession {
    [cmdletbinding(DefaultParameterSetName='NewSessionSpecific')]
    param (
        [Parameter(Position=0, ParameterSetName='NewSessionSpecific')]
        [string[]]$TestNames,
        [Parameter(Position=0, ParameterSetName='ExistingSession')]
        [int]$SessionId,
        [Parameter(Position=0, ParameterSetName='NewSessionPath')]
        [string]$Path = $PWD,
        [switch]$Debuggable
    )

    $testSession = $null

    if($PSCmdlet.ParameterSetName -eq 'NewSessionSpecific') {
        Guard-ArgumentNotNullOrEmpty 'TestNames' $TestNames
        $testFixtures = Get-TestFixtures $TestNames
    }

    if($PSCmdlet.ParameterSetName -eq 'ExistingSession') {
        Guard-ArgumentValid 'SessionId' 'SessionId must be greater than or equal to 1' ($SessionId -gt 0)
        $testSession = Get-Session -Id $SessionId
        $tests = $testSession.Tests
    }

    if($PSCmdlet.ParameterSetName -eq 'NewSessionPath') {
        Guard-ArgumentNotNull 'Path' $Path
        Guard-ArgumentValid 'Path' 'The path provided does not exist' (Test-Path $Path)
        $tests = Get-Tests -Path $Path
    }

    $poshUnitState = [PoshUnitState]::Default
    $testNamesHashSet = New-Object System.Collections.Generic.HashSet[string]($TestNames)

    try {
        if($testSession -eq $null) {
            $testSession = [PSClassContainer]::ClassDefinitions['PoshUnit.TestSession'].New($poshUnitState.Sessions.Count + 1)
        }

        $poshUnitState.CurrentSession = $testSession

        if($Debuggable) {
            $runner = [PSClassContainer]::ClassDefinitions['PoshUnit.PoshUnitDebugTestRunner'].New()
        } else {
            $runner = [PSClassContainer]::ClassDefinitions['PoshUnit.PoshUnitParallelTestRunner'].New()
        }

        $fixtures = Get-TestFixtures -Path $PWD

        foreach($fixture in $fixtures) {
            foreach($test in $fixture.tests) {
                if($testNamesHashSet.Contains($test.DisplayName)) {
                    [Void]$testSession.Tests.Add($test)
                }
            }
        }

        return $runner.RunTests($testSession.Tests)
    } finally {
        $poshUnitState.CurrentSession = $null
    }
}
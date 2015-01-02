function Start-TestSession {
    [cmdletbinding(DefaultParameterSetName='NewSession')]
    param (
        [Parameter(Position=0, ParameterSetName='NewSession')]
        [Parameter(Position=0, ParameterSetName='NewSessionRunList')]
        [string]$Path = ($PWD.Path),
        [Parameter(Position=1, ParameterSetName='NewSession')]
        [string]$NameFilter,
        [Parameter(Position=2, ParameterSetName='NewSession')]
        [string]$IncludeTrait,
        [Parameter(Position=2, ParameterSetName='NewSession')]
        [string]$ExcludeTrait,
        [Parameter(Position=2, ParameterSetName='NewSessionRunList', ValueFromPipeline)]
        [string[]]$RunList,
        [Parameter(Position=0, ParameterSetName='ExistingSession', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Parameter(Position=0, ParameterSetName='ExistingSession')]
        [int]$SessionId,
        [switch]$Debuggable
    )

    $testSession = $null

    if($PSCmdlet.ParameterSetName -eq 'NewSession') {
        Guard-ArgumentNotNullOrEmpty 'TestNames' $TestNames
        $testFixtures = Get-TestFixtures $TestNames
    }

    if($PSCmdlet.ParameterSetName -eq 'ExistingSession') {
        Guard-ArgumentValid 'SessionId' 'SessionId must be greater than or equal to 1' ($SessionId -gt 0)
        $testSession = Get-Session -Id $SessionId
        $tests = $testSession.Tests
    }

    if($PSCmdlet.ParameterSetName -eq 'NewSession') {
        Guard-ArgumentNotNull 'Path' $Path
        Guard-ArgumentValid 'Path' 'The path provided does not exist' (Test-Path $Path)
        $tests = Get-Tests -Path $Path
    }

    $GpUnitState = [GpUnitState]::Default
    if($PSCmdlet.ParameterSetName -eq 'NewSession') {
        $testNamesHashSet = New-Object System.Collections.Generic.HashSet[string]($TestNames)
        $testFilterPredicate = {
            param($testDisplayName)
            $testNamesHashSet.Contains($testDisplayName)
        }
    } else {
        $testFilterPredicate = { return $true }
    }

    try {
        if($testSession -eq $null) {
            $testSession = (Get-PSClass 'GpUnit.TestSession').New($GpUnitState.Sessions.Count + 1)
        }

        [Void]$GpUnitState.Sessions.Add($testSession)
        $GpUnitState.CurrentSession = $testSession

        if($Debuggable) {
            $runner = (Get-PSClass 'GpUnit.GpUnitDebugTestRunner').New()
        } else {
            $runner = (Get-PSClass 'GpUnit.GpUnitParallelTestRunner').New()
        }

        $fixtures = Get-TestFixtures -Path $Path

        $selectedTestDictionary = New-GenericObject System.Collections.Generic.Dictionary string,object

        # loop through all found fixtures
        foreach($fixture in $fixtures) {

            # loop through all tests in fixture
            foreach($test in $fixture.tests) {

                # check if test matches the filter predicate only if we need to filter
                if(-not $PSCmdlet.ParameterSetName -eq 'NewSessionSpecific' -or $testFilterPredicate.Invoke($test.DisplayName)) {

                    # add fixture to selectedTestDictionary if is not already in there
                    if(-not $selectedTestDictionary.ContainsKey($fixture.Name)) {
                        [Void]$selectedTestDictionary.Add($fixture.Name, (New-GenericObject System.Collections.Generic.Dictionary string,object))
                    }

                    # add the test to the fixture dictionary
                    [Void]$selectedTestDictionary[$fixture.Name].Add($test.DisplayName, $test)
                }
            }
        }

        $testSession.SelectedTestDictionary = $selectedTestDictionary

        $runner.RunSessionTests($testSession)

        return $testSession
    } finally {
        $GpUnitState.CurrentSession = $null
    }
}
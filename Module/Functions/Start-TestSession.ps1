function Start-TestSession {
    [cmdletbinding(DefaultParameterSetName='NewSession')]
    param (
        [Parameter(Position=0, ParameterSetName='NewSession')]
        [Parameter(Position=0, ParameterSetName='NewSessionRunList')]
        [string]$Path = ($PWD.Path),
        [Parameter(Position=1, ParameterSetName='NewSession')]
        [string]$Filter,
        [Parameter(Position=2, ParameterSetName='NewSession')]
        [string]$IncludeTrait,
        [Parameter(Position=2, ParameterSetName='NewSession')]
        [string]$ExcludeTrait,
        [Parameter(Position=2, ParameterSetName='NewSessionRunList', ValueFromPipeline)]
        [string[]]$RunList,
        [Parameter(Position=0, ParameterSetName='ExistingSession', ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [int]$SessionId,
        [switch]$Debuggable
    )

    $testSession = $null

    $tests = New-Object System.Collections.ArrayList

    $gpUnitState = [GpUnitState]::Default

    if($PSCmdlet.ParameterSetName -eq 'ExistingSession') {
        Guard-ArgumentValid 'SessionId' 'SessionId must be greater than or equal to 1' ($SessionId -gt 0)
        $testSession = Get-Session -Id $SessionId
    }

    if($PSCmdlet.ParameterSetName -eq 'NewSession') {
        Guard-ArgumentNotNull 'Path' $Path
        Guard-ArgumentValid 'Path' 'The path provided does not exist' (Test-Path $Path)
    }

    try {
        if($testSession -eq $null) {
            $testSession = (Get-PSClass 'GpUnit.TestSession').New($gpUnitState.Sessions.Count + 1)
            $testSession.Tests = Get-Tests -Path $Path
        }

        if($PSCmdlet.ParameterSetName -eq 'NewSession') {
            [Void]$gpUnitState.Sessions.Add($testSession)
        }

        $gpUnitState.CurrentSession = $testSession

        if($Debuggable) {
            $runner = (Get-PSClass 'GpUnit.GpUnitDebugTestRunner').New()
        } else {
            $runner = (Get-PSClass 'GpUnit.GpUnitParallelTestRunner').New()
        }

        $runner.RunSessionTests($testSession)

        return $testSession
    } finally {
        $gpUnitState.CurrentSession = $null
    }
}
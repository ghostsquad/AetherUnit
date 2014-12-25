function Get-TestSession {
    [cmdletbinding(DefaultParameterSetName='Default')]
    param (
        [Parameter(Position=0, ParameterSetName='Default')]
        [int]$SessionId
    )
}
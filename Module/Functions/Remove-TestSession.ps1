function Remove-TestSession {
    [cmdletbinding(DefaultParameterSetName='Default')]
    param (
        [Parameter(Position=0, ParameterSetName='SessionObject')]
        [psobject]$InputObject,
        [Parameter(Position=0, ParameterSetName='Default')]
        [int]$SessionId
    )
}
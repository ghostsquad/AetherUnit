param (
    [string]$TestName = "*",
    [switch]$Debug,
    [switch]$CurrentContext = $false
)
$ErrorActionPreference = "Stop"
if($Debug){
    $DebugPreference = "Continue"
}

$here = (Split-Path -Parent $MyInvocation.MyCommand.Path)

if($currentContext) {
    Import-Module Pester
    Invoke-Pester -TestName $TestName -Path $here
} else {
    $cmd = 'Set-Location ''{0}''; Import-Module PondUnit; Invoke-Pester -TestName ''{1}'' -EnableExit;' -f $here, $TestName
    powershell.exe -noprofile -command $cmd
}
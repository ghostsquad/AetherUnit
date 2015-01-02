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

New-TestSession -Path ($here\Tests) -Debuggable:$currentContext
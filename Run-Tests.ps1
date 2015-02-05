param (
    [switch]$Debug,
    [switch]$CurrentContext = $false
)
$ErrorActionPreference = "Stop"
if($Debug){
    $DebugPreference = "Continue"
}

$here = (Split-Path -Parent $MyInvocation.MyCommand.Path)

robocopy d:\dev\GravityPS d:\dev\tempPSModulePath\GravityPS /e
robocopy d:\dev\GpClass d:\dev\tempPSModulePath\GpClass /e

if($currentContext) {
    write-host "running in current context"
    $env:PSModulePath += ';d:\dev\tempPSModulePath'
    Import-Module (Join-Path $here 'Module\GpUnit.psd1')
    $formatting = @('Total', @{Label='Passed'; Expression={$_.Total - $_.Failed}}, 'Failed', 'Skipped', @{Label='Time'; Expression={'{0}ms' -f $_.Time}})
    Start-TestSession -Path (Join-Path $here 'Tests') -Debuggable | ft $formatting -autosize
} else {
    $cmd = 'Set-Location ''{0}'';' -f $here
    $cmd += '$env:PSModulePath += '';d:\dev\tempPSModulePath'''
    $cmd += 'Import-Module d:\dev\GravityPS\GravityPS.psd1'
    $cmd += 'Import-Module d:\dev\GpClass\GpClass.psd1'
    $cmd += 'Import-Module .\Module\GpUnit.psd1;'
    $cmd += 'Start-TestSession -Path .\Tests -Debuggable '
    $cmd += '| ft Total, @{Label=''Passed''; Expression={$_.Total - $_.Failed}}, Failed, Skipped, @{Label=''Time''; Expression={''{0}ms'' -f $_.Time}} -autosize;'
    powershell.exe -noprofile -command $cmd
}

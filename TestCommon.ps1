$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest
$private:here = Split-Path $MyInvocation.MyCommand.Path -Parent
$private:modulePathRelative = (Join-Path (Split-Path $MyInvocation.MyCommand.Path -Parent) 'PondPSClass.psd1')
$private:modulePathAbsolute = [System.IO.Path]::GetFullPath($modulePathRelative);
if((Test-Path (Join-Path $here 'test.config.ps1'))) {
    . $here\test.config.ps1
}
Import-Module $private:modulePathAbsolute -Force -DisableNameChecking
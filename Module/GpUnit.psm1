$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Add-Type -Path $here\Gpunit.dll
write-host "$(Get-Date -Format u) import xunit"
Add-Type -Path $here\Dependencies\xunit.dll

write-host "$(Get-Date -Format u) import testresult"
. $here\TestResult.ps1
write-host "$(Get-Date -Format u) import failurereason"
. $here\FailureReason.ps1

$nonStandardFunctionsToSourceAndExport = @(
    'Fixture',
)
foreach($func in $nonStandardFunctionsToSourceAndExport) {
    write-host "$(Get-Date -Format u) import $func"
    . ('{0}\Functions\{1}.ps1' -f $here, $func)
}

$psClassesToSource = @(
    'TestCase',
    'TestFixture',
    'TestSession',
    'TestRunnerBase',
    'GpunitParallelTestRunner',
    'GpunitDebugTestRunner',
    'TestInvocationInfo'
)

foreach($psClassName in $psClassesToSource) {
    write-host "$(Get-Date -Format u) import $psClassName"
    if(-not (Get-PSClass "Gpunit.$psClassName")) {
        . ('{0}\PSClasses\{1}.ps1' -f $here, $psClassName)
    }
}

foreach($assert in (get-childitem $here\Asserts)) {
    write-host "$(Get-Date -Format u) import $assert"
    . $assert.FullName
}

write-host "$(Get-Date -Format u) add type accelerators"

Add-TypeAccelerator -Name StringConstantExpressionAst -Type ([System.Management.Automation.Language.StringConstantExpressionAst])
Add-TypeAccelerator -Name CommandParameterAst -Type ([System.Management.Automation.Language.CommandParameterAst])
Add-TypeAccelerator -Name CommandElementAst -Type ([System.Management.Automation.Language.CommandElementAst])
Add-TypeAccelerator -Name CommandAst -Type ([System.Management.Automation.Language.CommandAst])
Add-TypeAccelerator -Name ScriptBlockExpressionAst -Type ([System.Management.Automation.Language.ScriptBlockExpressionAst])
Add-TypeAccelerator -Name ScriptBlockAst -Type ([System.Management.Automation.Language.ScriptBlockAst])

Add-TypeAccelerator -Name GpunitException -Type ([Gpunit.GpunitException])
Add-TypeAccelerator -Name GpunitState -Type ([Gpunit.GpunitState])

write-host "$(Get-Date -Format u) import remaining functions"

. $here\Functions\Get-TestFixtures.ps1
. $here\Functions\Start-TestSession.ps1
. $here\Functions\Get-TestSession.ps1
. $here\Functions\Remove-TestSession.ps1
. $here\Functions\Get-Tests.ps1
. $here\Functions\New-PSClassFromTestFixture.ps1

Export-ModuleMember -Function *-*
Export-ModuleMember -Function $nonStandardFunctionsToSourceAndExport
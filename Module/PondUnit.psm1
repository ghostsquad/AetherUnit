$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$PondUnitModuleBuilder = New-DynamicModuleBuilder 'PondUnit'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Add-Type -Path $here\PondUnit.dll
Add-Type -Path $here\Dependencies\xunit.dll

. $here\TestResult.ps1
. $here\FailureReason.ps1

$nonStandardFunctionsToSourceAndExport = @(
    'Fact',
    'Fixture',
    'Setup',
    'Teardown',
    'Theory',
    'UseDataFixture',
    'CreatePSClassFromTestFixture'
)
foreach($func in $nonStandardFunctionsToSourceAndExport) {
    . ('{0}\Functions\{1}.ps1' -f $here, $func)
}

$psClassesToSource = @(
    'TestCase',
    'TestFixture',
    'TestSession',
    'TestRunnerBase',
    'PondUnitParallelTestRunner',
    'PondUnitDebugTestRunner'
)

foreach($psClassName in $psClassesToSource) {
    if(-not (Get-PSClass "PondUnit.$psClassName")) {
        . ('{0}\PSClasses\{1}.ps1' -f $here, $psClassName)
    }
}

foreach($assert in (get-childitem $here\Asserts)) {
    . $assert.FullName
}

Add-TypeAccelerator -Name StringConstantExpressionAst -Type ([System.Management.Automation.Language.StringConstantExpressionAst])
Add-TypeAccelerator -Name CommandParameterAst -Type ([System.Management.Automation.Language.CommandParameterAst])
Add-TypeAccelerator -Name CommandAst -Type ([System.Management.Automation.Language.CommandAst])
Add-TypeAccelerator -Name ScriptBlockExpressionAst -Type ([System.Management.Automation.Language.ScriptBlockExpressionAst])
Add-TypeAccelerator -Name ScriptBlockAst -Type ([System.Management.Automation.Language.ScriptBlockAst])

Add-TypeAccelerator -Name PondUnitException -Type ([PondUnit.PondUnitException])
Add-TypeAccelerator -Name PondUnitState -Type ([PondUnit.PondUnitState])

. $here\Functions\Get-TestFixtures.ps1
. $here\Functions\Start-TestSession.ps1
. $here\Functions\Get-TestSession.ps1
. $here\Functions\Remove-TestSession.ps1
. $here\Functions\Get-Tests.ps1

Export-ModuleMember -Function *-*
Export-ModuleMember -Function $nonStandardFunctionsToSourceAndExport
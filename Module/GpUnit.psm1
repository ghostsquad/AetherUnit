$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Add-Type -Path $here\GpUnit.dll
Add-Type -Path $here\Dependencies\xunit.dll

. $here\Functions\Fixture.ps1

$psClassesToSource = @(
    'TestCase',
    'TestDefinition',
    'TestFixture',
    'TestSession',
    'TestInvocationInfo',
    'TestRunSummary',
    'FixtureDiscovererBase',
    'GpUnitFixtureDiscoverer',
    'TestRunnerBase',
    'GpunitParallelTestRunner',
    'GpunitDebugTestRunner'
)

foreach($psClassName in $psClassesToSource) {
    if(-not (Get-PSClass "Gpunit.$psClassName")) {
        . ('{0}\PSClasses\{1}.ps1' -f $here, $psClassName)
    }
}

foreach($assert in (get-childitem $here\Asserts)) {
    . $assert.FullName
}

Add-TypeAccelerator -Name StringConstantExpressionAst -Type ([System.Management.Automation.Language.StringConstantExpressionAst])
Add-TypeAccelerator -Name CommandParameterAst -Type ([System.Management.Automation.Language.CommandParameterAst])
Add-TypeAccelerator -Name CommandElementAst -Type ([System.Management.Automation.Language.CommandElementAst])
Add-TypeAccelerator -Name CommandAst -Type ([System.Management.Automation.Language.CommandAst])
Add-TypeAccelerator -Name ScriptBlockExpressionAst -Type ([System.Management.Automation.Language.ScriptBlockExpressionAst])
Add-TypeAccelerator -Name ScriptBlockAst -Type ([System.Management.Automation.Language.ScriptBlockAst])

Add-TypeAccelerator -Name GpunitException -Type ([Gpunit.GpunitException])
Add-TypeAccelerator -Name GpunitState -Type ([Gpunit.GpunitState])

. $here\Functions\Start-TestSession.ps1
. $here\Functions\Get-TestSession.ps1
. $here\Functions\Remove-TestSession.ps1
. $here\Functions\Get-Tests.ps1
. $here\Functions\New-PSClassFromTestFixture.ps1

Export-ModuleMember -Function *-*
Export-ModuleMember -Function Fixture
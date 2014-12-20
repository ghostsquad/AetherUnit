$ErrorActionPrefence = "Stop"
Set-StrictMode -Version Latest

if(-not (Get-Module PoshBox.PSClass -ListAvailable)){
    Throw (New-Object System.InvalidOperationException("PoshBox.PSClass cannot be found. Please visit https://github.com/ghostsquad/PoshBox"))
} elseif(-not (Get-Module PoshBox.PSClass )) {
    Import-Module PoshBox.PSClass -Global -DisableNameChecking
}

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$nonStandardFunctionsToSourceAndExport = @(
    'Fact',
    'Fixture',
    'Setup',
    'Teardown',
    'Theory',
    'UseFixtureDataObject'
)
foreach($func in $nonStandardFunctionsToSourceAndExport) {
    . ('{0}\Functions\{1}.ps1' -f $here, $func)
}

$psClassesToSource = @(
    'PoshUnitState',
    'TestObject',
    'Fixture',
    'TestSession',
    'TestRunnerBase',
    'PoshUnitParallelTestRunner',
    'PoshUnitDebugTestRunner'
)

foreach($psClassName in $psClassesToSource) {
    if(-not [PSClassContainer]::ClassDefinitions.ContainsKey("PoshUnit.$psClassName")) {
        . ('{0}\PSClasses\{1}.ps1' -f $here, $psClassName)
    }
}

Export-ModuleMember -Function *-*
Export-ModuleMember -Function $nonStandardFunctionsToSourceAndExport
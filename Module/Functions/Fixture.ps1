function Fixture {
    param (
        [string]$Name,
        [scriptblock]$Definition
    )

    throw (New-Object System.NotImplementedException)
}

## Internally used fixture functions
#function GetParentFixture {
#    param (
#        [string]$DataType
#    )
#    $parentInvocation = Get-Variable -Name MyInvocation -Scope 2 -ValueOnly
#    if($parentInvocation -eq $null -or $parentInvocation.MyCommand -ne 'Fixture') {
#        throw (New-Object PoshUnit.FixtureInitializationException(('A {0} must be used only inside of a Fixture.' -f $DataType)))
#    }

#    return (Get-Variable -Name Fixture -Scope 2 -ValueOnly)
#}

#function AddTestObjectToFixture {
#    param (
#        [psobject]$Fixture,
#        [string]$Name,
#        [scriptblock]$Definition,
#        [switch]$Theory = $false
#    )

#    $testObject = [PSClassContainer]::ClassDefinitions['PoshUnit.TestObject'].New($Name, $Definition, $Theory)

#    $Fixture.Tests.Enqueue($testObject)
#}
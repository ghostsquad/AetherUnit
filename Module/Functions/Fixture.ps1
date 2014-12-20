function Fixture {
    param (
        [string]$Name,
        [scriptblock]$Definition
    )

    # Create PoshUnit state if not created
    if($global:PoshUnitState -eq $null) {
        throw (New-Object PoshUnit.FixtureInitializationException(('Cannot find PoshUnitState. PoshUnit script files cannot be run alone. See Invoke-PoshUnit.')))
    }

    # On First Run, gather a list of tests within this fixture
    if() {
        $Local:Fixture = [PSClassContainer]::ClassDefinitions['PoshUnit.Fixture'].New($Name)

        [Void]([ScriptBlock]::Create($Definition.ToString()).InvokeReturnAsIs())

        $global:PoshUnitState.CurrentSession.Fixtures.Add($Fixture)
    }
}

# Internally used fixture functions
function GetParentFixture {
    param (
        [string]$DataType
    )
    $parentInvocation = Get-Variable -Name MyInvocation -Scope 2 -ValueOnly
    if($parentInvocation -eq $null -or $parentInvocation.MyCommand -ne 'Fixture') {
        throw (New-Object PoshUnit.FixtureInitializationException(('A {0} must be used only inside of a Fixture.' -f $DataType)))
    }

    return (Get-Variable -Name Fixture -Scope 2 -ValueOnly)
}

function AddTestObjectToFixture {
    param (
        [psobject]$Fixture,
        [string]$Name,
        [scriptblock]$Definition,
        [switch]$Theory = $false
    )

    $testObject = [PSClassContainer]::ClassDefinitions['PoshUnit.TestObject'].New($Name, $Definition, $Theory)

    $Fixture.Tests.Enqueue($testObject)
}
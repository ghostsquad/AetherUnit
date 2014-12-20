# function to be used inside the $Definition scriptblock parameter of the Fixture function
function UseFixtureDataObject {
    param (
        [scriptblock]$Definition
    )

    $Fixture = GetParentFixture -DataType 'UseFixtureDataObject'

    if($Fixture.LazyDataObject -ne $null) {
        throw (New-Object `
            PoshUnit.FixtureInitializationException(`
                "Only one instance of UseFixtureDataObject is allowed per fixture"))
    }

    $Fixture.LazyDataObject = New-Lazy $Definition
}

# function to be used inside the $Definition scriptblock parameter of the Fixture function
function UseDataFixture {
    param (
        [scriptblock]$Definition
    )

    throw (New-Object System.NotImplementedException)

    #$Fixture = GetParentFixture -DataType 'UseFixtureDataObject'

    #if($Fixture.LazyDataObject -ne $null) {
    #    throw (New-Object `
    #        PoshUnit.FixtureInitializationException(`
    #            "Only one instance of UseDataFixture is allowed per fixture"))
    #}

    #$Fixture.LazyDataObject = New-Lazy $Definition
}

# function to be used inside the $Definition scriptblock parameter of the Fixture function
function Setup {
    param (
        [scriptblock]$Definition
    )

    throw (New-Object System.NotImplementedException)

    #$Fixture = GetParentFixture -DataType 'Setup'

    #$Fixture.Setup = $Definition
}
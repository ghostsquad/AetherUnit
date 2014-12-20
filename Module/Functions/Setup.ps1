# function to be used inside the $Definition scriptblock parameter of the Fixture function
function Setup {
    param (
        [scriptblock]$Definition
    )

    $Fixture = GetParentFixture -DataType 'Setup'

    $Fixture.Setup = $Definition
}
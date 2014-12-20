# function to be used inside the $Definition scriptblock parameter of the Fixture function
function Teardown {
    param (
        [scriptblock]$Definition
    )

    $Fixture = GetParentFixture -DataType 'Teardown'

    $Fixture.Teardown = $Definition
}
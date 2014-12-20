# function to be used inside the $Definition scriptblock parameter of the Fixture function
function Fact {
    param (
        [string]$Name,
        [scriptblock]$Definition
    )

    $Fixture = GetParentFixture -DataType 'Fact'

    AddTestObjectToState $Fixture $Name $Definition
}
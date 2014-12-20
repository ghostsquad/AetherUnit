# function to be used inside the $Definition scriptblock parameter of the Fixture function
function Theory {
    param (
        [string]$Name,
        [scriptblock]$Definition
    )

    $Fixture = GetParentFixture -DataType 'Theory'

    AddTestObjectToState $Fixture $Name $Definition -Theory
}
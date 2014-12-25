# function to be used inside the $Definition scriptblock parameter of the Fixture function
function Theory {
    param (
        [string]$Name,
        [scriptblock]$Definition
    )

    throw (New-Object System.NotImplementedException)

    #$Fixture = GetParentFixture -DataType 'Theory'

    #AddTestObjectToState $Fixture $Name $Definition -Theory
}
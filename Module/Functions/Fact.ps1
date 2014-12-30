# function to be used inside the $Definition scriptblock parameter of the Fixture function
function Fact {
    param (
        [string]$Name,
        [scriptblock]$Definition
    )

    throw (New-Object System.NotImplementedException)
}
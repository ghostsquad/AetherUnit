# function to be used inside the $Definition scriptblock parameter of the Fixture function
function Teardown {
    param (
        [scriptblock]$Definition
    )

    throw (New-Object System.NotImplementedException)
}
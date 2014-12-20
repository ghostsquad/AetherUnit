# function to be used inside the $Definition scriptblock parameter of the Fixture function
function FixtureNote {
    param (
        [string]$NoteName
    )

    $Fixture = GetParentFixture -DataType 'FixtureNote'

    $Fixture.FixtureNotes.Add($NoteName)
}
function CreateFixtureClassFromMeta {
    param(
        $FixtureMeta
    )

    Guard-ObjectIsPSClass $FixtureMeta 'PoshUnit.FixtureMeta'

    $testClass = New-PSClass $FixtureMeta.Name {
        constructor $FixtureMeta.Setup
        foreach($test in $FixtureMeta.Tests) {
            method $test.Name $test.Definition
        }

        foreach($fixtureNoteName in $FixtureMeta.FixtureNotes) {
            note $fixtureNoteName
        }

        method 'Dispose' $test.Teardown

        note 'FixtureDataObject' $($FixtureMeta.GetDataObject())
    }.GetNewClosure() -PassThru

    return $testClass
}
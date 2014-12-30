function CreateFixtureClassFromMeta {
    param(
        $FixtureMeta
    )

    Guard-ArgumentIsPSClass 'FixtureMeta' $FixtureMeta 'PondUnit.FixtureMeta'

    $testClass = New-PSClass ([Guid]::NewGuid().ToString()) {} -PassThru
    Attach-PSClassConstructor $testClass $FixtureMeta.Setup

    foreach($test in $FixtureMeta.Tests) {
        Attach-PSClassMethod $testClass $test.DisplayName $test.Definition
    }

    Attach-PSClassMethod $testClass 'Dispose' $FixtureMeta.Teardown

    Attach-PSClassNote $testClass 'FixtureDataObject' $FixtureMeta.GetDataObject() -forceValueAssignment

    return $testClass
}
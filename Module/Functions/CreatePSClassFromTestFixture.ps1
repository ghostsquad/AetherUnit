function CreatePSClassFromTestFixture {
    param(
        $TestFixture
    )

    Guard-ArgumentIsPSClass 'TestFixture' $TestFixture 'PondUnit.TestFixture'

    $testClass = New-PSClass ([Guid]::NewGuid().ToString()) {} -PassThru
    Attach-PSClassConstructor $testClass $TestFixture.Setup

    foreach($test in $TestFixture.Tests) {
        Attach-PSClassMethod $testClass $test.DisplayName $test.Definition
    }

    Attach-PSClassMethod $testClass 'Dispose' $TestFixture.Teardown

    Attach-PSClassNote $testClass 'FixtureDataObject' $TestFixture.GetDataObject() -forceValueAssignment

    $TestInvocationInfo = (Get-PSClass 'PondUnit.TestInvocationInfo').New($TestFixture.FilePath)

    Attach-PSClassNote $testClass '__TestInvocationInfo' $TestInvocationInfo -forceValueAssignment

    return $testClass
}
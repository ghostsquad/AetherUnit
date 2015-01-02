function Create-PSClassFromTestFixture {
    param(
        $TestFixture
    )

    Guard-ArgumentIsPSClass 'TestFixture' $TestFixture 'PondUnit.TestFixture'

    $testClass = New-PSClass ([Guid]::NewGuid().ToString()) {} -PassThru

    Attach-PSClassConstructor $testClass $TestFixture.Setup

    foreach($test in $TestFixture.Tests) {
        Attach-PSClassMethod -Class $testClass -Name $test.DisplayName -Script $test.Definition
    }

    foreach($method in $TestFixture.Methods) {
        Attach-PSClassMethod -Class $testClass -Name $method['Name'] -Script $method['Script']
    }

    foreach($note in $TestFixture.Notes) {
        $noteSplat = @{
            Class = $testClass
            Name = $note['Name']
            Value = $note['Value']
        }

        Attach-PSClassNote @noteSplat
    }

    foreach($property in $TestFixture.Properties) {
        $propertySplat = @{
            Class = $testClass
            Name = $property['Name']
            Get = $property['Get']
            Set = $property['Set']
        }

        Attach-PSClassProperty @propertySplat
    }

    Attach-PSClassMethod $testClass 'Dispose' $TestFixture.Teardown

    Attach-PSClassNote $testClass 'FixtureDataObject' $TestFixture.GetDataObject() -forceValueAssignment

    $TestInvocationInfo = (Get-PSClass 'PondUnit.TestInvocationInfo').New($TestFixture.FilePath)

    Attach-PSClassNote $testClass 'TestInvocationInfo' $TestInvocationInfo -forceValueAssignment

    return $testClass
}
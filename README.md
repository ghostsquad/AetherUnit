# PoshUnit

<img src="https://raw.githubusercontent.com/ghostsquad/PoshUnit/readme/Content/PoshUnitLogo.png" alt="PoshUnit Logo" title="PoshUnit" align="right" />

PoshUnit is a Powershell unit test framework. Testing in C# with XUnit, Fluent Assertions, Moq, and Autofixture is an amazing experience. I wanted to bring that to Powershell. Here are the core concepts that make PoshUnit stand out from the crowd:

* **Test Isolation** - Tests are run in complete isolation from each other. Like in XUnit, the fixture is recreated once per test.
* **Test Attributes** - Organize, Control, and Extend the functionality of tests using attributes
  * Explicit Tests (NUnit [explanation](http://www.nunit.org/index.php?p=explicit&r=2.2.10))
  * Skip Tests (XUnit)
  * Test Extension Attribute Examples [here](http://callumhibbert.blogspot.com/2008_01_01_archive.html) and [here](http://www.dotnetguy.co.uk/post/2010/04/01/xunit-freezeclock-black-magic-stopping-time/)
* **Hierarchical Organization** - Organize tests like you would in C# by Project, Namespace, Class, TestName
* **Test Sessions** - Select specific tests to be run using a test-session, rerunning a test-session only runs the tests you've selected. If you've selected a fixture, all tests within the fixture will be run, including new ones that you've added since last run.
* **Test Search** - Find tests by name, attribute with builtin in tab-completion!
* **Clean, Detailed Output** - result, runtime, standard output, trace, etc. Data is stored in a global variable to use/analyze as needed, as well as to the console and results JSON file.
* **Per Test & Per Fixture Setup and Teardown** - I agree that setup/teardown methods make a test harder to understand, and explicit calls to helper methods would keep tests clear. Regardless, I'm not everyone, and I thought it would be useful to support Per Test & Per Fixture setup & teardown like other frameworks.

### Complementary Modules

* [**PSFluentAssertions**](http://github.com/ghostsquad/PSFluentAssertions) - A PowerShell adaptation of the [.NET FluentAssertions library](http://www.fluentassertions.com/).

* [**PSClass & PSClassMock**](http://github.com/ghostsquad/PSClass) - Write code & test it faster, and with greater confidence.

* [**PSMoq**](http://github.com/ghostsquad/PSMoq) - A PowerShell adaptation of the [.Net Moq library](https://github.com/Moq/moq4).

* [**PSAutofixture**](http://github.com/ghostsquad/PSAutoFixture) - A PowerShell adaptation of the [.Net Autofixture library](https://github.com/AutoFixture/AutoFixture).

### Design Notes & Restrictions

* Variables outside of the Fixture are not accessible unless they are in the Global scope.

* The script invocation information is stored in an autovariable $TestInvocationInfo. This may be needed to resolve paths to other scripts/files when the test is run.

* The Fixture, Fact, and Theory methods simply define the test definition. Nothing is actually run without using Invoke-PoshUnit. This differs from popular testing framework Pester,
but offers some powerful capabilities.


### Examples

```Powershell
$RepeatCustomization = New-TestCustomization {
    param(
        [scriptblock]$testDefinition
    )

    $repeatCount = $args[0]

    # make sure to return an array ALWAYS
    $TestScripts = @()

    # this simply runs the test multiple times using the repeatCount arg
    for($i = 0; $i -lt $repeatCount; $i++) {
        [Void]$TestScripts.Add($testDefinition)
    }

    # using the comma trick, this will ensure that an actual array is returned
    # even if there are 1 or no elements in the array
    return ,$TestScripts
}

$o = New-Object PSObject
$o

PoshUnitFixture 'FooFixture' {
    #####
    # This is how PoshUnit provides a per-fixture data object.
    # The test runner will call this scriptblock just once before the first test in this fixture is run.
    # The object returned will have a lifetime tied to the all the tests in this fixture.
    # In other words, it will only be disposed when all tests within this test fixture have run.
    # After all tests for this TestFixture have run, if a "Dispose" method exists
    # on the object, it will be invoked at that time.
    UseDataFixture {
        $o = (new-object psobject)
        Attach-PSScriptMethod $o GetHelloMessage {
            return 'hello world'
        }
        Attach-PSScriptMethod $o Dispose {
            write-host "doing data fixture cleanup"
        }
        #this scriptblock should return an object
        return $o
    }

    Setup {
        $this.tellUsBefore = { write-host 'before test' }
        $this.propertyDataSource = @(
            @('paramA-1', 'paramB-1'),
            @('paramA-2', 'paramB-2')
        )

        $this.myVar = 'foo'
    }

    Teardown {
        write-host 'fixture teardown here'
    }
    #####

    Fact 'UsingFixtureDataObjectInSomeWay' {
        $myMessage = $this.FixtureDataObject.GetHelloMessage()
        # .. do more stuff
    }

    Fact 'VanillaTest' {
        param()
    }

    Fact 'SkippedFact' {
        [Skip("This Test Sucks")]
        param()
    }

    Fact 'Fact with max runtime of 50 ms' {
        [Timeout(50)]
        param()
    }

    Fact 'CustomBeforeScript' {
        [Before({ write-host 'before test' })]
        param()
    }

    Fact 'CustomBeforeScript2' {
        #TellUsBefore really points to $this.TellUsBefore
        [Before('TellUsBefore')]
        param()
    }

    Fact 'CustomAfterScript' {
        [After({ write-host 'after test' })]
        param()
    }

    Fact 'CustomAttribute' {
        [TestCustomization($RepeatCustomization, 5)]
        param()
    }

    # This generates 1 test per item in the collection provided, in this case, 2 tests
    # note the datasource must be a collection of collections
    # the outer collection is the number of test cases to generate
    # the inner collection is the ordered parameter values
    # further collections inside are not unrolled, and will be passed as a parameter
    Theory 'VariableDataTheory' {
        [VariableDataSource('propertyDataSource')]
        param($a, $b)
    }

    # This generates 2 test cases
    Theory 'InlineDataTheories' {
        [InlineData('value1', 'value2')]
        [InlineData('value3', 'value4')]
        param($a, $b)
    }

    # The Following Examples Require PSAutoFixture
    Fact 'GivenFooExpectBar' {
        [AutoData]
        param([string]$a, [int]$b)
    }

    Fact 'GivenFooExpectBar' {
        [AutoPSClassData('MyAnimalClass')]
        param([psobject]$a)
    }

    Fact 'GivenFooExpectBar' {
        [AutoMixedData('MyAnimalClass')]
        param([psobject]$a, [string]$b, [int]$c)
    }
}

```


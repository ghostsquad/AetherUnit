# GpUnit (GravityPS-Unit)

<img src="https://raw.githubusercontent.com/ghostsquad/GpUnit/master/Content/GpUnitLogo.png" alt="GpUnitUnit Logo" title="GpUnit" align="right" />

GpUnit is a Gravity-Driven Powershell unit test framework. Testing in C# with XUnit, Fluent Assertions, Moq, and Autofixture is an amazing experience. I wanted to bring that to Powershell. Here are the core concepts that make GpUnit stand out from the crowd:

* **Test Isolation** - Tests are run in complete isolation from each other. Like in XUnit, the fixture is recreated once per test.
* **Extensibility** - Organize, Control, and Extend the functionality of tests using attributes
  * Explicit Tests (NUnit [explanation](http://www.nunit.org/index.php?p=explicit&r=2.2.10))
  * Skip Tests (XUnit)
  * Test Extension Attribute Examples [here](http://callumhibbert.blogspot.com/2008_01_01_archive.html) and [here](http://www.dotnetguy.co.uk/post/2010/04/01/xunit-freezeclock-black-magic-stopping-time/)
* **Hierarchical Organization** - Test hierarchy can be obtained using Dot-Notation. C# conventions using Project, Namespace, Class, TestName is easy. _Example:_ A fixture with the name Foo.Bar.Baz will be siblings to other fixtures using the Foo.Bar prefix.
* **Test Sessions** - When a specific test pattern, or runlist is used, that information and the results from the tests are saved automatically. Those tests can be rerun with ease. And new sessions, with different selection patterns can be created without affecting other tests. Example: create a test session, excluding all 'integration' tests. When all tests from this session are green, you can then run your session for ONLY 'integration' tests. This saves lots of time, and typing, and there's no need to save/lookup your console command history.
* **Test Search** - Find tests by name, attribute with builtin in tab-auto-complete!
* **Clean, Detailed Output** - result, runtime, standard output, trace, etc. Data is stored in the global scope, and is easily accessible. In addition to the console, results can be output to JSON or XML with the NUnit-Schema.a
* **Per Test & Per Fixture Setup and Teardown** - I agree that setup/teardown methods, while benefiting from the DRY principle, can make a test harder to understand. Explicit calls to helper methods help keep tests clear and readable. Regardless, I'm not everyone, and I thought it would be useful to support Per Test & Per Fixture setup & teardown like other frameworks.

### Complementary Modules

* [**GpAssert**](http://github.com/ghostsquad/GpAssert) - A PowerShell adaptation of the [.NET FluentAssertions library](http://www.fluentassertions.com/).

* [**GpClass & GpClassMock**](http://github.com/ghostsquad/GpClass) - Write code & test it faster, and with greater confidence.

* [**GpMoq**](http://github.com/ghostsquad/gpMoq) - A PowerShell adaptation of the [.Net Moq library](https://github.com/Moq/moq4).

* [**GpAuto**](http://github.com/ghostsquad/GpAuto) - A PowerShell adaptation of the [.Net Autofixture library](https://github.com/AutoFixture/AutoFixture).

### Design Notes & Restrictions

* Variables outside of the Fixture are not accessible unless they are in the Global scope.

* The script invocation information is stored in an automatic fixture variable accessible from any fixture method by calling out to `$this.TestInvocationInfo`. This may be needed to resolve paths to other scripts/files when the test is run.

* The methods used to define the aspects of a test fixture are simply "markers", and are never actually invoked. The PowerShell AST is used to discover and build test fixtures. This differs from other PS testing frameworks like Pester, which run tests as they are discovered.

* **Important:** Any code inside of test file that is not associated with one of the
following commands will **NOT RUN**:
  * Fixture
  * Fact/Theory
  * Setup/Constructor
  * Teardown/Dispose
  * UseDataFixture
  * Method
  * Note
  * Property

* Any code that needs to run prior to _any_ tests (such as declaring customizations), can be contained inside of an `gpunit.init.ps1` file within the test root. Only 1 file by this name should exist. This file is invoked as-is within the runspace the tests are run in. If more than 1 runspace is required (such as with a parallel test runner), this file will be invoked multiple times (but always no more than 1/runspace). As such, it is important to be mindful of potential race conditions and toe stepping if you are performing work on outside elements (databases, filesystem, network devices, etc).

### Examples

```Powershell
#
# here's an example of the runtime extensibility of GpUnit
# a function is provided that allows for arbitrary
# control over how a testDefinition is invoked
#
New-TestCustomizationAttribute 'RepeatCustomizationAttribute' {
    # testCustomizations should always include this param block
    # The test runner will call this, providing the test definition
    # (think of this like MethodInfo)
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

    # return 1 or more scriptblocks, which will be used as the definition of each test
    return ,$TestScripts
}

New-BeforeAttribute 'MyCustomBeforeAttribute' {

}

Fixture 'FooFixture' {

    #
    # shorthand ways of defining notes on the fixture
    # which can be assigned values at any time
    # default values are supported, but only if they are value types (or strings)
    #
    note propertyDataSource
    note myVar 'hello world'

    #
    # This is synonymous to 'constructor'
    # and is run when the testFixture object is created
    # this will effectively run before each test
    # note though, that property/note values (except DataFixtureObject)
    # do NOT persist between tests
    # they are reinitalized each time using the default value provided
    # or if a value is assigned in Setup/Constructor
    #
    Setup {
        $this.propertyDataSource = @(
            @('paramA-1', 'paramB-1'),
            @('paramA-2', 'paramB-2')
        )

        $this.myVar = 'a new value'
    }

    #
    # This is synonymous to 'dispose'
    # this is run after each test, just before the testFixture object is destroyed
    # use this like you would use Dispose in .NET
    # don't worry about resetting values or anything, the testFixture
    # is recreated for each test
    #
    Teardown {
        write-host 'fixture teardown here'
    }

    #
    # This is how GpUnit provides a per-fixture data object.
    # The test runner will call this scriptblock just once before the first test in this fixture is run.
    # The object returned will have a lifetime tied to the all the tests in this fixture.
    # In other words, it will only be disposed when all tests within this test fixture have run.
    # After all tests for this TestFixture have run, if a "Dispose" method exists
    # on the object, it will be invoked at that time.
    # this object can be found within any fixture test/method/property using $this.FixtureDataObject
    #
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

    #
    # here's a vanilla FACT
    # it is accessing the persistent FixtureDataObject
    # it will PASS
    #
    Fact 'UsingFixtureDataObjectInSomeWay' {
        $myMessage = $this.FixtureDataObject.GetHelloMessage()

        Assert-Equal $myMessage 'hello world'
    }

    #
    # here's another vanilla FACT
    # note that the 'param' block is only required if
    # you would like to decorate this fact with one or more attributes
    # this will FAIL
    #
    Fact 'VanillaTest' {
        Assert-True $false
    }

    #
    # this FACT will not run
    # even if explicitly selected
    # use the 'Explicit' attribute if you would like the test to run if
    # it is explicitly included when starting a new test session
    #
    Fact 'SkippedFact' {
        [Skip("This Test Sucks")]
        param()
    }

    #
    # this FACT will FAIL
    # because it will take more than 50ms to run
    #
    Fact 'Fact with max runtime of 50 ms' {
        [Timeout(50)]
        param()

        Start-Sleep -MilliSeconds 100
    }

    #
    # PowerShell allows Scriptblocks (which are really just strings that are later interpreted)
    # to be used as parameter constants for attributes
    # this Fact has a scriptblock that will run prior to the test running
    # behind the scenes, the scriptblock becomes a method of the testFixture
    # as such, the $this variable will point to the testFixture instance
    # no variables within the FACT will be visible
    #
    Fact 'CustomBeforeScript' {
        [Before({ write-host 'before test' })]
        param()
    }

    #
    # Here's another way to use the Before/After attributes
    # if your script block is long, it will probably make your test code
    # quite unreadable. So, we'll do a little legwork for you
    # provided a string, we'll look up a method on the Fixture
    # with that name and call it.
    #


    Fact 'CustomAfterScript' {
        [After({ write-host 'after test' })]
        param()
    }

    Fact 'CustomAttribute' {
        # yes, you are looking at the correctly,
        # the New-TestCustomizationAttribute method will dynamically create a
        # attribute .net class for you to use for your test!
        [GpUnit.RepeatCustomization(5)]
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

    # This requires GpAuto
    Fact 'GivenFooExpectBar' {
        [AutoData]
        param([string]$a, [int]$b)
    }

    # This requires GpAuto & GpAutoPSClass
    Fact 'GivenFooExpectBar' {
        [AutoPSClassData('MyAnimalClass')]
        param([psobject]$a)
    }

    # This requires GpAuto & GpAutoPSClass
    Fact 'GivenFooExpectBar' {
        [AutoMixedData('MyAnimalClass')]
        param([psobject]$a, [string]$b, [int]$c)
    }
}

```


# PoshUnit

<img src="https://raw.githubusercontent.com/ghostsquad/PoshUnit/readme/Content/PoshUnitLogo.png" alt="PoshUnit Logo" title="PoshUnit" align="right" />

PoshUnit is a Powershell unit test framework. Testing in C# with XUnit, Fluent Assertions, Moq, and Autofixture is an amazing experience. I wanted to bring that to Powershell. Here are the core concepts that make PoshUnit stand out from the crowd:

1. **Test Isolation** - Tests are run in complete isolation from each other. Like in XUnit, the fixture is recreated once per test. 
2. **Setup and Teardown** - Although normally, I would agree that setup/teardown methods make the code harder to understand, if done correctly, it can save a lot of time and keep code DRY. XUnit states that the constructor/dispose methods of the test class can be used like setup/teardown.
3. **Fluent Assertions w/ nice messages** - [Fluent Assertions](https://github.com/dennisdoomen/fluentassertions) makes debugging easier with cleaner messages. No more vague messages like "expected false, but was true".
4. **Test Attributes** - Organize, Control, and Extend the functionality of tests using attributes
  * Explicit Tests (NUnit [explanation](http://www.nunit.org/index.php?p=explicit&r=2.2.10))
  * Skip Tests (XUnit)
  * Test Extension Attribute Examples [here](http://callumhibbert.blogspot.com/2008_01_01_archive.html) and [here](http://www.dotnetguy.co.uk/post/2010/04/01/xunit-freezeclock-black-magic-stopping-time/)
5. **Hierarchical Organization** - Organize tests like you would in C# by Project, Namespace, Class, TestName
6. **Tab Expansion** - Built-In tab expansion for finding tests by name/attribute
7. **Clear, Consistent Naming** - Built-In support for BDD naming syntax.
8. **Clean, Detailed Output** - result, runtime, standard output, trace, etc. Data is stored in a global variable to use/analyze as needed, as well as to the console and results JSON file.
9. **Mocking DI Style** - Pester, PSUnit and others have focused on allowing developers to mock out function calls, like Get-ChildItem within the SUT (System under test). This seems like a good idea at first, but quickly, you'll realize that you have no guarantee that when you run your test, you will call the actual function or the mocked function, or if that function is even being used anymore. You end up breaking the first rule of testing, which is that you should not know about implementation details. Implementation details may change, but thes tests shouldn't (as long as the behavior remains the same).
10. **AutoMockTestable Pattern** - Don't inject dependencies that aren't related to your test. Let the AutoMock container handle that!

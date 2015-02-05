Fixture 'FooFixture' {

    FixtureNote myVar
    FixtureNote propertyDataSource
    FixtureNote tellUsBefore

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
}

Fixture -Name 'FooFixture' -Definition {

}
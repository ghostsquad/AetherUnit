$myTestFixture = New-TestFixture {	
	$foo = "hello world"
	$bar = ("foo")
	$asdf = ("foo" + $(Get-Location))
	
	function fooInnerParams {
		[cmdletbinding()]
		param()
	}
	
	function fooOuterParams($param1) {
	
	}

	$setup = New-TestSetup {		
		Write-Output "Setup"
	}
	
	$teardown = New-TestTeardown {
		Write-Output "Teardown"
	}
	
	$testFail = New-Test {
		throw "omg! wtf happened?"
	}
	
	$test1 = New-Test {
		Write-Output "Test1!"
	}
	
	$testFoo = New-Test {
		Write-Output "value of foo: $foo"
	}
}
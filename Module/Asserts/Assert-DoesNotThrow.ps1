function Assert-DoesNotThrow {
	param(
		[Parameter(ValueFromPipeline=$true)]
		[delegate]$testCode
	)
	
	[Xunit.Assert]::DoesNotThrow($testCode)
}
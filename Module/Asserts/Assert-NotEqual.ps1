function Assert-NotEqual {
	param(
		[Parameter(ValueFromPipeline=$true)]
		[object]$expected,
		[object]$actual		
	)
	[Xunit.Assert]::NotEqual($expected, $actual)
}
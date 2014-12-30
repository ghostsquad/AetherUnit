function Assert-IsAssignableFrom {
	param(
		[Parameter(ValueFromPipeline=$true)]
		[System.Type]$expectedType,
		[object]$object
	)
	
	[Xunit.Assert]::IsAssignableFrom($expectedType, $object)
}
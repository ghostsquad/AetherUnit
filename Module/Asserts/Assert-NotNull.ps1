function Assert-NotNull {
	param(
		[Parameter(ValueFromPipeline=$true)]
		[Object]$object
	)
	[Xunit.Assert]::NotNull($object)
}
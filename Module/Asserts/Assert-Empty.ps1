function Assert-Empty {
	param(
		[Parameter(ValueFromPipeline=$true)]
		[System.Collections.IEnumerable]$collection
	)
	
	[Xunit.Assert]::Empty($collection)
}
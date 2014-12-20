New-PSClass 'PoshUnit.TestObject' {
    note Name
    note Definition
    note IsTheory

    constructor {
        param(
            [string]$Name,
            [scriptblock]$Definition,
            [bool]$IsTheory = $false
        )

        Guard-ArgumentNotNull 'Name' $Name
        Guard-ArgumentNotNull 'Definition' $Definition

        $this.Name = $Name
        $this.Definition = $Definition
        $this.IsTheory = $IsTheory
    }
}
New-PSClass 'PondUnit.TestFixture' {
    note Name
    note Tests
    note Setup
    note Teardown
    note LazyDataObject

    constructor {
        param(
            [string]$Name
        )

        Guard-ArgumentNotNull 'Name' $Name

        $this.Name = $Name
        $this.Tests = (New-Object System.Collections.ArrayList)
        $this.Setup = {}
        $this.Teardown = {}
        $this.LazyDataObject = (New-Lazy { return $null })
    }

    method GetDataObject {
        return $this.LazyDataObject.Value
    }
}
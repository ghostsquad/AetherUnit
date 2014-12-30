New-PSClass 'PondUnit.TestFixture' {
    note Name
    note Tests
    note Setup
    note Teardown
    note LazyDataObject
    note FilePath

    constructor {
        param(
            [string]$Name,
            [string]$FilePath
        )

        Guard-ArgumentNotNull 'Name' $Name
        Guard-ArgumentNotNull 'FilePath' $FilePath

        $this.Name = $Name
        $this.FilePath = $FilePath
        $this.Tests = (New-Object System.Collections.ArrayList)
        $this.Setup = {}
        $this.Teardown = {}
        $this.LazyDataObject = (New-Lazy { return $null })
    }

    method GetDataObject {
        return $this.LazyDataObject.Value
    }
}
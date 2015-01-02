New-PSClass 'GpUnit.TestFixture' {
    note Name
    note Tests
    note Setup
    note Teardown
    note LazyDataObject
    note FilePath
    note Methods
    note Notes
    note Properties

    constructor {
        param(
            [string]$Name,
            [string]$FilePath
        )

        Guard-ArgumentNotNull 'Name' $Name
        Guard-ArgumentNotNull 'FilePath' $FilePath

        $this.Name = $Name
        $this.FilePath = $FilePath
        $this.Tests = New-Object System.Collections.ArrayList
        $this.Setup = {}
        $this.Teardown = {}
        $this.LazyDataObject = New-Lazy { return $null }
        $this.Notes = New-Object System.Collections.ArrayList
        $this.Methods = New-Object System.Collections.ArrayList
        $this.Properties = New-Object System.Collections.ArrayList
    }

    method GetDataObject {
        return $this.LazyDataObject.Value
    }
}
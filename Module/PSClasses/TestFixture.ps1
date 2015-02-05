New-PSClass 'GpUnit.TestFixture' {

    # [string]
    note Name

    # ArrayList of PSClass [GpUnit.TestDefinition]
    note TestDefinitions

    # [ScriptBlock]
    note Setup

    # [ScriptBlock]
    note Teardown

    # [System.Lazy]
    note LazyDataObject

    # [String]
    note FilePath

    # HashTable
    note Methods

    # HashTable
    note Notes

    # HashTable
    note Properties

    # PSClass [GpUnit.TestRunSummary]
    note TestRunSummary

    constructor {
        param(
            [string]$Name,
            [string]$FilePath
        )

        Guard-ArgumentNotNull 'Name' $Name
        Guard-ArgumentNotNull 'FilePath' $FilePath

        $this.Name = $Name
        $this.FilePath = $FilePath
        $this.TestDefinitions = New-Object System.Collections.ArrayList
        $this.Setup = {}
        $this.Teardown = {}
        $this.LazyDataObject = New-Lazy { return $null }
        $this.Notes = New-Object System.Collections.ArrayList
        $this.Methods = New-Object System.Collections.ArrayList
        $this.Properties = New-Object System.Collections.ArrayList
        $this.TestRunSummary = (Get-PSClass 'GpUnit.TestRunSummary').New()
    }

    method UpdateTestTotal {
        $this.TestRunSummary.Total = ($this.TestDefinitions | %{$_.TestCases.Count} | Measure-Object -Sum).Sum
    }

    method GetDataObject {
        return $this.LazyDataObject.Value
    }

    method -override ToString {
        return $this.Name
    }
}
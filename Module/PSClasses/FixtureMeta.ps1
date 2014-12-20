New-PSClass 'PoshUnit.FixtureMeta' {
    note Name
    note Tests (New-Object System.Collections.Generic.Queue[object])
    note Setup {}
    note Teardown {}
    note LazyDataObject (New-Lazy { return $null })
    note Notes (New-Object System.Collections.ArrayList)

    constructor {
        param(
            [string]$Name
        )

        Guard-ArgumentNotNull 'Name' $Name

        $this.Name = $Name
    }

    method GetDataObject {
        return $this.LazyDataObject.Value
    }
}
New-PSClass 'PondUnit.TestInvocationInfo' {
    note __filePath
    property FilePath {
        return $this.__filePath
    }

    constructor {
        param (
            $FilePath
        )

        $this.__filePath = $FilePath
    }
}
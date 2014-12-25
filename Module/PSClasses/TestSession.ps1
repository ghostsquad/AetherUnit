New-PSClass 'PoshUnit.TestSession' {
    Note Tests (New-Object System.Collections.ArrayList)
    Note SessionId
    constructor {
        param(
            [int]$SessionId
        )

        $this.SessionId = $SessionId
    }
}
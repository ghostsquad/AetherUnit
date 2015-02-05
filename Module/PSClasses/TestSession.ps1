New-PSClass 'GpUnit.TestSession' {
    # [int]
    note SessionId

    # ArrayList of PSClass [GpUnit.TestCase]
    note Tests

    # [int]
    note Total

    # [int]
    note Failed

    # [int]
    note Skipped

    # [double]
    note Time

    constructor {
        param(
            [int]$SessionId
        )

        $this.SessionId = $SessionId
        $this.Tests = New-Object System.Collections.ArrayList
    }

    method _Aggregate {
        param (
            $TestRunSummary
        )

        Guard-ArgumentIsPSClass 'TestRunSummary' $TestRunSummary 'GpUnit.TestRunSummary'

        $this.Total += $TestRunSummary.Total
        $this.Failed += $TestRunSummary.Failed
        $this.Skipped += $TestRunSummary.Skipped
        $this.Time += $TestRunSummary.Time
    }
}
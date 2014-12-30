New-PSClass 'PoshUnit.TestSession' {
    note SessionId

    note SelectedTestDictionary

    note Total
    note Failed
    note Skipped
    note Time

    constructor {
        param(
            [int]$SessionId
        )

        $this.SelectedTestDictionary = @{}
        $this.SessionId = $SessionId
    }

    method Aggregate {
        param (
            $TestRunSummary
        )

        Guard-ArgumentIsPSClass 'TestRunSummary' $TestRunSummary 'PoshUnit.TestRunSummary'

        $this.Total += $TestRunSummary.Total
        $this.Failed += $TestRunSummary.Failed
        $this.Skipped += $TestRunSummary.Skipped
        $this.Time += $TestRunSummary.Time
    }
}
New-PSClass 'PoshUnit.TestRunSummary' {
    note Total
    note Failed
    note Skipped
    note Time

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
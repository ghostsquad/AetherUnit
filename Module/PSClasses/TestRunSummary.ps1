New-PSClass 'GpUnit.TestRunSummary' {
    note Total 0
    note Failed 0
    note Skipped 0
    note Time 0

    constructor {
        param (
            [int]$Total,
            [int]$Failed,
            [int]$Skipped,
            [decimal]$Time
        )

        $this.Total += $Total
        $this.Failed += $Failed
        $this.Skipped += $Skipped
        $this.Time += $Time
    }

    method Aggregate {
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
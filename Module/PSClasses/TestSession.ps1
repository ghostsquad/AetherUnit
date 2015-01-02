New-PSClass 'GpUnit.TestSession' {
    note SessionId

    note SelectedTestDictionary

    note Total
    note Failed
    note Skipped
    note Time

    note Runner

    constructor {
        param(
            [int]$SessionId
            $Runner
        )

        $this.SessionId = $SessionId
        Guard-ArgumentIsPSClass 'Runner' $Runner 'GpUnit.TestRunnerBase'

        $this.SelectedTestDictionary = @{}
    }

    method Run {
        return $this.Runner.RunSessionTests($this.SelectedTestDictionary)
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
New-PSClass 'PoshUnit.TestCase' {
    # [System.String]
    note DisplayName

    # [System.Management.Automation.ScriptBlock]
    note Definition

    # [PoshUnit.TestResult]
    note Result ([PoshUnit.TestResult]::NotRun)

    # [System.String]
    note SkipReason

    # [System.Management.Automation.ErrorRecord]
    note ErrorRecord

    # [PoshUnit.FailureReason]
    note FailureReason

    # PSClass [PoshUnit.Fixture]
    note Fixture

    constructor {
        param(
            [string]$DisplayName,
            [scriptblock]$Definition,
            $Fixture
        )

        Guard-ArgumentNotNull 'DisplayName' $DisplayName
        Guard-ArgumentNotNull 'Definition' $Definition
        Guard-ArgumentNotNull 'Fixture' $Fixture

        $this.DisplayName = $DisplayName
        $this.Definition = $Definition
        $this.Fixture = $Fixture
    }
}
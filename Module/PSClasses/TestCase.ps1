New-PSClass 'PoshUnit.TestCase' {
    # [System.String]
    note DisplayName

    # [System.Management.Automation.ScriptBlock]
    note Definition

    # [PoshUnit.TestResult]
    note Result ([PoshUnit.TestResult]::NotRun)

    # [System.String]
    note SkipReason

    # [System.Management.Automation.ErrorRecord[]]
    note Errors

    # [PoshUnit.FailureReason]
    note FailureReason

    # PSClass [PoshUnit.Fixture]
    note FixtureMeta

    constructor {
        param(
            [string]$DisplayName,
            [scriptblock]$Definition,
            $FixtureMeta
        )

        Guard-ArgumentNotNull 'DisplayName' $DisplayName
        Guard-ArgumentNotNull 'Definition' $Definition
        Guard-ArgumentNotNull 'FixtureMeta' $FixtureMeta

        $this.DisplayName = $DisplayName
        $this.Definition = $Definition
        $this.FixtureMeta = $FixtureMeta
    }
}
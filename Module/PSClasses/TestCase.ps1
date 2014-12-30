New-PSClass 'PondUnit.TestCase' {
    # [System.String]
    note DisplayName

    # [System.Management.Automation.ScriptBlock]
    note Definition

    # [PondUnit.TestResult]
    note Result ([PondUnit.TestResult]::NotRun)

    # [System.String]
    note SkipReason

    # [System.Management.Automation.ErrorRecord[]]
    note Errors

    # [PondUnit.FailureReason]
    note FailureReason

    # PSClass [PondUnit.Fixture]
    note TestFixture

    constructor {
        param(
            [string]$DisplayName,
            [scriptblock]$Definition,
            $TestFixture
        )

        Guard-ArgumentNotNull 'DisplayName' $DisplayName
        Guard-ArgumentNotNull 'Definition' $Definition
        Guard-ArgumentIsPSClass 'TestFixture' $TestFixture 'PondUnit.TestFixture'

        $this.DisplayName = $DisplayName
        $this.Definition = $Definition
        $this.TestFixture = $TestFixture
    }
}
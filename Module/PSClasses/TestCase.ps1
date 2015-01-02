New-PSClass 'GpUnit.TestCase' {
    # [System.String]
    note DisplayName

    # [GpUnit.TestDefinition]
    note TestDefinition

    # [GpUnit.TestResult]
    note Result ([GpUnit.TestResult]::NotRun)

    # [System.Management.Automation.ErrorRecord[]]
    note Errors

    # [GpUnit.FailureReason]
    note FailureReason

    # [GpUnit.DataAttribute]
    note DataAttribute

    constructor {
        param(
            [string]$DisplayName,
            $TestDefinition,
            [GpUnit.DataAttribute]$DataAttribute
        )

        Guard-ArgumentNotNull 'DisplayName' $DisplayName
        Guard-ArgumentIsPSClass 'TestDefinition' $TestDefinition 'GpUnit.TestDefinition'

        $this.DisplayName = $DisplayName
        $this.TestDefinition = $TestDefinition
        $this.Errors = New-Object System.Collections.ArrayList
    }
}
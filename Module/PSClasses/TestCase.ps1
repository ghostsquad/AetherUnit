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

    # [GpUnit.Attributes.DataAttribute]
    note DataAttribute

    # [System.Double]
    note Time 0

    constructor {
        param(
            [string]$DisplayName,
            $TestDefinition,
            [GpUnit.Attributes.DataAttribute]$DataAttribute
        )

        Guard-ArgumentNotNull 'DisplayName' $DisplayName
        Guard-ArgumentIsPSClass 'TestDefinition' $TestDefinition 'GpUnit.TestDefinition'

        $this.DisplayName = $DisplayName
        $this.TestDefinition = $TestDefinition
        $this.Errors = New-Object System.Collections.ArrayList
    }
}
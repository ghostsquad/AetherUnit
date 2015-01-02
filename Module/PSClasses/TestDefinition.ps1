New-PSClass 'GpUnit.TestDefinition' {
    # [System.String]
    note DisplayName

    # [System.Management.Automation.ScriptBlock]
    note Definition

    # [System.String]
    note SkipReason

    # [Bool]
    note Skip $false

    # [Explicit]
    note Explicit $false

    # [Int]
    note Timeout

    # PSClass [GpUnit.Fixture]
    note TestFixture

    # [System.Collections.HashTable]
    note Traits

    # [System.Collections.ArrayList]
    note TestCustomizations

    # [Bool]
    note Theory $false

    # PSClass [GpUnit.TestCase]
    note TestCases

    constructor {
        param(
            [string]$DisplayName,
            [scriptblock]$Definition,
            $TestFixture,
            [boo]$Theory
        )

        Guard-ArgumentNotNull 'DisplayName' $DisplayName
        Guard-ArgumentNotNull 'Definition' $Definition
        Guard-ArgumentIsPSClass 'TestFixture' $TestFixture 'GpUnit.TestFixture'

        $this.DisplayName = $DisplayName
        $this.Definition = $Definition
        $this.TestFixture = $TestFixture

        $this.Traits = @{}
        $this.TestCustomizations = New-Object System.Collections.ArrayList
        $this.Theory = $Theory
        $this.TestCases = New-Object System.Collections.ArrayList

        $attributes = $Definition.Attributes
        $dataAttributes = @()

        foreach($attr in $attributes) {
            if($Theory -and $attr -is [GpUnit.DataAttribute]) {
                $testCase = (Get-PSClass 'GpUnit.TestCase').New($DisplayName, $this, $dataAttribute)
                [Void]$this.TestCases.Add($testCase)
            } elseif ($attr -is [GpUnit.SkipAttribute]) {
                $this.SkipReason = $attr.Reason
                $this.Skip = $true
            } elseif ($attr -is [GpUnit.ExplicitAttribute]) {
                $this.Explicit = $true
            } elseif ($attr -is [GpUnit.TraitAttribute) {
                $this.Traits.Add($attr.Name, $attr.Value)
            } elseif ($attr -is [GpUnit.TimeoutAttribute]) {
                $this.Timeout = $attr.Duration
            } elseif ($attr -is [GpUnit.TestCustomizationAttribute]) {
                [Void]$this.TestCustomizations.Add($attr)
            }
        }

        if(-not $Theory) {
            $testCase = (Get-PSClass 'GpUnit.TestCase').New($DisplayName, $this)
            [Void]$this.TestCases.Add($testCase)
        }
    }
}
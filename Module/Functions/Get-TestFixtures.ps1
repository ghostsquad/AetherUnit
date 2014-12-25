function Get-TestFixtures {
    [cmdletbinding(DefaultParameterSetName='Path')]
    param (
        [Parameter(Position=0, ParameterSetName='Path')]
        [string]$Path = ($PWD.Path),
        [Parameter(Position=1, ParameterSetName='Path')]
        [string[]]$Patterns,
        [Parameter(Position=1, ParameterSetName='Path')]
        [string[]]$Traits,
        [Parameter(Position=0, ParameterSetName='Names')]
        [string[]]$Names
    )

    function GetCommandAsts {
        param (
            [ScriptBlockAst]$ScriptBlockAst,
            [string[]]$CommandNames
        )

        $newClosureParams = @{
            VariableDictionary = @{
                CommandNames = $CommandNames
            }
            ScriptBlock = {
                param($ast)
                return ($ast -is [CommandAst] `
                    -and $CommandNames -contains $ast.CommandElements[0].Value)
            }
        }

        $predicate = New-Closure @newClosureParams

        return $ScriptBlockAst.FindAll($predicate, $true)
    }

    function GetParamValues {
        param (
            [CommandAst]$CommandAst,
            [Switch]$DefinitionOnly
        )

        $ParamNameAstTypeDictionary = (New-Object System.Collections.Specialized.OrderedDictionary)

        if(-not $DefinitionOnly) {
            [Void]$ParamNameAstTypeDictionary.Add('Name', ([StringConstantExpressionAst]))
        }

        [Void]$ParamNameAstTypeDictionary.Add('Definition', ([ScriptBlockExpressionAst]))

        $ParamsDictionary = @{}

        $CommandName = $CommandAst.CommandElements[0]

        for($i = 1; $i -lt $CommandAst.CommandElements.Count; $i++) {
            $element = $CommandAst.CommandElements[$i]

            # Deal with named parameters
            if($element -is [CommandParameterAst]) {
                $commandParameterName = $element.ParameterName
                $expectedType = $ParamNameAstTypeDictionary[$commandParameterName]
                if(++$i -ge $CommandAst.CommandElements.Count `
                    -or -not ($CommandAst.CommandElements[$i] -is $expectedType)) {

                    $msg = [string]::Format("Parse Error: Found -{0} {1} parameter, but next element does not exist or is not of expected type: {2}. Extent: `n{3}",
                        $element.ParameterName,
                        $CommandName,
                        $expectedType,
                        $CommandAst.Extent)
                    throw (New-Object PoshUnitException($msg))
                }

                $commandElementValue = $CommandAst.CommandElements[$i].Value

                $ParamsDictionary[$commandParameterName] = $commandElementValue
            }

            $ParamNameAstTypeDictionaryIndex = $i - 1
            if($ParamNameAstTypeDictionaryIndex -lt $ParamNameAstTypeDictionary.Count `
                -and $i -ge 1 `
                -and $element -is $ParamNameAstTypeDictionary.Item($ParamNameAstTypeDictionaryIndex) `
                -and -not ($CommandAst.CommandElements[$i - 1] -is [CommandParameterAst])) {

                $Key = $ParamNameAstTypeDictionary.GetKey($i)
                $ParamsDictionary[$Key] = $element.Value
            }
        }

        $ParamNameAstTypeDictionaryEnumerator = $ParamNameAstTypeDictionary.GetEnumerator()

        $parameterPosition = 0
        while($ParamNameAstTypeDictionaryEnumerator.MoveNext()) {
            $Key = $ParamNameAstTypeDictionaryEnumerator.Current.Name
            if(-not $ParamsDictionary.ContainsKey($Key) -or $ParamsDictionary[$Key] -eq $null) {
                $msg = [string]::Format("Parse Error: Command [{0}] does not have necessary parameter [{1}] named or at position {2}. Extent: `n{3}",
                    $CommandName,
                    $Key,
                    $parameterPosition,
                    $CommandAst.Extent)
                throw (New-Object PoshUnitException($msg))
            }

            $parameterPosition++
        }

        return $ParamsDictionary
    }

    $fixtures = new-object system.collections.arraylist

    $files = [System.IO.Directory]::EnumerateFiles($Path, "*Tests.ps1", [System.IO.SearchOption]::AllDirectories)
    $filesEnumerator = $files.GetEnumerator()

    while($filesEnumerator.MoveNext()) {
        $parseErrors = $null
        $testFileAst = [System.Management.Automation.Language.Parser]::ParseFile($filesEnumerator.Current, [ref]$null, [ref]$parseErrors)
        if ($parseErrors.Length -gt 0) {
            $msg = "Parse Errors: {0}" -f ([string]::Join("`n", $parseErrors))
            throw (New-Object PoshUnitException($msg))
        }

        $fixtureAsts = GetCommandAsts $testFileAst 'Fixture'

        foreach($fixtureAst in $fixtureAsts) {
            $fixtureName = $fixtureAst.CommandElements[0].Value
            $fixtureParams = GetParamValues $fixtureAst

            $parseErrors = $null
            $Tokens = $null
            $fixtureDefinitionAst = [System.Management.Automation.Language.Parser]::ParseInput($fixtureParams['Definition'], [ref] $Tokens, [ref] $parseErrors)
            if ($parseErrors.Length -gt 0) {
                $msg = "Parse Errors: {0}" -f ([string]::Join("`n", $parseErrors))
                throw (New-Object PoshUnitException($msg))
            }

            $fixtureMeta = [PSClassContainer]::ClassDefinitions['PoshUnit.FixtureMeta'].New($fixtureName)

            $setupAst = GetCommandAsts $fixtureDefinitionAst 'Setup'
            $setupParams = GetParamValues $setupAst -DefinitionOnly
            $fixtureMeta.Setup = $setupParams['Definition']

            $teardownAst = GetCommandAsts $fixtureDefinitionAst 'Teardown'
            $teardownParams = GetParamValues $teardownAst -DefinitionOnly
            $fixtureMeta.Teardown = $teardownParams['Definition']

            $useDataFixtureAst = GetCommandAsts $fixtureDefinitionAst 'UseDataFixture'
            $useDataFixtureParams = GetParamValues $useDataFixtureAst -DefinitionOnly
            $fixtureMeta.LazyDataObject = New-Lazy { $useDataFixtureParams['Definition'] }

            $factsAndTheoriesAsts = GetCommandAsts $fixtureDefinitionAst @('Fact', 'Theory')
            foreach($testAst in $factsAndTheoriesAsts) {
                $testParams = GetParamValues $testAst
                $testCase = [PSClassContainer]::ClassDefinitions['PoshUnit.TestCase'].New($testParams['Name'], $testParams['Definition'], $fixtureMeta)
                [Void]$fixtureMeta.Tests.Add($testCase)
            }

            [Void]$fixtures.Add($fixtureMeta)
        }
    }

    return ,$fixtures
}
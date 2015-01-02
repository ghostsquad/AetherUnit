New-PSClass 'GpUnit.GpUnitFixtureDiscoverer' -Inherit 'GpUnit.FixtureDiscovererBase' {

    #region Singleton Code
    note -static '_instance'

    property -static 'Default' {
        if ($this._instance -eq $null) {
            $this._instance = (Get-PSClass 'GpUnit.GpUnitFixtureDiscoverer').New()
        }

        return $this._instance
    }
    #endregion Singleton Code

    method -override 'GetFixtures' {
        param (
            [string]$PathRoot
        )

        $fixtures = new-object system.collections.arraylist

        $files = [System.IO.Directory]::EnumerateFiles($PathRoot, "*Tests.ps1", [System.IO.SearchOption]::AllDirectories)
        $filesEnumerator = $files.GetEnumerator()

        while($filesEnumerator.MoveNext()) {
            $parseErrors = $null
            $fixtureFilePath = $filesEnumerator.Current
            $testFileAst = [System.Management.Automation.Language.Parser]::ParseFile($fixtureFilePath, [ref]$null, [ref]$parseErrors)
            if ($parseErrors.Length -gt 0) {
                $msg = "Parse Errors: {0}" -f ([string]::Join("`n", $parseErrors))
                throw (New-Object GpUnitException($msg))
            }

            $fixtureAsts = $this._GetCommandAsts($testFileAst, 'Fixture')

            $nameAndDefinitionMapping = $this._NewParamNameAstTypeDictionary($true, $true)
            $definitionOnlyMapping = $this._NewParamNameAstTypeDictionary($false, $true)

            foreach($fixtureAst in $fixtureAsts) {
                $fixtureName = $fixtureAst.CommandElements[0].Value
                $fixtureParams = $this._GetCommandParameterValues $fixtureAst

                $parseErrors = $null
                $Tokens = $null
                $fixtureDefinitionAst = [System.Management.Automation.Language.Parser]::ParseInput($fixtureParams['Definition'], [ref] $Tokens, [ref] $parseErrors)
                if ($parseErrors.Length -gt 0) {
                    $msg = "Parse Errors: {0}" -f ([string]::Join("`n", $parseErrors))
                    throw (New-Object GpUnitException($msg))
                }

                $testFixture = (Get-PSClass 'gpUnit.TestFixture').New($fixtureName, $fixtureFilePath)

                #region FixtureAsts
                $setupAsts = $this._GetCommandAsts($fixtureDefinitionAst, @('Setup','Constructor'))
                if($setupAsts.Count -gt 1) {
                    $msg = "Parse Errors: Found multiple setup/constructor methods (which are synonymous). Only 1 is allowed."
                    throw (New-Object GpUnitException($msg)
                } elseif($setupAsts.Count -eq 1) {
                    $setupParams = $this._GetCommandParameterValues($setupAsts[0], $definitionOnlyMapping)
                    $testFixture.Teardown = $setupParams['Definition']
                }

                $teardownAsts = $this._GetCommandAsts($fixtureDefinitionAst, @('Teardown','Dispose'))
                if($teardownAsts.Count -gt 1) {
                    $msg = "Parse Errors: Found multiple teardown/dispose methods (which are synonymous). Only 1 is allowed."
                    throw (New-Object GpUnitException($msg))
                } elseif($teardownAsts.Count -eq 1) {
                    $teardownParams = $this._GetCommandParameterValues($teardownAsts[0], $definitionOnlyMapping)
                    $testFixture.Teardown = $teardownParams['Definition']
                }

                $useDataFixtureAsts = $this._GetCommandAsts($fixtureDefinitionAst, 'UseDataFixture')
                if($useDataFixtureAsts.Count -gt 1) {
                    $msg = "Parse Errors: Found multiple UseDataFixture methods. Only 1 is allowed."
                    throw (New-Object GpUnitException($msg))
                } elseif($useDataFixtureAsts.Count -eq 1) {
                    $useDataFixtureParams = $this._GetCommandParameterValues($useDataFixtureAsts[0], $definitionOnlyMapping)
                    $testFixture.LazyDataObject = New-Lazy { $useDataFixtureParams['Definition'] }
                }

                $factsAsts = $this._GetCommandAsts($fixtureDefinitionAst, 'Fact')
                foreach($ast in $factsAsts) {
                    $testParams = $this._GetCommandParameterValues($ast, $nameAndDefinitionMapping)
                    $testCase = (Get-PSClass 'PondUnit.TestCase').New($testParams['Name'], $testParams['Definition'], $testFixture)
                    [Void]$testFixture.Tests.Add($testCase)
                }

                $theriesAsts = $this._GetCommandAsts($fixtureDefinitionAst, 'Theory')
                foreach($ast in $theriesAsts) {
                    $testParams = $this._GetCommandParameterValues($ast, $nameAndDefinitionMapping)
                    $testCase = (Get-PSClass 'PondUnit.TestCase').New($testParams['Name'], $testParams['Definition'], $testFixture)
                    [Void]$testFixture.Tests.Add($testCase)
                }
                #endregion FixtureAsts

                #region PSClassNatives
                # The following code is brittle, and requires intimate knowledge of the PSClass implementation
                # for the internal methods (note, property, & method) in order to make this seamless.
                # This should be revisited
                # TODO: Support TestFixture Inheritance
                $noteAsts = $this._GetCommandAsts($fixtureDefinitionAst, 'Note')
                foreach($ast in $noteAsts) {
                    $noteMapping = $this._NewParamNameAstTypeDictionary($true, $false)
                    $noteMapping.Add('Value', [CommandElementAst])
                    $noteParams = $this._GetCommandParameterValues($ast, $noteMapping)
                    [Void]$testFixture.Notes.Add($noteParams)
                }

                $propertyAsts = $this._GetCommandAsts($fixtureDefinitionAst, 'Property')
                foreach($ast in $propertyAsts) {
                    $propertyMapping = $this._NewParamNameAstTypeDictionary($true, $false)
                    $propertyMapping.Add('Get', [ScriptBlockExpressionAst])
                    $propertyMapping.Add('Set', [ScriptBlockExpressionAst])
                    $propertyParams = $this._GetCommandParameterValues($ast, $propertyMapping)
                    [Void]$testFixture.Properties.Add($propertyParams)
                }

                $methodAsts = $this._GetCommandAsts($fixtureDefinitionAst, 'Method')
                foreach($ast in $methodAsts) {
                    $methodMapping = $this._NewParamNameAstTypeDictionary($true, $false)
                    $methodMapping.Add('Script', [ScriptBlockExpressionAst])
                    $methodParams = $this._GetCommandParameterValues($ast, $methodMapping)
                    [Void]$testFixture.Methods.Add($methodParams)
                }
                #endregion PSClassNatives

                [Void]$fixtures.Add($testFixture)
            }
        }

        return ,$fixtures
    }

    method '_GetCommandAsts' {
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
                    -and $CommandNames -Contains $ast.CommandElements[0].Value)
            }
        }

        $predicate = New-Closure @newClosureParams

        return ,$ScriptBlockAst.FindAll($predicate, $true)
    }

    method '_GetCommandParameterValues' {
        param (
            [CommandAst]$CommandAst,
            [System.Collections.Specialized.OrderedDictionary]$ParamNameAstTypeDictionary
        )

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
                    throw (New-Object PondUnitException($msg))
                }

                $commandElementValue = $CommandAst.CommandElements[$i].Value

                $ParamsDictionary[$commandParameterName] = $commandElementValue
            }

            $ParamNameAstTypeDictionaryIndex = $i - 1
            if($ParamNameAstTypeDictionaryIndex -lt $ParamNameAstTypeDictionary.Count `
                -and $i -ge 1 `
                -and $element -is $ParamNameAstTypeDictionary.Item($ParamNameAstTypeDictionaryIndex) `
                -and -not ($CommandAst.CommandElements[$i - 1] -is [CommandParameterAst])) {

                $Key = ([string[]]$ParamNameAstTypeDictionary.Keys)[$ParamNameAstTypeDictionaryIndex]
                if($element -is [StringConstantExpressionAst]) {
                    $ParamsDictionary[$Key] = $element.Value
                } else {
                    $ParamsDictionary[$Key] = [scriptblock]::Create($element.ToString())
                }
            }
        }

        $ParamNameAstTypeDictionaryEnumerator = $ParamNameAstTypeDictionary.GetEnumerator()

        for($i = 0; $i -lt $ParamNameAstTypeDictionary.Count; $i++) {
            $Key = ([string[]]$ParamNameAstTypeDictionary.Keys)[$i]
            if(-not $ParamsDictionary.ContainsKey($Key) -or $ParamsDictionary[$Key] -eq $null) {
                $msg = [string]::Format("Parse Error: Command [{0}] does not have necessary parameter [{1}] named or at position {2}. Extent: `n{3}",
                    $CommandName,
                    $Key,
                    $i,
                    $CommandAst.Extent)
                throw (New-Object PondUnitException($msg))
            }
        }

        return $ParamsDictionary
    }

    method '_NewParamNameAstTypeDictionary' {
        param (
            [bool]$includeName,
            [bool]$includeDefinition
        )

        $ParamNameAstTypeDictionary = New-Object System.Collections.Specialized.OrderedDictionary

        if($includeName) {
            $ParamNameAstTypeDictionary.Add('Name', [StringConstantExpressionAst])
        }

        if($includeDefinition) {
            $ParamNameAstTypeDictionary.Add('Definition', [ScriptBlockExpressionAst])
        }

        return $ParamNameAstTypeDictionary
    }
}
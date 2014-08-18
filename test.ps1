$codeText = gc D:\Dev\PoshUnit\Test\PoshUnit.Tests.Example.ps1
$parseErrors = $null
$tokens = [System.Management.Automation.PSParser]::Tokenize($CodeText, [ref] $parseErrors)
$tokens | ft -autosize

function Get-IndexOfTokens {
	[cmdletbinding()]
	param (
		[Parameter(ValueFromPipeline)]
		[System.Management.Automation.PSToken[]] $Tokens,
		[System.Management.Automation.PSTokenType] $TokenType,
		[String] $Content,
		[Int] $StartIndex = 0
	)
	
	process {
		$found = $false
		for($i = $StartIndex; $i -lt $Tokens.Count; $i++){
			$token = $Tokens[$i]
			if($token.Type -eq $TokenType -and $token.Content -eq $Content) {
				$found = $true
				Write-Output $i
			}
		}
		
		if($found -eq $false) {
			throw "unable to find command and content requested!"
		}
	}
}

function Get-GroupCloseTokenIndex {
	[cmdletbinding()]
	param (
		[Parameter(ValueFromPipeline)]
		[System.Management.Automation.PSToken[]] $Tokens,
		[int] $GroupStartTokenIndex,
	)
	
	$groupLevel = 0;
	
	for($i = $GroupStartTokenIndex + 1; $i -lt $Tokens.Count; $i++) {
		switch ($Tokens[$i].Type) {
            ([System.Management.Automation.PSTokenType]::GroupStart) {
                $groupLevel++
                break
            }
			
			([System.Management.Automation.PSTokenType]::GroupEnd) {
                $groupLevel--
                if ($groupLevel -le 0) {
                    return $i
                }
                break
            }
		}
	}
	
	throw "unable to find group close before encountered end of tokens!"
}

function Get-GroupStartTokenIndex {
	[cmdletbinding()]
	param (
		[Parameter(ValueFromPipeline)]
		[System.Management.Automation.PSToken[]] $Tokens,
		[int] $OriginalTokenIndex,
		[string]$GroupStartType = "{"
	)
	
	$newIndex = $OriginalTokenIndex
	
	do {		
		$newIndex++
		$token = $Tokens[$newIndex]
		if($token.Type -eq "GroupStart" -and $token.Content -eq $GroupStartType) {
			return $newIndex;
		}
	}
	while($token.Type -ne "NewLine" -and $token.Type -ne "StatementSeparator")
	
	throw "unable to find group start before encountered end of tokens, statement separator or newline!"
}

$fixtureIndexes = $tokens | Get-IndexOfTokens -TokenType "Command" -Content "New-TestFixture"
foreach($testFixtureTokenIndex in $fixtureIndexes) {
	for($i = $testFixtureTokenIndex - 1; $i -gt 0; $i--){
		$token = $tokens[$i]
		if($token.Type -eq "Variable"){
			$fixtureName -eq $token.Content
		}
	}
}
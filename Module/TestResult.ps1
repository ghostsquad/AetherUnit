# We are wrapping this call in a function in order to
# 1. Make the parameters easier to read (via splatting)
# 2. To avoid cluttering the module scope with the splat variable
function Create-TestResultEnum {
    $TestResultEnumParams = @{
        ModuleBuilder = $PondUnitModuleBuilder
        Name = 'PondUnit.TestResult'
        Members = @{
            NotRun = 0
            Success = 1
            Failed = 2
            Skipped = 3
            InProgress = 4
        }
    }

    New-Enum @TestResultEnumParams
}

Create-TestResultEnum
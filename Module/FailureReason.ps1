# We are wrapping this call in a function in order to
# 1. Make the parameters easier to read (via splatting)
# 2. To avoid cluttering the module scope with the splat variable
function Create-FailureReasonEnum {
    $FailureReasonEnumParams = @{
        ModuleBuilder = $PondUnitModuleBuilder
        Name = 'PondUnit.FailureReason'
        Members = @{
            None = 0
            InitializationException = 1
            TestException = 2
            TeardownException = 4
        }
        Flags = $true
    }

    New-Enum @FailureReasonEnumParams
}

Create-FailureReasonEnum
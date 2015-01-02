New-PSClass 'GpUnit.GpUnitParallelTestRunner' -Inherit 'GpUnit.TestRunnerBase' {
    note _threadCount 5
}
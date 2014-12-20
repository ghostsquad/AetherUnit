New-PSClass 'PoshUnit.PoshUnitParallelTestRunner' -Inherit 'PoshUnit.TestRunnerBase' {
    note _threadCount 5

    method -override RunTests {

    }
}
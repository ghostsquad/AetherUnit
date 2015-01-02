New-PSClass 'GpUnit.GpUnitTestSessionFactory' -Inherit 'GpUnit.TestSessionFactoryBase' {
    method -override CreateTestSession {
        param(
            $Runner
        )

        Guard-ArgumentIsPSClass 'Runner' $Runner 'GpUnit.TestRunnerBase'
    }
}
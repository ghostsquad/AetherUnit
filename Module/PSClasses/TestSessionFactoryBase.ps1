New-PSClass 'GpUnit.TestSessionFactoryBase' {
    method CreateTestSession {
        param(
            $Runner
        )

        throw (New-Object System.NotImplementedException)
    }
}
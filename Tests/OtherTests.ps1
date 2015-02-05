Fixture "OtherTests" {
    Fact 'PassingTest' {
        Assert-Equal $true $true
    }

    Fact 'FailingTest' {
        #write-host 'running failing test'
        #Assert-True $false
        throw 'AHH'
    }
}

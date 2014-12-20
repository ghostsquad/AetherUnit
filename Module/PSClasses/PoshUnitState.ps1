New-PSClass 'PoshUnit.PoshUnitState' {
    note '_currentSession'
    property 'CurrentSession' -get {
        return $this._currentSession
    } -set {
        param($value)
        Guard-ObjectIsPSClass $value 'PoshUnit.TestSession'
        $this._currentSession = $value
    }
}
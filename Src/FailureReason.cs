namespace GpUnit
{
    using System;

    [Flags]
    public enum FailureReason
    {
        None = 0,
        SetupException = 1,
        TestException = 2,
        TeardownException = 4,
        TestCustomizationException = 8
    }
}

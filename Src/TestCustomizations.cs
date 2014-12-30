namespace PondUnit
{
    using System.Collections.Generic;
    using System.Management.Automation;

    public static class TestCustomizations
    {
        public static readonly IDictionary<string, ScriptBlock> Custumizations = new Dictionary<string, ScriptBlock>();
    }
}

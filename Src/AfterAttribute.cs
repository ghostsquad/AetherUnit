namespace PoshUnit {
    using System.Management.Automation;

    public class AfterAttribute : TestCustomizationAttribute {
        #region Constructors and Destructors

        public AfterAttribute(ScriptBlock command, params object[] callValues)
            : base(command, callValues) {
        }

        #endregion
    }
}
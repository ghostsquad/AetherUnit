namespace PoshUnit {
    using System.Management.Automation;

    public class BeforeAttribute : TestCustomizationAttribute {
        #region Constructors and Destructors

        public BeforeAttribute(ScriptBlock command, params object[] callValues)
            : base(command, callValues) {
        }

        #endregion
    }
}
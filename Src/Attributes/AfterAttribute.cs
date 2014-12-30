namespace PondUnit.Attributes {
    using System.Management.Automation;

    public class AfterAttribute : TestCustomizationAttribute {
        #region Constructors and Destructors

        public AfterAttribute(ScriptBlock command, params object[] callValues)
            : base(command, callValues) {
        }

        public AfterAttribute(string customizationName, params object[] callValues)
            : base(customizationName, callValues) {
        }

        #endregion
    }
}
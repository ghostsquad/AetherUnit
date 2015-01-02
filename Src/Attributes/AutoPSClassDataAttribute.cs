namespace GpUnit.Attributes {
    public class AutoPSClassDataAttribute : DataAttribute {
        #region Constructors and Destructors

        public AutoPSClassDataAttribute(params string[] classNames) {
            this.Values = classNames;
        }

        #endregion
    }
}
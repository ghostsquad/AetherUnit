namespace PondUnit.Attributes {
    using System;

    public class SkipAttribute : Attribute {
        #region Constructors and Destructors

        public SkipAttribute(string reason) {
            this.Reason = reason;
        }

        #endregion

        #region Public Properties

        public string Reason { get; set; }

        #endregion
    }
}
namespace PoshUnit {
    using System;

    public class DataAttribute : Attribute {
        #region Public Properties

        public virtual object[] Values { get; set; }

        #endregion
    }
}

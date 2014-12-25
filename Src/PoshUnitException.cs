namespace PoshUnit {
    using System;
    using System.Management.Automation;

    public class PoshUnitException : Exception {
        #region Constructors and Destructors

        public PoshUnitException(string message)
            : base(message) {
        }

        public PoshUnitException(string message, ErrorRecord errorRecord)
            : base(message) {
            this.ErrorRecord = errorRecord;
        }

        public PoshUnitException(string message, Exception inner)
            : base(message, inner) {
        }

        #endregion

        #region Public Properties

        public ErrorRecord ErrorRecord { get; private set; }

        #endregion
    }
}
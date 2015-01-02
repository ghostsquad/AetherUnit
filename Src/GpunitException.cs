namespace GpUnit {
    using System;
    using System.Management.Automation;

    public class GpUnitException : Exception {
        #region Constructors and Destructors

        public GpUnitException(string message)
            : base(message) {
        }

        public GpUnitException(string message, ErrorRecord errorRecord)
            : base(message) {
            this.ErrorRecord = errorRecord;
        }

        public GpUnitException(string message, Exception inner)
            : base(message, inner) {
        }

        #endregion

        #region Public Properties

        public ErrorRecord ErrorRecord { get; private set; }

        #endregion
    }
}
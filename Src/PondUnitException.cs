namespace PondUnit {
    using System;
    using System.Management.Automation;

    public class PondUnitException : Exception {
        #region Constructors and Destructors

        public PondUnitException(string message)
            : base(message) {
        }

        public PondUnitException(string message, ErrorRecord errorRecord)
            : base(message) {
            this.ErrorRecord = errorRecord;
        }

        public PondUnitException(string message, Exception inner)
            : base(message, inner) {
        }

        #endregion

        #region Public Properties

        public ErrorRecord ErrorRecord { get; private set; }

        #endregion
    }
}
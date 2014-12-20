namespace PoshUnit {
    using System;
    using System.Management.Automation;

    public class FixtureInitializationException : Exception {
        #region Constructors and Destructors

        public FixtureInitializationException(string message)
            : base(message) {
        }

        public FixtureInitializationException(string message, ErrorRecord errorRecord)
            : base(message) {
            this.ErrorRecord = errorRecord;
        }

        public FixtureInitializationException(string message, Exception inner)
            : base(message, inner) {
        }

        #endregion

        #region Public Properties

        public ErrorRecord ErrorRecord { get; private set; }

        #endregion
    }
}
namespace PondUnit.Attributes {
    using System;

    public class TimeoutAttribute : Attribute {
        #region Constructors and Destructors

        public TimeoutAttribute(int duration) {
            this.Duration = duration;
        }

        #endregion

        #region Public Properties

        public int Duration { get; set; }

        #endregion
    }
}
namespace PondUnit.Attributes {
    public class VariableDataSourceAttribute : DataAttribute {
        #region Constructors and Destructors

        public VariableDataSourceAttribute(object source) {
            this.Source = source;
        }

        #endregion

        #region Public Properties

        public object Source { get; set; }

        #endregion
    }
}
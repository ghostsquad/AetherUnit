namespace PondUnit {
    using System.Collections;

    public interface IPondUnitState {
        #region Public Properties

        object CurrentSession { get; set; }

        ArrayList Sessions { get; }

        #endregion
    }
}
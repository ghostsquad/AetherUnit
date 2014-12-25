namespace PoshUnit {
    using System.Collections;

    public interface IPoshUnitState {
        #region Public Properties

        object CurrentSession { get; set; }

        SortedList Sessions { get; }

        #endregion
    }
}
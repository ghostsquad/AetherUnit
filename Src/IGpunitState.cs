namespace GpUnit {
    using System.Collections;

    public interface IGpunitState {
        #region Public Properties

        object CurrentSession { get; set; }

        ArrayList Sessions { get; }

        #endregion
    }
}
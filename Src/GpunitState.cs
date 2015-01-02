namespace GpUnit {
    using System.Collections;

    public class GpUnitState : IGpunitState {
        #region Static Fields

        private static GpUnitState instance;

        #endregion

        #region Constructors and Destructors

        private GpUnitState()
        {
            this.Sessions = new ArrayList();
        }

        #endregion

        #region Public Properties

        public static GpUnitState Default
        {
            get {
                if (instance == null) {
                    instance = new GpUnitState();
                }

                return instance;
            }
        }

        #endregion

        public object CurrentSession { get; set; }

        public ArrayList Sessions { get; private set; }
    }
}
namespace PondUnit {
    using System.Collections;

    public class PondUnitState : IPondUnitState {
        #region Static Fields

        private static PondUnitState instance;

        #endregion

        #region Constructors and Destructors

        private PondUnitState() {
            this.Sessions = new ArrayList();
        }

        #endregion

        #region Public Properties

        public static PondUnitState Default {
            get {
                if (instance == null) {
                    instance = new PondUnitState();
                }

                return instance;
            }
        }

        #endregion

        public object CurrentSession { get; set; }

        public ArrayList Sessions { get; private set; }
    }
}
namespace PoshUnit {
    using System.Collections;

    public class PoshUnitState : IPoshUnitState {
        #region Static Fields

        private static PoshUnitState instance;

        #endregion

        #region Constructors and Destructors

        private PoshUnitState() {
            this.Sessions = new SortedList();
        }

        #endregion

        #region Public Properties

        public static PoshUnitState Default {
            get {
                if (instance == null) {
                    instance = new PoshUnitState();
                }

                return instance;
            }
        }

        #endregion

        public object CurrentSession { get; set; }

        public SortedList Sessions { get; private set; }
    }
}
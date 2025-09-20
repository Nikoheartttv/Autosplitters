using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Livesplit.SWORN.Memory
{
    public class Watcher<T>
    {

        private T _old;
        private T _current;

        public T Old { get { return _old; } }
        public T Current
        {
            get { return _current; }
            set
            {
                _old = _current;
                _current = value;
            }
        }

        public bool Changed
        {
            get
            {
                if (Current == null) return Old != null;
                return !Current.Equals(Old);
            }
        }

    }
}

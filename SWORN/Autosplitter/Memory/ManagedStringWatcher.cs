using LiveSplit.ComponentUtil;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using static LiveSplit.ComponentUtil.MemoryWatcher;

namespace Livesplit.SWORN.Memory
{
    public class ManagedStringWatcher : ManagedDataWatcher
    {

        public static class Offsets
        {
            public const int Size = 0x10;
            public const int firstChar = 0x14;
        }

        public new string Current
        {
            get => (string)base.Current;
            set => base.Current = value;
        }
        public new string Old
        {
            get => (string)base.Old;
            set => base.Old = value;
        }

        public delegate void StringChangedEventHandler(string old, string current);
        public event StringChangedEventHandler OnChanged;

        public ManagedStringWatcher(DeepPointer pointer) : base(pointer) { }

        public ManagedStringWatcher(IntPtr address) : base(address) { }

        public override void Reset()
        {
            base.Current = null;
            base.Old = null;
            InitialUpdate = false;
        }

        public override bool Update(Process process)
        {
            Changed = false;

            if (!Enabled) return false;
            if (!CheckInterval()) return false;

            string str = default;
            bool success = false;

            switch (AddrType)
            {
                case AddressType.Absolute:
                    success = process.ReadManagedString(Address, out str);
                    break;

                case AddressType.DeepPointer:
                    success = DeepPtr.DerefManagedString(process, out str);
                    break;
            }

            if (success)
            {
                base.Old = base.Current;
                base.Current = str;
            }
            else
            {
                if (FailAction == ReadFailAction.DontUpdate) return false;

                base.Old = base.Current;
                base.Current = str;
            }

            if (!InitialUpdate)
            {
                InitialUpdate = true;
                return false;
            }

            if (!Current.Equals(Old))
            {
                OnChanged?.Invoke(Old, Current);
                Changed = true;
                return true;
            }

            return false;
        }
    }
}

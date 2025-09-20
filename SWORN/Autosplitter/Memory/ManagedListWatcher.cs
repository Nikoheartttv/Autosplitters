using LiveSplit.ComponentUtil;
using System;
using System.Collections.Generic;
using System.Diagnostics;

namespace Livesplit.SWORN.Memory
{
    public class ManagedListWatcher<T> : ManagedDataWatcher where T : unmanaged
    {

        public static class Offsets
        {
            public const int Size = 0x18;
            public const int Items = 0x10;
            public const int Data = 0x20;
        }

        public new List<T> Current
        {
            get => (List<T>)base.Current;
            set => base.Current = value;
        }
        public new List<T> Old
        {
            get => (List<T>)base.Old;
            set => base.Old = value;
        }

        public delegate void ListChangedEventHandler(List<T> old, List<T> current);
        public event ListChangedEventHandler OnInitialUpdateCompleted;
        public event ListChangedEventHandler OnChanged;

        public bool UpdateOnlyOnSizeChange { get; set; } = false;

        public ManagedListWatcher(DeepPointer pointer) : base(pointer) { }

        public ManagedListWatcher(IntPtr address) : base(address) { }

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

            List<T> list = default;
            bool success = false;

            if (UpdateOnlyOnSizeChange && Current != null && ReadSize(process, out int size) && size == Current.Count) return false;

            switch (AddrType)
            {
                case AddressType.Absolute:
                    success = process.ReadList<T>(Address, out list);
                    break;

                case AddressType.DeepPointer:
                    success = DeepPtr.DerefList<T>(process, out list);
                    break;
            }

            if (success)
            {
                base.Old = base.Current;
                base.Current = list;
            }
            else
            {
                if (FailAction == ReadFailAction.DontUpdate) return false;

                base.Old = base.Current;
                base.Current = list;
            }

            if (!InitialUpdate)
            {
                InitialUpdate = true;
                OnInitialUpdateCompleted?.Invoke(Old, Current);
                return false;
            }

            if (!ListCompare(Current, Old))
            {
                OnChanged?.Invoke(Old, Current);
                Changed = true;
                return true;
            }

            return false;
        }

        private bool ReadSize(Process process, out int size)
        {
            size = default;
            IntPtr listPointer = default;
            switch (AddrType)
            {
                case AddressType.Absolute:
                    listPointer = Address;
                    break;

                case AddressType.DeepPointer:
                    DeepPtr.DerefOffsets(process, out listPointer);
                    break;
            }

            if (!process.ReadPointer(listPointer, out IntPtr listBase)) return false;
            if (listBase == IntPtr.Zero) return false;
            if (!process.ReadValue<int>(listBase + Offsets.Size, out size)) return false;

            return true;
        }

        private int ReadSize(Process process)
        {
            ReadSize(process, out int size);
            return size;
        }

        private bool ListCompare(List<T> list1, List<T> list2)
        {
            if (list1 == null && list2 == null) return false;
            if (list1 != list2) return false;

            if (list1.Count != list2.Count) return false;
            for (var i = 0; i < list1.Count; i++)
            {
                if (!list1[i].Equals(list2[i])) return false;
            }

            return true;
        }
    }
}

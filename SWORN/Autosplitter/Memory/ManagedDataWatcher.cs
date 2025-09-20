using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LiveSplit.ComponentUtil;

namespace Livesplit.SWORN.Memory
{
    public abstract class ManagedDataWatcher : MemoryWatcher
    {

        public ManagedDataWatcher(DeepPointer pointer) : base(pointer) { }

        public ManagedDataWatcher(IntPtr address) : base(address) { }

        public abstract override void Reset();

        public abstract override bool Update(Process process);

        protected bool GetAddressAtOffset(Process process, int offset, out IntPtr address, bool deref = true)
        {
            address = IntPtr.Zero;
            IntPtr baseAddress = IntPtr.Zero;

            switch (AddrType)
            {
                case AddressType.DeepPointer:
                    if (DeepPtr.DerefOffsets(process, out IntPtr addr))
                    {
                        if (deref) process.ReadPointer(addr, out baseAddress);
                        else baseAddress = addr;
                    }
                    break;

                case AddressType.Absolute:
                    if (deref) process.ReadPointer(Address, out baseAddress);
                    else baseAddress = Address;
                    break;
            }

            if (baseAddress == IntPtr.Zero) return false;

            address = baseAddress + offset;
            return true;
        }

        protected bool GetValueAtOffset<T>(Process process, int offset, out T value, bool deref = true) where T : unmanaged
        {
            value = default;

            if (GetAddressAtOffset(process, offset, out IntPtr address, deref))
            {
                return process.ReadValue<T>(address, out value);
            }

            return false;
        }

    }
}

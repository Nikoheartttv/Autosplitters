using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;
using LiveSplit.ComponentUtil;

namespace Livesplit.SWORN.Memory
{
    public static class ProcessExtensions
    {
        public static readonly byte PointerSize = 0x8;

        public static bool ReadManagedString(this Process process, IntPtr address, out string str)
        {
            str = default;
            const int offsetSize = 0x10;
            const int offsetFirstChar = 0x14;

            if (!process.ReadPointer(address, out IntPtr stringBase)) return false;
            if (stringBase == IntPtr.Zero) return false;
            if (!process.ReadValue<int>(stringBase + offsetSize, out int size)) return false;
            if (!process.ReadString(stringBase + offsetFirstChar, ReadStringType.UTF16, size * 2, out str)) return false;

            return true;
        }

        public static string ReadManagedString(this Process process, IntPtr address)
        {
            if (process.ReadManagedString(address, out string str)) return str;
            return default;
        }

        public static unsafe bool ReadList<T>(this Process process, IntPtr address, out List<T> list) where T : unmanaged
        {
            list = default;
            const int offsetSize = 0x18;
            const int offsetItems = 0x10;
            const int offsetData = 0x20;

            if (!process.ReadPointer(address, out IntPtr listBase)) return false;
            if (listBase == IntPtr.Zero) return false;
            if (!process.ReadValue<int>(listBase + offsetSize, out int size)) return false;
            if (!process.ReadPointer(listBase + offsetItems, out IntPtr arrayBase)) return false;

            T[] buffer = new T[size];
            for (var i = 0; i < size; i++)
            {
                process.ReadValue<T>(arrayBase + offsetData + sizeof(T) * i, out buffer[i]);
            }

            list = new List<T>(buffer);
            return true;
        }

        public static List<T> ReadList<T>(this Process process, IntPtr address) where T : unmanaged
        {
            process.ReadList<T>(address, out List<T> list);
            return list;
        }

        public static bool ReadListString(this Process process, IntPtr address, out List<string> list)
        {
            list = default;
            const int offsetSize = 0x18;
            const int offsetItems = 0x10;
            const int offsetData = 0x20;

            if (!process.ReadPointer(address, out IntPtr listBase)) return false;
            if (listBase == IntPtr.Zero) return false;
            if (!process.ReadValue<int>(listBase + offsetSize, out int size)) return false;
            if (!process.ReadPointer(listBase + offsetItems, out IntPtr arrayBase)) return false;

            string[] buffer = new string[size];
            for (var i = 0; i < size; i++)
            {
                process.ReadManagedString(arrayBase + offsetData + PointerSize * i, out buffer[i]);
            }

            list = new List<string>(buffer);
            return true;
        }

        public static List<string> ReadListString(this Process process, IntPtr address)
        {
            process.ReadListString(address, out List<string> list);
            return list;
        }

    }
}

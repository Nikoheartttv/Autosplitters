using Livesplit.SWORN.Memory;
using LiveSplit.ComponentUtil;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Livesplit.SWORN.Memory
{
    public static class DeepPointerExtensions
    {

        public static bool DerefManagedString(this DeepPointer pointer, Process process, out string str)
        {
            str = default;

            if (!pointer.DerefOffsets(process, out IntPtr stringPointer)) return false;
            if (!process.ReadManagedString(stringPointer, out str)) return false;

            return true;
        }

        public static string DerefManagedString(this DeepPointer pointer, Process process)
        {
            pointer.DerefManagedString(process, out string str);
            return str;
        }

        public static bool DerefList<T>(this DeepPointer pointer, Process process, out List<T> list) where T : unmanaged
        {
            list = default;

            if (!pointer.DerefOffsets(process, out IntPtr listPointer)) return false;
            if (!process.ReadList<T>(listPointer, out list)) return false;

            return true;
        }

        public static List<T> DerefList<T>(this DeepPointer pointer, Process process) where T : unmanaged
        {
            pointer.DerefList<T>(process, out List<T> list);
            return list;
        }

        public static bool DerefListString(this DeepPointer pointer, Process process, out List<string> list)
        {
            list = default;

            if (!pointer.DerefOffsets(process, out IntPtr listPointer)) return false;
            if (!process.ReadListString(listPointer, out list)) return false;

            return true;
        }

        public static List<string> DerefListString(this DeepPointer pointer, Process process)
        {
            pointer.DerefListString(process, out List<string> list);
            return list;
        }

    }
}

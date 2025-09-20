using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LiveSplit.ComponentUtil;
using Livesplit.SWORN.Memory;

namespace Livesplit.SWORN.IL2CPP
{
    public class IL2CPPField
    {
        public static class Offsets
        {
            public static int Name = 0;
            public static int Offset = 0x18;
            public static int StructSize = 0x20;
        }

        public IntPtr Address { get; set; }
        public string Name { get => GetName(); }
        public int? Offset { get => GetOffset(); }

        public IL2CPPField(IntPtr address)
        {
            Address = address;
        }

        private string GetName()
        {
            if (!new DeepPointer(Address + Offsets.Name, 0).DerefString(Game.Process, 256, out string value)) return null;
            return value;
        }

        private int? GetOffset()
        {
            if (!Game.Process.ReadValue<int>(Address + Offsets.Offset, out int value)) return null;
            return value;
        }


    }
}

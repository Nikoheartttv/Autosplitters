using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Livesplit.SWORN.Memory;
using LiveSplit.ComponentUtil;

namespace Livesplit.SWORN.IL2CPP
{
    public class IL2CPPImage
    {
        public static class Offsets
        {
            public static int TypeCount { get => 0x18; }
            public static int MetadataHandle { get => 0x28; }
        }

        public IntPtr Address { get; set; }
        private IL2CPPManager Manager { get; set; }

        public IEnumerable<IL2CPPClass> Classes { get => _classes ?? (_classes = GetClasses()); }
        private IEnumerable<IL2CPPClass> _classes;

        public IL2CPPImage(IL2CPPManager manager, IntPtr address)
        {
            Manager = manager;
            Address = address;
        }

        public IL2CPPClass this[string classname]
        {
            get
            {
                if (classname == null) return null;
                if (Classes == null) return null;
                return Classes.FirstOrDefault(c => c.Name == classname);
            }
        }

        private IEnumerable<IL2CPPClass> GetClasses()
        {
            if (!Game.Process.ReadValue<int>(Address + Offsets.TypeCount, out var typeCount) || typeCount == 0) yield break;
            if (!Game.Process.ReadValue<IntPtr>(Address + Offsets.MetadataHandle, out var metadataPointer) || metadataPointer == IntPtr.Zero) yield break;
            if (!Game.Process.ReadValue<int>(metadataPointer, out int metadataHandle)) yield break;
            if (!Game.Process.ReadValue<IntPtr>(Manager.TypeInfoDefinitionTableAddress, out IntPtr typeInfoTablePtr)) yield break;

            IntPtr ptr = typeInfoTablePtr + metadataHandle * 0x8;

            for (int i = 0; i < typeCount; i++)
                yield return new IL2CPPClass(Manager, Game.Process.ReadValue<IntPtr>(ptr + 0x8 * i));
        }



    }
}

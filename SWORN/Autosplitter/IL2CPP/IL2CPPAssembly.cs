using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LiveSplit.ComponentUtil;
using Livesplit.SWORN.Memory;

namespace Livesplit.SWORN.IL2CPP
{
    public class IL2CPPAssembly
    {

        public static class Offsets
        {
            public static int Image { get => 0; }
            public static int Name { get => 0x18; }
        }

        public IntPtr Address { get; private set; }
        private IL2CPPManager Manager { get; set; }


        public string Name { get => _name ?? (_name = GetName()); }
        private string _name;

        public IL2CPPImage Image { get => _image ?? (_image = GetImage()); }
        private IL2CPPImage _image;

        public IL2CPPAssembly(IL2CPPManager manager, IntPtr address)
        {
            Manager = manager;
            Address = address;
        }

        public IL2CPPClass this[string classname]
        {
            get
            {
                if (classname == null || Image == null || Image.Classes == null) return null;
                return Image.Classes.FirstOrDefault(c => c.Name == classname);
            }
        }

        private IL2CPPImage GetImage()
        {
            if (Game.Process.ReadValue<IntPtr>(Address + Offsets.Image, out var address))
                return new IL2CPPImage(Manager, address);
            else throw new Exception("IL2CPPAssembly: Could not get image");
        }

        private string GetName()
        {
            if (!new DeepPointer(Address + Offsets.Name, 0).DerefString(Game.Process, 256, out var value)) return null;
            return value;
        }




    }
}

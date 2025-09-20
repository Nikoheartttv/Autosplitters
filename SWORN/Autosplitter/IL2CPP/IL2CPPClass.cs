using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using LiveSplit.ComponentUtil;
using Livesplit.SWORN.Memory;

namespace Livesplit.SWORN.IL2CPP
{
    public class IL2CPPClass
    {
        public static class Offsets
        {
            public static int Name { get; } = 0x10;
            public static int Namespace { get; } = 0x18;
            public static int Parent { get; } = 0x58;
            public static int Fields { get; } = 0x80;
            public static int StaticFields { get; } = 0xB8;
            public static int FieldCount { get; } = 0x124;
        }

        public IntPtr Address { get; set; }
        private IL2CPPManager Manager { get; set; }

        public string Name { get => _name ?? (_name = GetName()); }
        private string _name;

        public string Namespace { get => _namespace ?? (_namespace = GetNamespace()); }
        private string _namespace;

        public IL2CPPClass Parent { get => GetParent(); }
        public ushort FieldCount { get => GetFieldCount(); }
        public IntPtr Static { get => GetStaticFieldsAddress(); }

        public IEnumerable<IL2CPPField> Fields { get => _fields ?? (_fields = GetFields()); }
        private IEnumerable<IL2CPPField> _fields;

        public IL2CPPClass(IL2CPPManager manager, IntPtr address)
        {
            Manager = manager;
            Address = address;
        }

        public int this[string fieldName]
        {
            get
            {
                if (fieldName == null) throw new Exception("Get offset: Fieldname is null");
                if (Fields == null) throw new Exception("Get offset: Fields collection is null");
                var field = Fields.FirstOrDefault(f => f.Name == fieldName || f.Name == "<" + fieldName + ">k__BackingField") 
                    ?? throw new Exception("Get offset: Field " + fieldName + " could not be found");
                if (!field.Offset.HasValue) throw new Exception("Get offset: Field " + fieldName + " has null offset");
                return field.Offset.Value;
            }
        }

        public IntPtr StaticAddress(string fieldName)
        {
            return Static + this[fieldName];
        }

        private string GetName()
        {
            if (!new DeepPointer(Address + Offsets.Name, 0).DerefString(Game.Process, 256, out var value)) return null;
            return value;
        }

        private string GetNamespace()
        {
            if (!new DeepPointer(Address + Offsets.Namespace, 0).DerefString(Game.Process, 256, out var value)) return null;
            return value;
        }

        private IL2CPPClass GetParent()
        {
            if (!Game.Process.ReadValue<IntPtr>(Address + Offsets.Parent, out IntPtr address) || address == IntPtr.Zero) return default;
            return new IL2CPPClass(Manager, address);
        }

        private ushort GetFieldCount()
        {
            if (!Game.Process.ReadValue<ushort>(Address + Offsets.FieldCount, out ushort count) || count == 0 || count == ushort.MaxValue) return default;
            return count;
        }

        private IntPtr GetStaticFieldsAddress()
        {
            if (!Game.Process.ReadValue<IntPtr>(Address + Offsets.StaticFields, out IntPtr value)) return IntPtr.Zero;
            return value;
        }

        private IEnumerable<IL2CPPField> GetFields()
        {
            IL2CPPClass klass = this;

            while (true)
            {
                if (klass == null) yield break;
                if (klass.Name == "Object" || klass.Namespace == "UnityEngine") yield break;

                if (Game.Process.ReadValue<IntPtr>(Address + Offsets.Fields, out var fieldsAddress) && fieldsAddress != IntPtr.Zero)
                {
                    for (int i = 0; i < FieldCount; i++)
                        yield return new IL2CPPField(fieldsAddress + i * IL2CPPField.Offsets.StructSize);
                }

                klass = klass.Parent;
            }
        }

    }
}

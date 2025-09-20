using LiveSplit.ComponentUtil;
using System;
using Livesplit.SWORN.Memory;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;

namespace Livesplit.SWORN.IL2CPP
{
    public class IL2CPPManager
    {
        public IntPtr AssembliesAddress { get; private set; }
        public IntPtr TypeInfoDefinitionTableAddress { get; private set; }

        public IEnumerable<IL2CPPAssembly> Assemblies { get => _assemblies ?? (_assemblies = GetAssemblies()); }
        private IEnumerable<IL2CPPAssembly> _assemblies;

        public IL2CPPManager()
        {
            AssembliesAddress = GetAssembliesAddress();
            if (AssembliesAddress == IntPtr.Zero) throw new Exception("GetAssembliesAddress: Address not found");

            TypeInfoDefinitionTableAddress = GetTypeInfoDefinitionTableAddress();
            if (TypeInfoDefinitionTableAddress == IntPtr.Zero) throw new Exception("GetTypeInfoDefinitionTableAddress: Address not found");
        }

        public IL2CPPAssembly this[string assemblyName]
        {
            get
            {
                if (assemblyName == null) return null;
                if (Assemblies == null) return null;
                return Assemblies.FirstOrDefault(asm => asm.Name == assemblyName);
            }
        }

        public IL2CPPClass GetClass(string assemblyName, string className)
        {
            var assembly = this[assemblyName] ?? throw new Exception("GetClass: Assembly not found");
            var klass = assembly[className] ?? throw new Exception("GetClass: Class not found");
            return klass;
        }

        public IL2CPPClass GetClass(string className) => GetClass("Assembly-CSharp", className);


        private IntPtr GetAssembliesAddress()
        {
            SignatureScanner sigScanner;
            SigScanTarget target;

            // Assemblies
            target = new SigScanTarget(5, "75 ?? 48 8B 1D ?? ?? ?? ?? 48 3B 1D") { OnFound = (proc, scanner, address) => { return address + 0x4 + Game.Process.ReadValue<int>(address); } };
            sigScanner = new SignatureScanner(Game.Process, GameAssemblyModule.BaseAddress, GameAssemblyModule.ModuleMemorySize);
            return sigScanner.Scan(target);
        }

        private IntPtr GetTypeInfoDefinitionTableAddress()
        {
            SignatureScanner sigScanner;
            SigScanTarget target;

            // Metadata
            sigScanner = new SignatureScanner(Game.Process, GameAssemblyModule.BaseAddress, GameAssemblyModule.ModuleMemorySize);
            target = new SigScanTarget(0, "67 6C 6F 62 61 6C 2D 6D 65 74 61 64 61 74 61 2E 64 61 74 00");
            IntPtr metaData = sigScanner.Scan(target);
            if (metaData == IntPtr.Zero) throw new Exception("GetTypeInfoDefinitionTableAddress: Could not find metadata");

            // Load Effective Address
            target = new SigScanTarget(3, "48 8D 0D");
            IntPtr lea = sigScanner.ScanAll(target).FirstOrDefault(addr => addr + 0x4 + Game.Process.ReadValue<int>(addr) == metaData);
            if (lea == IntPtr.Zero) throw new Exception("GetTypeInfoDefinitionTableAddress: Could not find LEA");

            // shr
            sigScanner = new SignatureScanner(Game.Process, lea, 0x200);
            target = new SigScanTarget(3, "48 C1 E9");
            IntPtr shr = sigScanner.Scan(target);
            if (shr == IntPtr.Zero) throw new Exception("GetTypeInfoDefinitionTableAddress: Could not find SHR");

            // TypeInfoDefinitionTable
            sigScanner = new SignatureScanner(Game.Process, shr, 0x100);
            target = new SigScanTarget(3, "48 89 05") { OnFound = (proc, scanner, address) => address + 0x4 + proc.ReadValue<int>(address) };
            return sigScanner.Scan(target);
        }


        private IEnumerable<IL2CPPAssembly> GetAssemblies()
        {
            var firstAssembly = Game.Process.ReadValue<IntPtr>(AssembliesAddress);
            var lastAssembly = Game.Process.ReadValue<IntPtr>(AssembliesAddress + 0x8);
            int count = (int)(((ulong)lastAssembly - (ulong)firstAssembly) / 0x8);

            for (var i = 0; i < count; i++)
            {
                yield return new IL2CPPAssembly(this, Game.Process.ReadValue<IntPtr>(firstAssembly + 0x8 * i));
            }
        }

        private ProcessModule GameAssemblyModule
        {
            get
            {
                if (_gameAssemblyModule == null)
                    _gameAssemblyModule = Game.Process.Modules.Cast<ProcessModule>().FirstOrDefault(mod => mod.ModuleName == "GameAssembly.dll")
                    ?? throw new Exception("Game Assembly not found >:(");

                return _gameAssemblyModule;
            }
        }
        private ProcessModule _gameAssemblyModule;

    }
}

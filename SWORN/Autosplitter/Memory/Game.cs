using LiveSplit.ComponentUtil;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace Livesplit.SWORN.Memory
{
    public static class Game
    {
        public static string Name { get; set; }

        public static Process Process
        {
            get
            {
                if (process == null)
                {
                    if (DateTime.Now <= lastHooked.AddSeconds(1)) return null;
                    if (GetGameProcess(out process))
                    {
                        Thread.Sleep(1000);
                        process.EnableRaisingEvents = true;
                        process.Exited += OnClose;
                        OnHook?.Invoke(null, EventArgs.Empty);
                    }
                }
                else
                {
                    if (process.HasExited) ResetProcess();
                    lastHooked = DateTime.Now;
                }

                return process;
            }
        }
        private static Process process;

        private static DateTime lastHooked;

        public static event EventHandler OnHook;
        public static event EventHandler OnClose;

        public static bool Is64Bit
        { 
            get
            {
                if (Process == null) return default;
                return Process.Is64Bit();
            }
        }

        public static int PointerSize
        {
            get
            {
                if (Process == null) return default;
                return Is64Bit ? 0x8 : 0x4;
            }
        }

        public static void ReleaseProcess()
        {
            ResetProcess();
            OnClose?.Invoke(null, EventArgs.Empty);
        }

        private static bool GetGameProcess(out Process process)
        {
            process = null;
            if (String.IsNullOrWhiteSpace(Name)) return false;
            process = Process.GetProcessesByName(Name).FirstOrDefault();
            return process != null;
        }

        private static void ResetProcess()
        {
            if (process != null)
            {
                process.Exited -= OnClose;
                process.Dispose();
                process = null;
            }
        }

    }
}

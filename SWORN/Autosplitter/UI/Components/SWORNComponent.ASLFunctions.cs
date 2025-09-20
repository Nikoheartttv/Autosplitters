using Livesplit.SWORN.IL2CPP;
using Livesplit.SWORN.Memory;
using LiveSplit.ComponentUtil;
using LiveSplit.Model;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Windows.Forms;

namespace Livesplit.SWORN.UI.Components
{
    public partial class SWORNComponent : LiveSplit.UI.Components.IComponent
    {

        public Watcher<List<BossData>> BossData { get; set; } = new Watcher<List<BossData>>();

        public dynamic Config { get; set; }

        public IL2CPPManager Manager { get; set; }

        public void Startup()
        {
        }

        public void Init()
        {
            Manager = new IL2CPPManager();

            if (State.CurrentTimingMethod != TimingMethod.GameTime)
            {
                DialogResult mbox = MessageBox.Show(State.Form,
                    "SWORN uses in-game time.\nWould you like to switch to it?",
                    "SWORN",
                    MessageBoxButtons.YesNo);

                if (mbox == DialogResult.Yes) State.CurrentTimingMethod = TimingMethod.GameTime;
            }

            var asd = Manager.GetClass("AutoSplitterData", "AutoSplitterData");
            var mainmenu = Manager.GetClass("MainMenu");
            var overlayui = Manager.GetClass("OverlayUI");
            Watchers.Add(new MemoryWatcher<float>(asd.StaticAddress("GameTime")) { Name = "GameTimer" });
            Watchers.Add(new ManagedStringWatcher(asd.StaticAddress("RoomId")) { Name = "RoomID" });
            Watchers.Add(new MemoryWatcher<bool>(asd.StaticAddress("DidWin")) { Name = "DidWin" });
            Watchers.Add(new MemoryWatcher<bool>(new DeepPointer(mainmenu.StaticAddress("Instance"), mainmenu["IsVisible"])) { Name = "IsInMainMenu" });
            Watchers.Add(new ManagedListWatcher<IntPtr>(new DeepPointer(overlayui.StaticAddress("instance"), overlayui["bossUIs"])) { Name = "BossUIs" });

            Watchers.UpdateAll(Game.Process);
        }

        public bool Update()
        {
            Watchers.UpdateAll(Game.Process);

            // Log RoomIDs to Tracespy
            if (Watchers["RoomID"].Changed) Utility.Log("RoomID: \"" + ((string)Watchers["RoomID"].Current) + "\"");

            if (GameData.MiniBossIDs.Contains(Watchers["RoomID"].Current) || GameData.BossIDs.Contains(Watchers["RoomID"].Current))
            {
                BossData.Current = GetBossData((List<IntPtr>)Watchers["BossUIs"].Current);
            }
            else BossData.Current = null;

            return true;
        }

        public bool Start()
        {
            if (Watchers["RoomID"].Changed && (string)Watchers["RoomID"].Current == " Intro ") return true;
            return false;
        }

        public void OnStart()
        {
            Utility.Log("Start");
        }

        public bool IsLoading()
        {
            return true;
        }

        public TimeSpan? GameTime()
        {
            return TimeSpan.FromSeconds((float)Watchers["GameTimer"].Current);
        }

        public bool Reset()
        {
            if (Settings["Reset_Lobby"] && Watchers["RoomID"].Changed && (string)Watchers["RoomID"].Current == "Hub Area ") return true;
            if (Settings["Reset_MainMenu"] && Watchers["IsInMainMenu"].Changed && (bool)Watchers["IsInMainMenu"].Current == true) return true;
            return false;
        }

        public void OnReset()
        {
            Utility.Log("Reset");
        }

        public bool Split()
        {
            // Split on all rooms
            if (Settings["Split_Room"] && Watchers["RoomID"].Changed &&
                (!Settings["SplitException_RestShop"] || !GameData.RestShopIDs.Contains(Watchers["RoomID"].Old)) &&
                (!Settings["SplitException_HubArea"] || !((string)Watchers["RoomID"].Old == "Hub Area " || (string)Watchers["RoomID"].Current == "Hub Area "))) return true;

            // Split on miniboss
            if (Settings["Split_Miniboss"] && Watchers["RoomID"].Changed && GameData.MiniBossIDs.Contains(Watchers["RoomID"].Old)) return true;

            // Split on boss
            if (Settings["Split_Boss"] && Watchers["RoomID"].Changed && GameData.BossIDs.Contains(Watchers["RoomID"].Old)) return true;

            // Split on run completion
            if (Settings["Split_DidWin"] && Watchers["DidWin"].Changed && (bool)Watchers["DidWin"].Current == true) return true;

            if (Settings["Split_Individual_SirGawain"] && BossData.Current != null && BossData.Current[0].Name == "Gawain, Butcher of Wirral" && BossData.Current[0].Health == 0 && BossData.Old[0].Health > 0) return true;

            // Boss HP Splits
            if (BossData.Old != null && BossData.Current != null
                && BossData.Current.Count > 0 && BossData.Current[0].Name != null
                && GameData.BossesInverted.TryGetValue(BossData.Current[0].Name, out var bossKey) && Settings["Split_BossHP_" + bossKey])
            {
                float oldBossHealth = 0, currentBossHealth = 0;
                foreach (var boss in BossData.Old)
                {
                    oldBossHealth += boss.Health;
                }
                foreach (var boss in BossData.Current)
                {
                    currentBossHealth += boss.Health;
                }

                if (oldBossHealth != 0 && currentBossHealth == 0)
                {
                    Utility.Log("Boss HP Split: " + bossKey);
                    return true;
                }
            }

            return false;
        }

        public void OnSplit()
        {
            Utility.Log("Split");
        }

        public void Exit()
        {
            Manager = null;
        }

        public void Shutdown()
        {
        }

        public List<BossData> GetBossData(List<IntPtr> bossUIs)
        {
            if (bossUIs == null) return null;

            var data = new List<BossData>();

            foreach (var bossUI in bossUIs)
            {
                var bossData = new BossData();

                if (new DeepPointer(bossUI + 0x3F0, 0x3E0).DerefManagedString(Game.Process, out var bossName)) bossData.Name = Utility.StripHtmlTags(bossName);
                if (new DeepPointer(bossUI + 0x418, 0xBC).Deref<float>(Game.Process, out var bossMaxHealth)) bossData.MaxHealth = bossMaxHealth;
                if (new DeepPointer(bossUI + 0x418, 0xB8).Deref<float>(Game.Process, out var bossHealth)) bossData.Health = bossHealth;

                data.Add(bossData);
            }

            return data;
        }

        private string GetProcessHash(Process process)
        {
            if (process == null) return null;
            using (var md5 = MD5.Create())
            using (var s = File.Open(process.MainModule.FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
                return md5.ComputeHash(s).Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
        }

    }
}

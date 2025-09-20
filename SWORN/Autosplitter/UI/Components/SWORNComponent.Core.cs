using Livesplit.SWORN.Memory;
using LiveSplit.Model;
using LiveSplit.Model.Input;
using LiveSplit.UI;
using LiveSplit.UI.Components;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System.Windows.Forms;
using LiveSplit.ComponentUtil;

namespace Livesplit.SWORN.UI.Components
{
    public partial class SWORNComponent : LiveSplit.UI.Components.IComponent
    {
        public string ComponentName { get => "SWORN Autosplitter"; }

        public float HorizontalWidth => 0;
        public float MinimumHeight => 0;
        public float VerticalHeight => 0;
        public float MinimumWidth => 0;
        public float PaddingTop => 0;
        public float PaddingBottom => 0;
        public float PaddingLeft => 0;
        public float PaddingRight => 0;
        public void DrawHorizontal(System.Drawing.Graphics g, LiveSplitState state, float height, System.Drawing.Region clipRegion) { }
        public void DrawVertical(System.Drawing.Graphics g, LiveSplitState state, float width, System.Drawing.Region clipRegion) { }

        public IDictionary<string, Action> ContextMenuControls => null;

        public SWORNAutosplitterSettings Settings { get; set; }

        public LiveSplitState State { get; set; }
        public TimerModel Timer { get; set; }
        public MemoryWatcherList Watchers { get; set; }

        public EventHandler StartEvent => (sender, e) => { OnStart(); };
        public EventHandlerT<TimerPhase> ResetEvent => (sender, e) => { OnReset(); };
        public EventHandler SplitEvent => (sender, e) => { OnSplit(); };
        public EventHandler HookEvent => Init;
        public EventHandler CloseEvent => Exit;

        public bool Initialized;

        public SWORNComponent(LiveSplitState state)
        {
            Utility.Log("Livesplit.SWORN: Startup");
            State = state;
            Timer = new TimerModel() { CurrentState = state };
            Settings = new SWORNAutosplitterSettings();
            Watchers = new MemoryWatcherList();

            Game.Name = "SWORN";

            State.OnStart += StartEvent;
            State.OnReset += ResetEvent;
            Timer.OnSplit += SplitEvent;
            Game.OnHook += HookEvent;
            Game.OnClose += CloseEvent;
            Startup();
            Utility.Log("Livesplit.SWORN: Startup Completed");
        }

        public void Init(object sender, EventArgs e)
        {
            Utility.Log("Livesplit.SWORN: Init");
            try
            {
                Init();
                Initialized = true;
                Utility.Log("Livesplit.SWORN: Init Completed");
            }
            catch (Exception ex)
            {
                Utility.Log("Init Failed! (" + ex.Message + ")");
                Game.ReleaseProcess();
            }
        }

        public void Exit(object sender, EventArgs e)
        {
            Utility.Log("Livesplit.SWORN: Exit");
            Exit();
            Watchers.Clear();
            Initialized = false;
            Utility.Log("Livesplit.SWORN: Exit Completed");
        }

        public void Dispose()
        {
            Utility.Log("Livesplit.SWORN: Shutdown");
            if (Initialized) Game.ReleaseProcess();
            Shutdown();
            State.OnStart -= StartEvent;
            State.OnReset -= ResetEvent;
            Timer.OnSplit -= SplitEvent;
            Game.OnHook -= HookEvent;
            Game.OnClose -= CloseEvent;
            Utility.Log("Livesplit.SWORN: Shutdown Completed");
        }

        public XmlNode GetSettings(XmlDocument document)
        {
            if (Settings == null) throw new NullReferenceException("Settings control is not initialised");
            return Settings.GetSettings(document);
        }

        public Control GetSettingsControl(LayoutMode mode)
        {
            Settings.Mode = mode;
            return Settings;
        }

        public void SetSettings(XmlNode settings)
        {
            if (Settings == null) throw new NullReferenceException("Settings control is not initialised");
            Settings.SetSettings(settings);
        }

        public void Update(IInvalidator invalidator, LiveSplitState state, float width, float height, LayoutMode mode)
        {
            if (Game.Process == null) return;
            if (!Initialized) return;

            if (!Update()) return;
            if (Timer.CurrentState.CurrentPhase == TimerPhase.Running)
            {
                Timer.CurrentState.IsGameTimePaused = IsLoading();
                Timer.CurrentState.SetGameTime(GameTime());
                if (Settings.Reset && Reset()) Timer.Reset();
                else if (Settings.Split && Split()) Timer.Split();
            }
            else if (Settings.Start && Start()) Timer.Start();
        }
    }
}

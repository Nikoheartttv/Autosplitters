state("re9"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main");
	vars.Uhara.Settings.CreateFromXml("Components/RE9.Settings.xml");
	if (timer.CurrentTimingMethod == TimingMethod.RealTime)
	{         
		var timingMessage = MessageBox.Show (
			"This game uses Load Removed Time as the main timing method.\n"+
			"LiveSplit is currently set to show Real Time (RTA).\n"+
			"Would you like to set the timing method to Game Time?",
			"LiveSplit | Resident Evil Requiem",
			MessageBoxButtons.YesNo,MessageBoxIcon.Question);

		if (timingMessage == DialogResult.Yes) timer.CurrentTimingMethod = TimingMethod.GameTime;
	}

	vars.timers = new Dictionary<string, int> {
		{"OperatingTime", 0}, {"SystemElapsedTime", 1}, {"GameElapsedTime", 2}, {"GameSystemElapsedTime", 3},
		{"LoadSpending", 4}, {"SystemMenuSpending", 5}, {"PauseSpending", 6}, {"EventSpending", 7}, {"MovieSpending", 8},
		{"SaveLoadSpending", 9}, {"PhotoModeSpending", 10}, {"RichTutorialSpending", 11}, {"SubGame1ElapsedTime", 12}
	};
	vars.bitCheck = new Func<byte, int, bool>((byte val, int b) => (val & (1 << b)) != 0);

	vars.CompletedSplits = new HashSet<string>();
	vars.CounterObjectives = new HashSet<string> { "Ob_303_010_010_010", "Ob_305_020_040" };
	vars.ObjCounters = new Dictionary<string, int>();

	vars.ReadyToLoadEvents = new HashSet<int> { 
		111301, 111500, 111900, 112800, 112900, 311610, 312700, 321950, 322900, 331900,
		341900, 342900, 351910, 420500, 420850, 430950, 440900, 441800,
		450900, 510900, 530800, 530900, 540200, 531100, 531900
	};

	vars.ReturnedFromLoadEvents = new HashSet<int> { 
		111000, 111310, 111510, 112100, 311101, 312101, 321010, 322000, 
		331000, 342000, 351000, 410201, 420910, 420502, 440000, 441000, 442100, 
		520100, 530100
	};
}

init
{
	IntPtr MainGameFlowManager = vars.Uhara.ScanRel(3, "48 8b 05 ?? ?? ?? ?? 48 85 c0 74 ?? 80 78 ?? ?? 0f 84 ?? ?? ?? ?? 48 89 f1");
	IntPtr SceneTransitionManager = vars.Uhara.ScanRel(3, "48 8b 05 ?? ?? ?? ?? 48 85 c0 0f 84 ?? ?? ?? ?? 48 89 d6 48 8b 58");
	IntPtr PauseManager = vars.Uhara.ScanRel(3, "48 8b 05 ?? ?? ?? ?? 48 85 c0 74 ?? 8a 98");
	IntPtr EnvStageManager = vars.Uhara.ScanRel(3, "4c 8b 35 ?? ?? ?? ?? 48 8b 5f ?? 48 8b 7f");
	IntPtr GameClock = vars.Uhara.ScanRel(3, "48 8b 15 ?? ?? ?? ?? 48 8b 41 ?? 48 8b 40 ?? 84 db");
	IntPtr FadeManager = vars.Uhara.ScanRel(3, "48 8b 05 ?? ?? ?? ?? 48 85 c0 74 ?? 48 8b 40 ?? 48 85 c0 0f 84 ?? ?? ?? ?? 83 78");
	IntPtr InventoryManager = vars.Uhara.ScanRel(3, "48 8b 15 ?? ?? ?? ?? 48 85 d2 0f 84 ?? ?? ?? ?? 48 83 ec ?? 48 89 f1 4c 8b 7d");
	IntPtr CharacterManager = vars.Uhara.ScanRel(3, "48 8b 15 ?? ?? ?? ?? 48 85 d2 0f 84 ?? ?? ?? ?? 80 ba ?? ?? ?? ?? ?? 0f 85");
	IntPtr EventSaveManager = vars.Uhara.ScanRel(3, "48 8b 15 ?? ?? ?? ?? 48 85 d2 0f 84 ?? ?? ?? ?? 44 8b 40 ?? 48 89 f1 41 b9");
	IntPtr TimelineEventMediator = vars.Uhara.ScanRel(3, "48 8b 15 ?? ?? ?? ?? 48 85 d2 0f 84 ?? ?? ?? ?? 48 89 f1 41 89 d8");
	IntPtr GuiManager = vars.Uhara.ScanRel(3, "48 8b 05 ?? ?? ?? ?? 48 85 c0 74 ?? 48 8b 50 ?? 48 85 d2 74 ?? 48 8b 05 ?? ?? ?? ?? 4c 8b 80");
	IntPtr ItemManager = vars.Uhara.ScanRel(3, "48 8b 05 ?? ?? ?? ?? 48 85 c0 0f 84 ?? ?? ?? ?? 48 89 d6 48 8b 90 ?? ?? ?? ?? 48 85 d2");
	IntPtr InteractManager = vars.Uhara.ScanRel(3, "48 8b 15 ?? ?? ?? ?? 48 85 d2 0f 84 ?? ?? ?? ?? 48 89 f1 49 89 f8 49 89 d9");

	vars.Resolver.WatchString("Chapter", MainGameFlowManager, 0x20, 0x80, 0x14);    
	vars.Resolver.WatchString("View", SceneTransitionManager, 0x28, 0x40, 0x14);
	vars.Resolver.Watch<byte>("PauseType", PauseManager, 0x60);
	vars.Resolver.WatchString("StageName", EnvStageManager, 0x88, 0x14);
	vars.Resolver.Watch<byte>("GameClockTimerBit", GameClock, 0x20);
	vars.Resolver.WatchString("SwitchGameSceneName", MainGameFlowManager, 0x20, 0x98, 0x14);
	vars.Uhara["SwitchGameSceneName"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
	vars.Resolver.Watch<IntPtr>("EnemyContextList", CharacterManager, 0xB8, 0x10);
	vars.Resolver.Watch<int>("EnemyContextListArrayNum", CharacterManager, 0xB8, 0x18);
	vars.Resolver.Watch<IntPtr>("EventSaveList", EventSaveManager, 0x10, 0x10, 0x10);
	vars.Resolver.Watch<int>("EventSaveListSize", EventSaveManager, 0x10, 0x10, 0x18);
	vars.Resolver.Watch<IntPtr>("ActiveEvents", TimelineEventMediator, 0x20);
	vars.Resolver.Watch<byte>("PlayerModeFade", FadeManager, 0x10, 0x48, 0x70);
	vars.Resolver.Watch<IntPtr>("PlayerContextFast", CharacterManager, 0xB0);
	vars.Resolver.Watch<int>("EventName", TimelineEventMediator, 0x20, 0x10, 0x20, 0xB4);
	vars.Resolver.Watch<IntPtr>("ItemPickedupIDSet", ItemManager, 0x50, 0x18);
	vars.Resolver.Watch<int>("ItemPickedupIDSetSize", ItemManager, 0x50, 0x3C);
	vars.Resolver.Watch<bool>("OptionsMenu", GuiManager, 0x1B0, 0x18, 0x18, 0x41);
	vars.Resolver.Watch<bool>("PauseMenu", GuiManager, 0xD8, 0x18, 0x18, 0x41);
	vars.Resolver.Watch<int>("CurrentSituationType", GuiManager, 0x3AC);
	vars.Resolver.Watch<bool>("GameLoading", GuiManager, 0x190, 0x18, 0x18, 0x41);
	vars.Resolver.Watch<int>("InteractLimitType", InteractManager, 0x40);
	vars.Resolver.Watch<float>("CharacterPositionY", CharacterManager, 0xB0, 0x104);
	vars.Resolver.Watch<float>("CharacterPositionZ", CharacterManager, 0xB0, 0x108);
	vars.Resolver.Watch<IntPtr>("ObjectiveGUIController", GuiManager, 0x140, 0x18);
	vars.Resolver.Watch<IntPtr>("Inventory", InventoryManager, 0x58, 0x18);

	current.View = "";
	current.PauseType = 0;
	current.StageName = "";
	current.GameClockTimerBit = 0;
	current.SwitchGameSceneName = "";
	current.EvnStageName = 0;
	current.TimelinePlayState = 1;
	current.EnemyHealth = 0;
	current.ItemPickup = "";
	current.ObjectiveGUIID = "";
	current.ObjectiveGUICleared = false;
	current.ObjectiveGUICount = 0;
	current.LeonInvPanelSize = 0;
	current.AtticChunk = false;
	current.Commander = false;
	current.GiantSpider = false;
	current.Tyrant = false;
	current.B700IsEnd = false;
	current.C510IsEnd = false;
	current.BatteryPickup = "";
	current.GameSceneName = "";
	vars.Loading = false;
	vars.Permaload = false;
	vars.RCCBattery = 0;
	vars.Chap1_01Count = 0;
	vars.Chap4_40Count = 0;
}

start
{
	if (current.View == "MainGame")
	{
		if (settings["NoIntro"]) return current.StageName == "st30_003" && old.PlayerModeFade == 2 && current.PlayerModeFade == 3;
		else return current.Chapter == "Chap1_00" && old.PauseType == 0 && current.PauseType == 8;
	}
}

onStart
{
	timer.IsGameTimePaused = true; 
	vars.Loading = false;
	vars.Permaload = false;
	vars.RCCBattery = 0;
	vars.Chap1_01Count = 0;
	vars.Chap4_40Count = 0;
	current.LeonInvPanelSize = 0;
	current.AtticChunk = false;
	current.Commander = false;
	current.GiantSpider = false;
	current.Tyrant = false;
	current.BatteryPickup = "";
	current.GameSceneName = "";
	current.B700IsEnd = false;
	current.C510IsEnd = false;
	vars.CompletedSplits.Clear();
}

update
{
	vars.Uhara.Update();

	// Setting up currents
	current.GameSceneName = string.IsNullOrEmpty(current.SwitchGameSceneName) ? old.GameSceneName : current.SwitchGameSceneName;

	if (current.EventSaveListSize > old.EventSaveListSize && current.EventSaveList != IntPtr.Zero && current.EventSaveListSize > 0)
	{
		int eventID = vars.Resolver.Read<int>(current.EventSaveList + ((current.EventSaveListSize - 1) * 0x8) + 0x20, 0x10);
		current.EvnStageName = eventID;
	}
	
	if (current.ObjectiveGUIController != IntPtr.Zero) {
		IntPtr objectiveGUIControllerUnit = vars.Resolver.Read<IntPtr>(current.ObjectiveGUIController + 0x18, 0x28, 0x10);
		int objectiveGUIControllerUnitCont = vars.Resolver.Read<int>(current.ObjectiveGUIController + 0x18, 0x28, 0x1C);
		if (objectiveGUIControllerUnit != IntPtr.Zero && objectiveGUIControllerUnitCont > 0) {

			current.ObjectiveGUIID = vars.Resolver.ReadString(objectiveGUIControllerUnit + 0x20, 0x98, 0x10, 0x10, 0x14);
			current.ObjectiveGUICleared = vars.Resolver.Read<bool>(objectiveGUIControllerUnit + 0x20, 0x98, 0x28);
			current.ObjectiveGUICount = vars.Resolver.Read<int>(objectiveGUIControllerUnit + 0x20, 0x98, 0x1C);
		}
	}

	if (current.ActiveEvents != IntPtr.Zero) {
		int size = vars.Resolver.Read<int>(current.ActiveEvents + 0x18);
		current.TimelinePlayState = 1;
		if (size > 0) {
			byte rawTPS = vars.Resolver.Read<byte>(current.ActiveEvents + 0x10, 0x20, 0xBC);
			if (rawTPS != 0) current.TimelinePlayState = rawTPS;
		}
	}

	if (current.ItemPickedupIDSetSize != old.ItemPickedupIDSetSize && current.ItemPickedupIDSetSize > 0)
	{
		int lastIndex = current.ItemPickedupIDSetSize - 1;
		string lastItemID = vars.Resolver.ReadString(64, ReadStringType.UTF16, current.ItemPickedupIDSet + ((lastIndex * 0x10) + 0x28), 0x10, 0x14);
		if (lastItemID != old.ItemPickup) current.ItemPickup = lastItemID;
	}

	// Loading Block
	if (current.CurrentSituationType != old.CurrentSituationType && current.CurrentSituationType == 0 && vars.ReadyToLoadEvents.Contains(current.EventName)) {
		vars.Permaload = true;
	}

	if (current.PauseType == 8 && current.EventName != 0 && vars.ReadyToLoadEvents.Contains(current.EventName)) {
		vars.Permaload = true;
	}
	if (current.EventName == 110000 && old.View != "AppTitle" && current.View == "MainGame") {
		vars.Permaload = true;
	}
	if (current.EventName == 520920 && old.PauseType == 0 && current.PauseType == 1) {
		vars.Permaload = true;
	}

	if (current.EventName == 450900 && old.PauseType == 1 && current.PauseType == 0) {
		vars.Permaload = false;
	}

	if (current.EventName == 420502 && old.EventName != 420502)
	{
		vars.Permaload = false;
		vars.Loading = true;
	}

	if (current.InteractLimitType == 32 && 
		((current.StageName == "st40_122" && Math.Abs(current.CharacterPositionY - (-3.25f)) <= 0.04 && Math.Abs(current.CharacterPositionZ - (-386f)) <= 4) ||
		(current.StageName == "st40_202" && Math.Abs(current.CharacterPositionY - (-11.25f)) <= 0.05 && Math.Abs(current.CharacterPositionZ - (-345f)) <= 4)))
	{
		vars.Loading = true;
	}

	if ((vars.ReturnedFromLoadEvents.Contains(current.EventName) && old.PauseType == 8 && 
		(current.EvnStageName == 331900 ? (current.PauseType == 0 || current.PauseType == 2) : current.PauseType == 0)) ||
		(current.EventName == 331900 && current.EvnStageName == 331900)) 
	{
		vars.Permaload = false;
	}

	if (current.CurrentSituationType != old.CurrentSituationType && current.CurrentSituationType == 0) 
	{
		vars.Loading = true;
	}

	if (old.PauseType == 0 && current.PauseType == 8) 
	{
		vars.Loading = true;
	}

	if (old.PlayerModeFade == 2 && current.PlayerModeFade == 3) 
	{
		vars.Loading = false;
	}

	if ((old.TimelinePlayState == 8 || old.TimelinePlayState == 10) && current.TimelinePlayState == 1) 
	{
		vars.Loading = false;
	}

	if (vars.Loading && old.InteractLimitType == 32 && (current.InteractLimitType == 0 || current.InteractLimitType == 64))
	{
		vars.Loading = false;
	}

	// Enemy Checks
	if (current.EnemyContextList != IntPtr.Zero && current.EnemyContextListArrayNum > 0 && 
	(current.StageName == "st30_076" || current.StageName == "st50_010" || current.StageName == "st40_124" || current.StageName == "st40_470")) 
	{
		for (int i = 0; i < current.EnemyContextListArrayNum; i++)
		{
			string kindID = vars.Resolver.ReadString(64, ReadStringType.UTF16, current.EnemyContextList + ((i * 0x8) + 0x20), 0x40, 0x10, 0x14);
			if (kindID != "cp_C100" && kindID != "cp_C610" && kindID != "cp_B700" && kindID != "cp_C510") continue;

			int health = vars.Resolver.Read<int>(current.EnemyContextList + ((i * 0x8) + 0x20), 0x70, 0x10, 0x28);
				
			if (kindID == "cp_C100")
			{
				current.EnemyHealth = health;
				if (old.EnemyHealth > 0 && current.EnemyHealth == 0 && !vars.CompletedSplits.Contains("AtticChunk")) current.AtticChunk = true;
			}
			if (kindID == "cp_C610")
			{
				current.EnemyHealth = health;
				if (old.EnemyHealth > 0 && current.EnemyHealth == 0 && !vars.CompletedSplits.Contains("Commander")) current.Commander = true;
			}
			if (kindID == "cp_B700")
			{
				bool SpiderIsEnd = vars.Resolver.Read<bool>(current.EnemyContextList + ((i * 0x8) + 0x20), 0x138, 0x11E);
				current.B700IsEnd = SpiderIsEnd;
				if (!old.B700IsEnd && current.B700IsEnd && !vars.CompletedSplits.Contains("GiantSpider")) current.GiantSpider = true;
			}

			if (kindID == "cp_C510")
			{
				bool TyrantIsEnd = vars.Resolver.Read<bool>(current.EnemyContextList + ((i * 0x8) + 0x20), 0x134);
				current.C510IsEnd = TyrantIsEnd;
				if (!old.C510IsEnd && current.C510IsEnd && !vars.CompletedSplits.Contains("Tyrant")) current.Tyrant = true;
			}
		}
	}

	// RCC Battery Check
	if (vars.RCCBattery == 1) {
		int panelSize = vars.Resolver.Read<int>(current.Inventory + 0x78, 0x48, 0x3C);
		IntPtr leonInv = vars.Resolver.Read<IntPtr>(current.Inventory + 0x78, 0x48, 0x18);
		
		if (leonInv != IntPtr.Zero && panelSize > 0) {
			int batteryCount = 0;
			string latestBatterySlot = "";
			
			for (int i = 0; i < panelSize; i++) {
				string itemId = vars.Resolver.ReadString(64, ReadStringType.UTF16, 
					leonInv + 0x30 + (i * 0x18), 0x10, 0x20, 0x10, 0x14);
				
				if (!string.IsNullOrEmpty(itemId) && itemId.Contains("it60_00_092"))
				{
					batteryCount++;
					latestBatterySlot = itemId + "_slot" + i;
					
					if (batteryCount == 2) {
						vars.RCCBattery = 2;
						current.BatteryPickup = "it60_00_092_C2";
						break;
					}
				}
			}
			
			if (batteryCount == 1 && current.BatteryPickup != latestBatterySlot)
				current.BatteryPickup = latestBatterySlot;
		}
	}

	if (old.GameSceneName != current.GameSceneName) vars.Uhara.Log("Game Scene Name: " + current.GameSceneName);
}

split
{
	// Split on Game Scene Name Change - Chapters/Bad Ending
	if (old.GameSceneName != current.GameSceneName)
	{
		if (current.GameSceneName == "Chap1_01")
		{
			vars.Chap1_01Count++;

			string chapKey = current.GameSceneName + "_" + vars.Chap1_01Count;
			bool returnChapEnabled = settings.ContainsKey("Chap1_01_2") && settings["Chap1_01_2"];

			if (!vars.CompletedSplits.Contains(chapKey) && vars.Chap1_01Count == 2 && returnChapEnabled)
			{
				vars.CompletedSplits.Add(chapKey);
				return true;
			}
		}

		if (current.GameSceneName == "Chap4_40")
		{
			vars.Chap4_40Count++;
			
			string chapKey = current.GameSceneName + "_Ch" + vars.Chap4_40Count;
			bool ch1Enabled = settings.ContainsKey("Chap4_40_Ch1") && settings["Chap4_40_Ch1"];
			bool ch2Enabled = settings.ContainsKey("Chap4_40_Ch2") && settings["Chap4_40_Ch2"];
			
			if (!vars.CompletedSplits.Contains(chapKey) &&
				((vars.Chap4_40Count == 1 && ch1Enabled) ||
				(vars.Chap4_40Count == 2 && ch2Enabled)))
			{
				vars.CompletedSplits.Add(chapKey);
				return true;
			}
		}
		if (current.GameSceneName == "Chap5_04" && !vars.CompletedSplits.Contains(current.GameSceneName) &&
			settings.ContainsKey("BadEnding") && settings["BadEnding"])
		{
			vars.CompletedSplits.Add(current.GameSceneName);
			return true;
		}

		if (!vars.CompletedSplits.Contains(current.GameSceneName) &&
		settings.ContainsKey(current.GameSceneName) && settings[current.GameSceneName])
		{
			vars.CompletedSplits.Add(current.GameSceneName);
			return true;
		}
	}

	// Split on Event Stage Name
	if (old.EvnStageName != current.EvnStageName && !vars.CompletedSplits.Contains(current.EvnStageName.ToString()))
	{
		if (settings.ContainsKey(current.EvnStageName.ToString()) && settings[current.EvnStageName.ToString()]) 
		{
			vars.CompletedSplits.Add(current.EvnStageName.ToString());
			return true;
		}
	}

	// Split on Enemy Kill
	if (current.AtticChunk && settings.ContainsKey("AtticChunk") && settings["AtticChunk"] && !vars.CompletedSplits.Contains("AtticChunk"))
	{
		vars.CompletedSplits.Add("AtticChunk");
		return true;
	}

	if (current.Commander && settings.ContainsKey("Commander") && settings["Commander"] && !vars.CompletedSplits.Contains("Commander"))
	{
		vars.CompletedSplits.Add("Commander");
		return true;
	}

	if (current.GiantSpider && settings.ContainsKey("GiantSpider") && settings["GiantSpider"] && !vars.CompletedSplits.Contains("GiantSpider"))
	{
		vars.CompletedSplits.Add("GiantSpider");
		return true;
	}

	if (current.Tyrant && settings.ContainsKey("Tyrant") && settings["Tyrant"] && !vars.CompletedSplits.Contains("Tyrant"))
	{
		vars.CompletedSplits.Add("Tyrant");
		return true;
	}

	// Victor First Phase
	if (settings["GoodEndingPhase1"] && settings.ContainsKey("GoodEndingPhase1") && current.EventName == 530600 && !vars.CompletedSplits.Contains("GoodEndingPhase1"))
	{
		vars.CompletedSplits.Add("GoodEndingPhase1");
		return true;
	}

	// Victor Second Phase
	if (settings["GoodEndingPhase2"] && settings.ContainsKey("GoodEndingPhase2") && current.EventName == 530800 && !vars.CompletedSplits.Contains("GoodEndingPhase2"))
	{
		vars.CompletedSplits.Add("GoodEndingPhase2");
		return true;
	}

	// Detonator Pickup 2 (2 choices)
	if (settings["DetonatorItem2"] && settings.ContainsKey("DetonatorItem2") && 
		(current.ItemPickup == "it60_00_115" || current.ItemPickup == "it60_00_118") && !vars.CompletedSplits.Contains("DetonatorItem2"))
	{
		vars.CompletedSplits.Add("DetonatorItem2");
		return true;
	}

	// Escape RPD
	if (old.StageName == "st40_400" && current.StageName == "st40_451" && !vars.CompletedSplits.Contains("EscapeRPD"))
	{
		if (settings.ContainsKey("EscapeRPD") && settings["EscapeRPD"])
		{
			vars.CompletedSplits.Add("EscapeRPD");
			return true;
		}
	}

	// Split on Stage Name st50_035
	if (old.StageName != current.StageName && current.StageName == "st50_035" && !vars.CompletedSplits.Contains("st50_035"))
	{
		if (settings.ContainsKey("st50_035") && settings["st50_035"]) {
			vars.CompletedSplits.Add("st50_035");
			return true;
		}
	}

	// Split on 2nd RCE Battery
	if (vars.RCCBattery == 2 && current.BatteryPickup == "it60_00_092_C2")
	{
		if (settings.ContainsKey("Battery2") && settings["Battery2"] && !vars.CompletedSplits.Contains("Battery2"))
		{
			vars.CompletedSplits.Add("Battery2");
			return true;
		}
	}
	
	// Check for item pickups
	if (!string.IsNullOrEmpty(current.ItemPickup) && current.ItemPickup != old.ItemPickup)
	{
		if (current.ItemPickup == "it60_00_092") {
			vars.RCCBattery++;
			if (vars.RCCBattery == 1 && settings.ContainsKey("Battery1") && settings["Battery1"] && !vars.CompletedSplits.Contains("Battery1")) 
			{
				vars.CompletedSplits.Add("Battery1");
				return true;
			}
		}
		
		if (settings.ContainsKey(current.ItemPickup) && settings[current.ItemPickup] && !vars.CompletedSplits.Contains(current.ItemPickup)) {
			vars.CompletedSplits.Add(current.ItemPickup);
			return true;
		}
	}

	// Split on Objectives
	if (!string.IsNullOrEmpty(current.ObjectiveGUIID) && old.ObjectiveGUIID != current.ObjectiveGUIID 
		&& !vars.CompletedSplits.Contains(current.ObjectiveGUIID)) 
	{
		if (current.ObjectiveGUICleared && settings[current.ObjectiveGUIID + "_Cleared"] && settings.ContainsKey(current.ObjectiveGUIID + "_Cleared") &&
			!vars.CompletedSplits.Contains(current.ObjectiveGUIID + "_Cleared")) 
		{
			vars.CompletedSplits.Add(current.ObjectiveGUIID + "_Cleared");
			return true;
		}
		if (current.ObjectiveGUICount > 0 && settings[current.ObjectiveGUIID + "_C" + current.ObjectiveGUICount] &&
			settings.ContainsKey(current.ObjectiveGUIID + "_C" + current.ObjectiveGUICount) &&
			!vars.CompletedSplits.Contains(current.ObjectiveGUIID + "_C" + current.ObjectiveGUICount))
		{
			vars.CompletedSplits.Add(current.ObjectiveGUIID + "_C" + current.ObjectiveGUICount);
			return true;
		}
		if (current.ObjectiveGUICount == 0 && settings[current.ObjectiveGUIID] && settings.ContainsKey(current.ObjectiveGUIID) &&
			!vars.CompletedSplits.Contains(current.ObjectiveGUIID))
		{
			vars.CompletedSplits.Add(current.ObjectiveGUIID);
			return true;
		}	
	}
}

isLoading
{
	if (current.OptionsMenu) return false;
	return  vars.bitCheck(current.GameClockTimerBit, vars.timers["LoadSpending"]) ||
			vars.bitCheck(current.GameClockTimerBit, vars.timers["EventSpending"]) ||
			vars.bitCheck(current.GameClockTimerBit, vars.timers["MovieSpending"]) ||
			current.PauseMenu || current.View == "AppBoot" || current.View == "AppTitle" || current.View == "AppBenchmark" ||
			current.GameLoading || vars.Loading || vars.Permaload;
}

reset
{
	return settings["AutoReset"] && settings.ContainsKey("AutoReset") && old.View == "MainGame" && current.View == "AppTitle";
}

onReset
{
	vars.Loading = false;
	vars.Permaload = false;
	vars.RCCBattery = 0;
	vars.Chap1_01Count = 0;
	vars.Chap4_40Count = 0;
	vars.CompletedSplits.Clear();
}

exit
{
	timer.IsGameTimePaused = true;
}
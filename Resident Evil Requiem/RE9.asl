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
	vars.GraceInv = "";
	vars.LeonInv = "";
	vars.GraceCloneInv = "";
	vars.ObjList = "";
	vars.LastCounter = 0;

	vars.ReadyToLoadEvents = new HashSet<int> { 
		111301, 111500, 111900, 112800, 112900, 311610, 312700, 321950, 322900, 
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
	IntPtr ObjectiveManager = vars.Uhara.ScanRel(3, "48 8b 0d ?? ?? ?? ?? 48 85 c9 0f 84 ?? ?? ?? ?? 4c 8b 40 ?? c5");
	IntPtr GameClock = vars.Uhara.ScanRel(3, "48 8b 15 ?? ?? ?? ?? 48 8b 41 ?? 48 8b 40 ?? 84 db");
	IntPtr FadeManager = vars.Uhara.ScanRel(3, "48 8b 05 ?? ?? ?? ?? 48 85 c0 74 ?? 48 8b 40 ?? 48 85 c0 0f 84 ?? ?? ?? ?? 83 78");
	IntPtr InventoryManager = vars.Uhara.ScanRel(3, "48 8b 15 ?? ?? ?? ?? 48 85 d2 0f 84 ?? ?? ?? ?? 48 83 ec ?? 48 89 f1 4c 8b 7d");
	IntPtr CharacterManager = vars.Uhara.ScanRel(3, "48 8b 15 ?? ?? ?? ?? 48 85 d2 0f 84 ?? ?? ?? ?? 80 ba ?? ?? ?? ?? ?? 0f 85");
	IntPtr EventSaveManager = vars.Uhara.ScanRel(3, "48 8b 15 ?? ?? ?? ?? 48 85 d2 0f 84 ?? ?? ?? ?? 44 8b 40 ?? 48 89 f1 41 b9");
	IntPtr TimelineEventMediator = vars.Uhara.ScanRel(3, "48 8b 15 ?? ?? ?? ?? 48 85 d2 0f 84 ?? ?? ?? ?? 48 89 f1 41 89 d8");

	vars.Resolver.WatchString("Chapter", MainGameFlowManager, 0x20, 0x80, 0x14);    
	vars.Resolver.WatchString("View", SceneTransitionManager, 0x28, 0x40, 0x14);
	vars.Resolver.Watch<byte>("PauseType", PauseManager, 0x60);
	vars.Resolver.WatchString("StageName", EnvStageManager, 0x88, 0x14);
	vars.Resolver.Watch<byte>("GameClockTimerBit", GameClock, 0x20);
	vars.Resolver.WatchString("SwitchGameSceneName", MainGameFlowManager, 0x20, 0x98, 0x14);
	vars.Uhara["SwitchGameSceneName"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
	vars.Resolver.Watch<IntPtr>("ObjectiveController", ObjectiveManager, 0x40);
	vars.Resolver.WatchString("JumpTargetMainSceneName", MainGameFlowManager, 0x20, 0x78);
    vars.Resolver.WatchString("CurrentMainSceneName", MainGameFlowManager, 0x20, 0x80);
	vars.Resolver.Watch<IntPtr>("EnemyContextList", CharacterManager, 0xB8, 0x10);
	vars.Resolver.Watch<int>("EnemyContextListArrayNum", CharacterManager, 0xB8, 0x18);
	vars.Resolver.Watch<IntPtr>("EventSaveList", EventSaveManager, 0x10, 0x10, 0x10);
	vars.Resolver.Watch<int>("EventSaveListSize", EventSaveManager, 0x10, 0x10, 0x18);
	vars.Resolver.Watch<int>("EventFadeState", FadeManager, 0x10, 0x40, 0x70);
	vars.Resolver.Watch<IntPtr>("Inventory", InventoryManager, 0x58, 0x18);
	vars.Resolver.Watch<IntPtr>("TransitionTarget", SceneTransitionManager, 0x30);
	vars.Resolver.Watch<IntPtr>("ActiveEvents", TimelineEventMediator, 0x20);
	vars.Resolver.Watch<int>("ActiveEventsSize", current.ActiveEvents, 0x18);
	vars.Resolver.Watch<byte>("PlayerModeFade", FadeManager, 0x10, 0x48, 0x70);
	vars.Resolver.Watch<IntPtr>("PlayerContextFast", CharacterManager, 0xB0);
	vars.Resolver.Watch<int>("EventName", TimelineEventMediator, 0x20, 0x10, 0x20, 0xB4);

	current.View = "";
	current.PauseType = 0;
	current.StageName = "";
	current.GameClockTimerBit = 0;
	current.SwitchGameSceneName = "";
	current.JumpTargetMainSceneName = "";
    current.CurrentMainSceneName = "";
	current.EvnStageName = 0;
	current.TimelinePlayState = 1;
	current.EnemyHealth = 0;
	current.CharacterName = "";

	vars.Loading = false;
	vars.Permaload = false;
	vars.ShouldSplit = "";
	vars.GraceInv = "";
	vars.LeonInv = "";
	vars.GraceCloneInv = "";
	vars.ObjList = "";
	vars.LastCounter = 0;
	vars.RCCBattery = 0;
	vars.RRCEscape = 0;
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
	vars.ShouldSplit = "";
	vars.GraceInv = "";
	vars.LeonInv = "";
	vars.GraceCloneInv = "";
	vars.ObjList = "";
	vars.LastCounter = 0;
	vars.ChunkOldHealth = 0;
	vars.RCCBattery = 0;
	vars.RCCEscape = 0;
	vars.CompletedSplits.Clear();
}

update
{
	vars.Uhara.Update();

	if (current.PlayerContextFast != IntPtr.Zero) {
		string characterName = vars.Resolver.ReadString(current.PlayerContextFast + 0x40, 0x10, 0x14) ?? "";
		if (current.CharacterName != characterName) 
		vars.Uhara.Log("Character Name: " + characterName);
		current.CharacterName = characterName;
	}

	// Loading Time Bleed Fix Block
	if (current.ActiveEvents != IntPtr.Zero) {
		int size = vars.Resolver.Read<int>(current.ActiveEvents + 0x18);
		current.TimelinePlayState = 1;
		if (size > 0) {
			byte rawTPS = vars.Resolver.Read<byte>(current.ActiveEvents + 0x10, 0x20, 0xBC);
			if (rawTPS != 0) current.TimelinePlayState = rawTPS;
		}
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

	if (current.EventName == 450900 && old.PauseType == 1 && current.PauseType == 0) vars.Permaload = false;
	if (vars.ReturnedFromLoadEvents.Contains(current.EventName) && old.PauseType == 8 && current.PauseType == 0) {
		vars.Permaload = false;
	}

	if (old.PauseType == 0 && current.PauseType == 8) {
		vars.Loading = true;
	}
	if (old.PauseType != current.PauseType) vars.Uhara.Log("PauseType: " + current.PauseType);

	if (old.PlayerModeFade == 2 && current.PlayerModeFade == 3) {
		vars.Loading = false;
	}

	bool is64 = current.PauseType == 64 && current.StageName == "st10_005";
	if (is64) vars.Loading = true;

	if ((old.TimelinePlayState == 8 || old.TimelinePlayState == 10) && current.TimelinePlayState == 1
	|| current.PauseType == 66 || is64 && old.PauseType == 8 && current.PauseType == 0) {
		vars.Loading = false;
	}

	if (current.EventSaveListSize > old.EventSaveListSize && current.EventSaveList != IntPtr.Zero && current.EventSaveListSize > 0)
	{
		int eventID = vars.Resolver.Read<int>(current.EventSaveList + ((current.EventSaveListSize - 1) * 0x8) + 0x20, 0x10);
		current.EvnStageName = eventID;
	}

	// Inventory
	if ((current.PauseType == 0 || current.PauseType == 2) && current.Inventory != IntPtr.Zero)
	{
		string[] characterSlots = null;
		string oldInventory = "";
		IntPtr characterBase = IntPtr.Zero;
		int slotSize = 0;
		string characterLabel = "";

		if (current.CharacterName == "cp_A100") // Grace
		{
			characterSlots = new string[16];
			characterBase = vars.Resolver.Read<IntPtr>(current.Inventory + 0x48);
			slotSize = 16;
			oldInventory = vars.GraceInv;
			characterLabel = "Grace";
		}
		else if (current.CharacterName == "cp_A000") // Leon
		{
			characterSlots = new string[104];
			characterBase = vars.Resolver.Read<IntPtr>(current.Inventory + 0x78);
			slotSize = 104;
			oldInventory = vars.LeonInv;
			characterLabel = "Leon";
		}
		else if (current.Chapter == "FF_02" && current.CharacterName == "cp_A200") // Grace Clone
		{
			characterSlots = new string[4];
			characterBase = vars.Resolver.Read<IntPtr>(current.Inventory + 0xA8);
			slotSize = 4;
			oldInventory = vars.GraceCloneInv;
			characterLabel = "GraceClone";
		}

		if (characterSlots != null)
		{
			if (characterBase != IntPtr.Zero)
			{
				int characterPanelSize = Math.Min(vars.Resolver.Read<int>(characterBase + 0x48, 0x3C), slotSize);
				for (int i = 0; i < characterPanelSize; i++)
					characterSlots[i] = vars.Resolver.ReadString(characterBase + 0x48, 0x18, 0x30 + (i * 0x18), 0x10, 0x20, 0x10, 0x14) ?? "";
			}

			string[] oldSlots = oldInventory.Split('|');
			for (int i = 0; i < slotSize; i++)
			{
				string curID = characterSlots[i] ?? "";
				string oldItem = i < oldSlots.Length ? oldSlots[i] : "";
				if (curID == oldItem) continue;
				if (!string.IsNullOrEmpty(vars.ShouldSplit)) continue;

				string id = !string.IsNullOrEmpty(curID) && curID != "None" ? curID : oldItem;
				char suffix = !string.IsNullOrEmpty(curID) && curID != "None" ? 'A' : 'R';

				if (!string.IsNullOrEmpty(id))
				{
					vars.Uhara.Log(characterLabel + " Slot[" + i + "] " + (suffix == 'A' ? "ADDED" : "REMOVED") + ": " + id);
					vars.ShouldSplit = id + "_" + suffix;
				}
			}

			string newInventory = string.Join("|", characterSlots);

			if (current.CharacterName == "cp_A100")
				vars.GraceInv = newInventory;
			else if (current.CharacterName == "cp_A000")
				vars.LeonInv = newInventory;
			else if (current.Chapter == "FF_02" && current.CharacterName == "cp_A200")
				vars.GraceCloneInv = newInventory;
		}
	}

	// // Objectives Tracking
	if (current.ObjectiveController != IntPtr.Zero)
	{
		string[] objSlots = new string[4];
		int[] objCounter = new int[4];
		int maxCount = 4;

		int objCount = Math.Min(vars.Resolver.Read<int>(current.ObjectiveController + 0x10, 0x18), maxCount);

		for (int i = 0; i < objCount; i++)
		{
			IntPtr objData = vars.Resolver.Read<IntPtr>(current.ObjectiveController + 0x10, 0x10, 0x20 + (i * 0x8));
			if (objData != IntPtr.Zero)
			{
				objSlots[i] = vars.Resolver.ReadString(objData + 0x10, 0x10, 0x14) ?? "";
				objCounter[i] = vars.Resolver.Read<int>(objData + 0x38);
			}
			else
			{
				objSlots[i] = "";
				objCounter[i] = 0;
			}
		}

		string[] oldObjs = vars.ObjList.Split('|');
		int lastCounter = vars.LastCounter;

		for (int i = 0; i < maxCount; i++)
		{
			string curID   = objSlots[i] ?? "";
			string oldItem = i < oldObjs.Length ? oldObjs[i] : "";
			int newCounter = objCounter[i];

			if (curID != oldItem)
			{
				if (!string.IsNullOrEmpty(curID) && curID != "None")
				{
					vars.Uhara.Log("Objective Slot[" + i + "] ADDED: " + curID);
					if (string.IsNullOrEmpty(vars.ShouldSplit)) vars.ShouldSplit = curID + "_A";
				}
				else if (!string.IsNullOrEmpty(oldItem))
				{
					vars.Uhara.Log("Objective Slot[" + i + "] REMOVED: " + oldItem);
					if (string.IsNullOrEmpty(vars.ShouldSplit)) vars.ShouldSplit = oldItem + "_R";
				}
			}
			else if (!string.IsNullOrEmpty(curID) && newCounter > lastCounter)
			{
				if (string.IsNullOrEmpty(vars.ShouldSplit))
				{
					vars.Uhara.Log("Objective Slot[" + i + "] COUNTER: " + curID + " " + newCounter);
					vars.ShouldSplit = curID + "_C" + newCounter;
				} 
			}
		}

		int maxCounter = 0;
		for (int i = 0; i < maxCount; i++)
			if (objCounter[i] > maxCounter) maxCounter = objCounter[i];
		vars.LastCounter = maxCounter;

		vars.ObjList = string.Join("|", objSlots);
	}

	// Enemy Checks
	if (current.EnemyContextList != IntPtr.Zero && current.EnemyContextListArrayNum > 0)
	{
		for (int i = 0; i < current.EnemyContextListArrayNum; i++)
		{
			string kindID = vars.Resolver.ReadString(256, ReadStringType.UTF16, current.EnemyContextList + ((i * 0x8) + 0x20), 0x40, 0x10, 0x14);
			if (kindID != "cp_C100" && kindID != "cp_C610") 
			{
				continue;
			}

			int health = vars.Resolver.Read<int>(current.EnemyContextList + ((i * 0x8) + 0x20), 0x70, 0x10, 0x28);
			
			if (kindID == "cp_C100" && current.StageName == "st30_076")
			{
				current.EnemyHealth = health;
				if (current.EnemyHealth != old.EnemyHealth) vars.Uhara.Log("current.EnemyHealth: " + current.EnemyHealth);

				if (old.EnemyHealth > 0 && current.EnemyHealth == 0 && !vars.CompletedSplits.Contains("AtticChunk"))
					vars.ShouldSplit = "AtticChunk";
			}
			if (kindID == "cp_C610" && current.StageName == "st50_010")
			{
				current.EnemyHealth = health;
				if (current.EnemyHealth != old.EnemyHealth) vars.Uhara.Log("current.EnemyHealth: " + current.EnemyHealth);

				if (old.EnemyHealth > 0 && current.EnemyHealth == 0 && !vars.CompletedSplits.Contains("Commander"))
					vars.ShouldSplit = "Commander";
			}
		}
	}
}

split
{
	if (old.SwitchGameSceneName != current.SwitchGameSceneName && current.SwitchGameSceneName == "Chap5_04"
		&& !vars.CompletedSplits.Contains(current.SwitchGameSceneName) && settings.ContainsKey("BadEnding") && settings["BadEnding"] )
	{
		vars.CompletedSplits.Add(current.SwitchGameSceneName);
		return true;
	}

	if (current.EventName == 530600 && !vars.CompletedSplits.Contains("GoodEndingPhase1"))
	{
		vars.CompletedSplits.Add("GoodEndingPhase1");
		return true;
	}

	if (current.EventName == 530800 && !vars.CompletedSplits.Contains("GoodEndingPhase2"))
	{
		vars.CompletedSplits.Add("GoodEndingPhase2");
		return true;
	}

	if ((vars.ShouldSplit == "it60_00_115_A" || vars.ShouldSplit == "it60_00_118_A") && !vars.CompletedSplits.Contains("DetonatorItem2"))
	{
		vars.CompletedSplits.Add("DetonatorItem2");
		vars.ShouldSplit = "";
		return true;
	}

	if (old.EvnStageName != current.EvnStageName && !vars.CompletedSplits.Contains(current.EvnStageName.ToString()))
	{
		if (settings.ContainsKey(current.EvnStageName.ToString()) && settings[current.EvnStageName.ToString()]) 
		{
			vars.CompletedSplits.Add(current.EvnStageName.ToString());
			return true;
		}
	}

	if (!string.IsNullOrEmpty(vars.ShouldSplit)) {
		if (settings.ContainsKey(vars.ShouldSplit) && settings[vars.ShouldSplit] && !vars.CompletedSplits.Contains(vars.ShouldSplit)) 
		{
			vars.CompletedSplits.Add(vars.ShouldSplit);
			vars.ShouldSplit = "";
			return true;
		}

		if (current.StageName == "st30_056" && vars.ShouldSplit == "it60_00_055_R" && !vars.CompletedSplits.Contains("it60_00_055_R"))
		{
			vars.CompletedSplits.Add("it60_00_055_R");
			vars.Uhara.Log("DID I GET HERE???");
			vars.ShouldSplit = "";
			return true;
		}

		if (current.EvnStageName == 331900 && vars.ShouldSplit == "Ob_302_020_015_R" && !vars.CompletedSplits.Contains("Ob_302_020_015_R"))
		{
			if (settings["ABOb_302_020_015"] && !vars.CompletedSplits.Contains("ABOb_302_020_015"))
			{
				vars.CompletedSplits.Add("ABOb_302_020_015");
				vars.ShouldSplit = "";
				return true;
			}
		}

		if (vars.ShouldSplit == "it60_00_092_A") {
			if (vars.RCCBattery < 2) 
			{
				vars.RCCBattery++;
				string batteryKey = "it60_00_092_A_C" + vars.RCCBattery;
				if (settings.ContainsKey(batteryKey) && settings[batteryKey] && !vars.CompletedSplits.Contains(batteryKey)) 
				{
					vars.CompletedSplits.Add(batteryKey);
					vars.ShouldSplit = "";
					return true;
				}
			}
		}

		if (vars.ShouldSplit == "Ob_440_030_020_A") {
			if (vars.RCCEscape < 2)
			{
				vars.RCCEscape++;
				string rccEscape = "Ob_440_030_020_A_C" + vars.RCCEscape;
				if (settings.ContainsKey(rccEscape) && settings[rccEscape] && !vars.CompletedSplits.Contains(rccEscape)) 
				{
					vars.CompletedSplits.Add(rccEscape);
					vars.ShouldSplit = "";
					return true;
				}
			}	
		}
		vars.ShouldSplit = "";
	}
}

isLoading
{
    return  vars.bitCheck(current.GameClockTimerBit, vars.timers["LoadSpending"]) ||
            vars.bitCheck(current.GameClockTimerBit, vars.timers["EventSpending"]) ||
            vars.bitCheck(current.GameClockTimerBit, vars.timers["MovieSpending"]) ||
            current.View == "AppBoot" || current.View == "AppTitle" || current.View == "AppBenchmark" ||
            vars.Loading || vars.Permaload || current.PauseType == 1 || current.PauseType == 8 || current.PauseType == 24;
}

reset
{
	return settings["AutoReset"] && settings.ContainsKey("AutoReset") && old.View == "MainGame" && current.View == "AppTitle";
}

onReset
{
	vars.Loading = false;
	vars.Permaload = false;
	vars.ShouldSplit = "";
	vars.GraceInv = "";
	vars.LeonInv = "";
	vars.GraceCloneInv = "";
	vars.ObjList = "";
	vars.LastCounter = 0;
	vars.ChunkOldHealth = 0;
	vars.RCCBattery = 0;
	vars.CompletedSplits.Clear();
}

exit
{
	timer.IsGameTimePaused = true;
}
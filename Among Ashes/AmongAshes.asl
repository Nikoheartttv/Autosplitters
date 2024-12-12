state("Among Ashes", "v1.0.1h / v1.0.2") { 
	bool gameStarted : "GameAssembly.dll", 0x24DA208, 0xB8, 0x0, 0x54;
	int currentMainStoryEvent : "GameAssembly.dll", 0x24C7858, 0xB8, 0x0, 0x28;
	bool RealWorldInCutscene : "GameAssembly.dll", 0x24E4870, 0xB8, 0x0, 0x42;
	bool NightCallInCutscene : "GameAssembly.dll", 0x24E47F8, 0xB8, 0x0, 0x42;
	int MainMenuState : "GameAssembly.dll", 0x24DA208, 0xB8, 0x0, 0xE8;
	int TLGameState : "GameAssembly.dll", 0x24A6470, 0xB8, 0x0, 0x20;
	int FinalBossWeakspots : "GameAssembly.dll", 0x24C4E28, 0xB8, 0x0, 0x38;
}

state("Among Ashes", "v1.0.2b") { 
	bool gameStarted : "GameAssembly.dll", 0x24DA218, 0xB8, 0x0, 0x54;
	int currentMainStoryEvent : "GameAssembly.dll", 0x24C7868, 0xB8, 0x0, 0x28;
	bool RealWorldInCutscene : "GameAssembly.dll", 0x24E4880, 0xB8, 0x0, 0x42;
	bool NightCallInCutscene : "GameAssembly.dll", 0x24E4808, 0xB8, 0x0, 0x42;
	int MainMenuState : "GameAssembly.dll", 0x24DA218, 0xB8, 0x0, 0xE8;
	int TLGameState : "GameAssembly.dll", 0x24A6480, 0xB8, 0x0, 0x20;
	int FinalBossWeakspots : "GameAssembly.dll", 0x24C4E38, 0xB8, 0x0, 0x40;
}

state("Among Ashes", "v1.0.2c") { 
	bool gameStarted : "GameAssembly.dll", 0x24DA218, 0xB8, 0x0, 0x54;
	int currentMainStoryEvent : "GameAssembly.dll", 0x24C7868, 0xB8, 0x0, 0x28;
	bool RealWorldInCutscene : "GameAssembly.dll", 0x24E4880, 0xB8, 0x0, 0x42;
	bool NightCallInCutscene : "GameAssembly.dll", 0x24E4808, 0xB8, 0x0, 0x42;
	int MainMenuState : "GameAssembly.dll", 0x24DA218, 0xB8, 0x0, 0xE8;
	int TLGameState : "GameAssembly.dll", 0x24A6480, 0xB8, 0x0, 0x20;
	int FinalBossWeakspots : "GameAssembly.dll", 0x24C4E38, 0xB8, 0x0, 0x40;
}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Among Ashes";
	vars.Helper.LoadSceneManager = true;

	dynamic[,] _settings =
	{
		{ "Splits", true, "Splits", null },
			{ "MSE_3", true, "Reach Demon Blood Boss", "Splits" },
			{ "MSE_10", true, "Night Call Downloaded", "Splits" },
			{ "Item_Key_Katherine_0", true, "Picked up Katherine's Room Key", "Splits" },
			{ "Item_Key_WWF2_0", true, "Pick Up West Wing Key", "Splits" },
			{ "MSE_11", true, "3 - Baton the dead lady", "Splits" },
			{ "Item_Key_Kitchen_0", true, "Office Lock Puzzle Complete & Kitchen Key Get", "Splits" },
			{ "Item_Bloodstained_Book_0", true, "Pick Up Bloodstained Book", "Splits" },
			{ "Item_MorgueKey_Bigfoot_0", true, "Opened Lab & Pick Up Morgue Key", "Splits" },
			{ "Item_MorgueKey_Fairy_0", false, "Pick Up Fairy Key", "Splits" },
			{ "Item_MorgueKey_Vampire_0", false, "Pick Up Vampire Key", "Splits" },
			{ "Item_MorgueKey_Mummy_0", false, "Pick Up Mummy Key", "Splits" },
			{ "Item_MorgueKey_Ghost_0", false, "Pick Up Ghost Key", "Splits" },
			{ "Item_Key_Gardens_0", true, "Lab Box Puzzle Complete & Garden Key Pick Up", "Splits" },
			{ "Item_Key_Servants_0", true, "Pick Up Servants Key", "Splits" },
			{ "Item_Key_Greenhouse_0", true, "Pick Up Greenhouse Key", "Splits" },
			{ "Enemy_FRANCIS_BOSS", true, "Killed Dr. Stoker in Greenhouse", "Splits" },
			{ "TLGameDone", true, "Tree of Life Game Done", "Splits" }, 
			{ "Item_Lighter_0", true, "Picked up Lighter from Music Box & Get In-Game", "Splits"},
			{ "Item_Key_Ankh_0", true, "Picked up Anhk key", "Splits" },
			{ "Item_LockerKey_Red_0", true, "Pick Up Underground Locker Key Red", "Splits" },
			{ "Item_LockerKey_Green_0", true, "Pick Up Underground Locker Key Green", "Splits" },
			{ "Item_Key_Amalia_0", true, "Pick up Amalia's Key", "Splits" },
			{ "LookingAtFingermanFNC", true, "Fake Night Call Ended & Looking at Finger Man", "Splits" },
			{ "Item_LockerKey_Blue_0", true, "Pick up Locker Key Blue", "Splits" },
			{ "Item_Key_Black_0", true, "Pick up Black Key", "Splits" },
			{ "FinalBossDead", true, "Final Boss Dead", "Splits" }, 
			{ "MSE_61", true, "End Credits", "Splits" },
	};
	vars.Helper.Settings.Create(_settings);

	vars.Helper.AlertLoadless();
	vars.CompletedSplits = new List<string>();
}

init
{
	string gameVersion = vars.Helper.ReadString(32, ReadStringType.UTF8, "UnityPlayer.dll", 0x1CA4940, 0x3D0);
	vars.Log(gameVersion);

	switch (gameVersion)
	{
	    case "v1.0.1h": version = "v1.0.1h / v1.0.2"; break;
		case "v1.0.2": version = "v1.0.1h / v1.0.2"; break;
		case "v1.0.2b": version = "v1.0.2b"; break;
		case "v1.0.2c": version = "v1.0.2c"; break;
    }

	vars.MainMenuTransition = false;
	vars.NoInCutsene = false;
	current.activeScene = "";
	vars.BossFightActive = false;
	vars.AfterFinalBossCutsceneFix = false;
}

onStart
{
	vars.CompletedSplits.Clear();
	vars.MainMenuState = false;
	timer.IsGameTimePaused = true;
}

start
{
	return current.gameStarted == true && current.MainMenuState == 7 && old.RealWorldInCutscene == false && current.RealWorldInCutscene == true;
}

update
{
	switch(version)
	{
		case "v1.0.1h / v1.0.2": 
			current.Items = vars.Helper.ReadList<IntPtr>("GameAssembly.dll", 0x24E0788, 0xB8, 0x0, 0x68);
			current.Enemies = vars.Helper.ReadList<IntPtr>("GameAssembly.dll", 0x24E0788, 0xB8, 0x0, 0x38);
			break;
		case "v1.0.2b":
			current.Items = vars.Helper.ReadList<IntPtr>("GameAssembly.dll", 0x24E0798, 0xB8, 0x0, 0x68);
			current.Enemies = vars.Helper.ReadList<IntPtr>("GameAssembly.dll", 0x24E0798, 0xB8, 0x0, 0x38);
			break;
		default:
			break;
	}

	current.Items = vars.Helper.ReadList<IntPtr>("GameAssembly.dll", 0x24E0798, 0xB8, 0x0, 0x68);
	current.Enemies = vars.Helper.ReadList<IntPtr>("GameAssembly.dll", 0x24E0798, 0xB8, 0x0, 0x38);
	
	if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Active.Name))	current.activeScene = vars.Helper.Scenes.Active.Name;
	if(current.activeScene != old.activeScene) vars.Log("active: Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");
	if (current.MainMenuState == 7 && old.RealWorldInCutscene == false && current.RealWorldInCutscene == true) vars.MainMenuTransition = true;
	if (vars.NoInCutsene == false && current.currentMainStoryEvent == 17)
	{
		if (current.RealWorldInCutscene == true) vars.NoInCutsene = true;
	}
	if (vars.NoInCutsene == true && current.currentMainStoryEvent == 19 && old.RealWorldInCutscene == true && current.RealWorldInCutscene == false) vars.NoInCutsene = false;
	if (vars.NoInCutsene == false && current.currentMainStoryEvent == 30)
	{
		if (current.RealWorldInCutscene == true) vars.NoInCutsene = true;
	}
	if (vars.NoInCutsene == true && old.RealWorldInCutscene == true && current.RealWorldInCutscene == false) vars.NoInCutsene = false;
	if (old.FinalBossWeakspots == 0 && current.FinalBossWeakspots == 8) vars.BossFightActive = true;
	if (vars.CompletedSplits.Contains("FinalBossDead") && current.NightCallInCutscene == true && old.RealWorldInCutscene == true && current.RealWorldInCutscene == false) 
	{
		vars.AfterFinalBossCutsceneFix = true;
		vars.Log("End Cutscene Fix is active");
	}
}

split
{
	// Main Splits
	if (current.currentMainStoryEvent == 3 || current.currentMainStoryEvent == 10 || current.currentMainStoryEvent == 11 
		|| current.currentMainStoryEvent == 43 || current.currentMainStoryEvent == 61)
	{
		if (settings["MSE_" + current.currentMainStoryEvent.ToString()] && old.currentMainStoryEvent != current.currentMainStoryEvent && !vars.CompletedSplits.Contains("MSE_" + current.currentMainStoryEvent.ToString()))
		{
			vars.CompletedSplits.Add("MSE_" + current.currentMainStoryEvent.ToString());
			vars.Log("--- SPLIT 1");
			return true;
		}
	}

	// Items Splits
	if (old.Items.Count < current.Items.Count)
	{
		var len = vars.Helper.Read<int>(current.Items[current.Items.Count - 1] + 0x10);
		var name = vars.Helper.ReadString(len * 2, ReadStringType.UTF16, current.Items[current.Items.Count - 1] + 0x14);
		vars.Log(name);
		if (!vars.CompletedSplits.Contains("Item_" + name)) 
		{
			vars.CompletedSplits.Add("Item_" + name);
			vars.Log("--- SPLIT 2");
			return settings["Item_" + name];
		}
	}

	// Enemies Splits (Dr. Stoker Only)
	if (old.Enemies.Count < current.Enemies.Count)
	{
		var len = vars.Helper.Read<int>(current.Enemies[current.Enemies.Count - 1] + 0x10);
		var name = vars.Helper.ReadString(len * 2, ReadStringType.UTF16, current.Enemies[current.Enemies.Count - 1] + 0x14);
		vars.Log(name);
		if (!vars.CompletedSplits.Contains("Enemy_" + name) && name == "FRANCIS_BOSS") 
		{
			vars.CompletedSplits.Add("Enemy_" + name);
			vars.Log("--- SPLIT 3");
			return settings["Enemy_" + name];
		}
	}

	// Tree of Life Game Done Split
	if (settings["TLGameDone"] && old.TLGameState != 4 && current.TLGameState == 4 && !vars.CompletedSplits.Contains("TLGameDone"))
		{
			vars.CompletedSplits.Add("TLGameDone");
			vars.Log("--- SPLIT 4");
			return true;
		}
	
	// Fake Night Call & Looking At Fingerman Split
	if (settings["LookingAtFingermanFNC"] && (current.currentMainStoryEvent == 51 || current.currentMainStoryEvent == 52) && 
		old.RealWorldInCutscene == false && current.RealWorldInCutscene == true && !vars.CompletedSplits.Contains("LookingAtFingermanFNC"))
		{
			vars.CompletedSplits.Add("LookingAtFingermanFNC");
			vars.Log("--- SPLIT 4");
			return true;
		}
	
	// Final Boss Split
	if (settings["FinalBossDead"] && vars.BossFightActive == true && old.FinalBossWeakspots <= 2 && current.FinalBossWeakspots <= 1
		&& old.NightCallInCutscene == false && current.NightCallInCutscene == true && !vars.CompletedSplits.Contains("FinalBossDead"))
		{
			vars.CompletedSplits.Add("FinalBossDead");
			vars.Log("--- SPLIT 5");
			return true;
		}
}


isLoading
{
	if (vars.NoInCutsene == true) return false;
	else if (vars.AfterFinalBossCutsceneFix == true) return current.RealWorldInCutscene;
	else return current.activeScene == "LoadingScreen" || current.RealWorldInCutscene || current.NightCallInCutscene;
}
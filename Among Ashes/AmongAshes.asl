state("Among Ashes"){}

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
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
		var g = mono["Global"];
		var gsm = mono["GameStateManager"];
		var mm = mono["MainMenu"];
		var pcrw = mono["PlayerControl_RealWorld"];
		var pcnc = mono["PlayerControl_NightCall"];
		var pcdb = mono["PlayerControl_DemonBlood"];
		var ncm = mono["NightCallManager"];
		var tl = mono["TL_Game"];
		var fbm = mono["FinalBossManager"];

		vars.Helper["gameStarted"] = mm.Make<bool>("instance", "gameStarted");
		vars.Helper["MainMenuState"] = mm.Make<int>("instance", "currentState");
		vars.Helper["RealWorldInCutscene"] = pcrw.Make<bool>("instance", "inCutscene");
		vars.Helper["NightCallEnemies"] = ncm.MakeList<IntPtr>("instance", "killedEnemies");
		vars.Helper["NightCallItems"] = ncm.MakeList<IntPtr>("instance", "pickedPickUps");
		vars.Helper["currentMainStoryEvent"] = gsm.Make<int>("instance", "currentMainStoryEvent");
		vars.Helper["TreeOfLifeGameState"] = tl.Make<int>("instance", "currentState");
		vars.Helper["FinalBossWeakspots"] = fbm.Make<int>("instance", "remainingWeakspots");
		vars.Helper["NightCallInCutscene"] = pcnc.Make<bool>("instance", "inCutscene");
		
		return true;
	});


	vars.MainMenuTransition = false;
	vars.NoInCutsene = false;
	current.activeScene = "";
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
	if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Active.Name))	current.activeScene = vars.Helper.Scenes.Active.Name;
	if(current.activeScene != old.activeScene) vars.Log("active: Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");
	
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
}

split
{
	// // Main Splits
	if (current.currentMainStoryEvent == 3 || current.currentMainStoryEvent == 10 || current.currentMainStoryEvent == 11 
		|| current.currentMainStoryEvent == 43 || current.currentMainStoryEvent == 61)
	{
		if (settings["MSE_" + current.currentMainStoryEvent.ToString()] && old.currentMainStoryEvent != current.currentMainStoryEvent && !vars.CompletedSplits.Contains("MSE_" + current.currentMainStoryEvent.ToString()))
		{
			vars.CompletedSplits.Add("MSE_" + current.currentMainStoryEvent.ToString());
			return true;
		}
	}

	// // Items Splits
	if (vars.Helper["NightCallItems"].Current.Count > vars.Helper["NightCallItems"].Old.Count)
	{
		string name = vars.Helper.ReadString(false, vars.Helper["NightCallItems"].Current[vars.Helper["NightCallItems"].Current.Count - 1]);
		if (!vars.CompletedSplits.Contains("Item_" + name)) 
		{
			vars.CompletedSplits.Add("Item_" + name);
			if (settings["Item_" + name]) return true;
		}
	}

	// // Enemies Splits (Dr. Stoker Only)
	if (vars.Helper["NightCallEnemies"].Current.Count > vars.Helper["NightCallEnemies"].Old.Count)
	{
		string name = vars.Helper.ReadString(false, vars.Helper["NightCallEnemies"].Current[vars.Helper["NightCallEnemies"].Current.Count - 1]);
		if (!vars.CompletedSplits.Contains("Enemy_" + name) && name == "FRANCIS_BOSS") 
		{
			vars.CompletedSplits.Add("Enemy_" + name);
			if (settings["Enemy_" + name]) return true;
		}
	}

	// Tree of Life Game Done Split
	if (settings["TLGameDone"] && old.TreeOfLifeGameState != 4 && current.TreeOfLifeGameState == 4 && !vars.CompletedSplits.Contains("TLGameDone"))
		{
			vars.CompletedSplits.Add("TLGameDone");
			return true;
		}
	
	// Fake Night Call & Looking At Fingerman Split
	if (settings["LookingAtFingermanFNC"] && (current.currentMainStoryEvent == 51 || current.currentMainStoryEvent == 52) && 
		old.RealWorldInCutscene == false && current.RealWorldInCutscene == true && !vars.CompletedSplits.Contains("LookingAtFingermanFNC"))
		{
			vars.CompletedSplits.Add("LookingAtFingermanFNC");
			return true;
		}
	
	// Final Boss Split
	if (settings["FinalBossDead"] && old.FinalBossWeakspots >= 1 && current.FinalBossWeakspots <= 1 
		&& old.NightCallInCutscene == false && current.NightCallInCutscene == true && !vars.CompletedSplits.Contains("FinalBossDead"))
		{
			vars.CompletedSplits.Add("FinalBossDead");
			return true;
		}
}


isLoading
{
	if (vars.NoInCutsene == true) return false;
	else return current.activeScene == "LoadingScreen" || current.RealWorldInCutscene || current.NightCallInCutscene;
}
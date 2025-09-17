state("BadCheese-Win64-Shipping") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	Assembly.Load(File.ReadAllBytes("Components/uhara8")).CreateInstance("Main");
	vars.Helper.GameName = "Bad Cheese";
	vars.Helper.AlertLoadless();

	dynamic[,] _settings =
	{
		{ "StartTiming", true, "Start Timing", null },
			{ "FromSettings", false, "From Settings (Main Menu → Steamboat, v1.0 only)", "StartTiming" },
			{ "Creepong", false, "Creepong Start (Main Menu → Kid's Bedroom)", "StartTiming" },
		{ "CreepongSplits", true, "Creepong Splits", null },
			{ "CreepongLevel1", true, "Level 1", "CreepongSplits" },
			{ "CreepongLevel2", true, "Level 2", "CreepongSplits" },
			{ "CreepongLevel3", true, "Level 3", "CreepongSplits" },
			{ "CreepongBoss",  true, "Boss (Win)", "CreepongSplits" },
		{ "ChapterSplits", true, "Chapter Splits", null },
			{ "L_01Hallway", true, "Hallway", "ChapterSplits" },
			{ "L_02Kitchen", true, "Kitchen", "ChapterSplits" },
			{ "L_Basement", true, "Basement", "ChapterSplits" },
			{ "L_06KidsRoom", true, "Kid's Bedroom", "ChapterSplits" },
			{ "L_PrototypeLevel", true, "Daddy's Bedroom", "ChapterSplits" },
			{ "L_09Steamboat", true, "Steamboat", "ChapterSplits" },
			{ "L_Bathroom", true, "Bathroom", "ChapterSplits" },
			{ "L_ScaryTimes", true, "Daddy Scary Times", "ChapterSplits" },
			{ "End", true, "Cheese World (End on Rolling Credits from Camera)", "ChapterSplits" },
	};

	vars.Helper.Settings.Create(_settings);
	vars.CompletedSplits = new List<string>();
}

init
{
	IntPtr gWorld = vars.Helper.ScanRel(3, "48 8B 1D ???????? 48 85 DB 74 ?? 41 B0 01");
	IntPtr gEngine = vars.Helper.ScanRel(3, "48 8B 0D ???????? 66 0F 5A C9 E8");
	IntPtr fNames = vars.Helper.ScanRel(7, "8B D9 74 ?? 48 8D 15 ???????? EB");
	IntPtr gSyncLoadCount = vars.Helper.ScanRel(5, "89 43 60 8B 05 ?? ?? ?? ??");

	if (gWorld == IntPtr.Zero || gEngine == IntPtr.Zero || fNames == IntPtr.Zero)
		throw new Exception("Not all required addresses could be found by scanning.");

	vars.FNameToString = (Func<ulong, string>)(fName =>
	{
		var nameIdx  = (fName & 0x000000000000FFFF) >> 0x00;
		var chunkIdx = (fName & 0x00000000FFFF0000) >> 0x10;
		var number   = (fName & 0xFFFFFFFF00000000) >> 0x20;

		IntPtr chunk = vars.Helper.Read<IntPtr>(fNames + 0x10 + (int)chunkIdx * 0x8);
		IntPtr entry = chunk + (int)nameIdx * sizeof(short);

		int length   = vars.Helper.Read<short>(entry) >> 6;
		string name  = vars.Helper.ReadString(length, ReadStringType.UTF8, entry + sizeof(short));

		return number == 0 ? name : name + "_" + number;
	});

	var Events = vars.Uhara.CreateTool("UnrealEngine", "Events");

	// asl-help Helpers
	vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x18);

	// Uhaha Helpers - Load Transitions
	vars.Helper["ReverseTransition"] = vars.Helper.Make<ulong>(Events.FunctionFlag("", "", "ReverseTransitionValue__UpdateFunc"));
	vars.Helper["ScreenTransition"] = vars.Helper.Make<ulong>(Events.FunctionFlag("", "", "ScreenTransitionTimeline__UpdateFunc"));
	vars.Helper["MouthOfFearFadeOut"] = vars.Helper.Make<ulong>(Events.FunctionFlag("BP_MouthOfFear_C", "BP_MouthOfFear_C", "EndTimeline__FinishedFunc"));
	vars.Helper["BathroomMazeTransition"] = vars.Helper.Make<ulong>(Events.FunctionFlag("BP_ExitRoom_C", "BP_ExitRoom_C", "ExecuteUbergraph_BP_ExitRoom"));
	vars.Helper["CheesegateTransition"] = vars.Helper.Make<ulong>(Events.FunctionFlag("BP_Cheesegate_C", "BP_Cheesegate_C", "BndEvt__BP_Cheesegate_EndLevelCol_K2Node_ComponentBoundEvent_1_ComponentBeginOverlapSignature__DelegateSignature"));
	vars.Helper["LevelEndBoxAudio"] = vars.Helper.Make<ulong>(Events.FunctionFlag("BP_LevelEndBox_C", "BP_LevelEndBox_C", "PlayAudio"));
	vars.Helper["CreepongStart"] = vars.Helper.Make<ulong>(Events.FunctionFlag("BP_PongMap_C", "TransitionMap_BP_PongMap_C_CAT", "PlayLevelTransitionAnimation"));
	vars.Helper["CreepongWin"] = vars.Helper.Make<ulong>(Events.FunctionFlag("BP_PongGame2_C", "BP_PongGame2_C", "BossKillEvent"));
	vars.Helper["CreepongNextLevel"] = vars.Helper.Make<ulong>(Events.FunctionFlag("BP_PongMap_C", "TransitionMap_BP_PongMap_C_CAT", "*Transition__FinishedFunc"));
	vars.Helper["CreepongShowLevel"] = vars.Helper.Make<ulong>(Events.FunctionFlag("BP_PongGame2_C", "BP_PongGame2_C", "ShowLevelName"));

	current.World = "";
	vars.NowLoading = true;
}

update
{
	vars.Helper.Update();
	vars.Helper.MapPointers();

	var world = vars.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None")
		current.World = world;

	if (old.World != current.World)
		vars.Log("World: " + current.World);

	if (current.ReverseTransition != old.ReverseTransition && current.ReverseTransition != 0)
		vars.NowLoading = false;
	else if ((current.ScreenTransition != old.ScreenTransition && current.ScreenTransition != 0)
			|| (current.MouthOfFearFadeOut != old.MouthOfFearFadeOut && current.MouthOfFearFadeOut != 0)
			|| (current.BathroomMazeTransition != old.BathroomMazeTransition && current.BathroomMazeTransition != 0)
			|| (current.CheesegateTransition != old.CheesegateTransition && current.CheesegateTransition != 0))
		vars.NowLoading = true;
}

start
{
	if (settings["FromSettings"] && old.World == "L_MainMenu" && current.World == "L_09Steamboat") return true;
	if (settings["Creepong"] && current.CreepongStart != old.CreepongStart && current.CreepongStart != 0) return true;

	return old.World == "L_MainMenu" && current.World == "L_01Hallway";
}

onStart
{
	if (!settings["Creepong"])
	{
		timer.IsGameTimePaused = true;
		vars.NowLoading = true;
	}

	vars.CompletedSplits.Clear();

	// Track Creepong progress
	vars.CreepongLevel = 1;
	vars.CreepongPendingSplit = false;
}

split
{
	// --- Normal chapter splits ---
	if (old.World != current.World && current.World != "L_MainMenu" && settings[old.World] && !vars.CompletedSplits.Contains(old.World))
	{
		vars.Log("Split: " + old.World);
		vars.CompletedSplits.Add(old.World);
		if (settings[old.World]) return true;
	}

	if (settings["End"] && current.World == "L_Credits" && (old.LevelEndBoxAudio != current.LevelEndBoxAudio && current.LevelEndBoxAudio != 0) && !vars.CompletedSplits.Contains("End"))
	{
		vars.Log("Split: End");
		vars.CompletedSplits.Add("End");
		return true;
	}

	// --- CREEPONG SPLITS ---
	if (settings["Creepong"])
	{
		// Transition finished → waiting for ShowLevel
		if (current.CreepongNextLevel != old.CreepongNextLevel && current.CreepongNextLevel != 0)
		{
			vars.CreepongPendingSplit = true;
		}

		// ShowLevel right after transition → split if setting enabled
		if (vars.CreepongPendingSplit && current.CreepongShowLevel != old.CreepongShowLevel && current.CreepongShowLevel != 0)
		{
			vars.CreepongPendingSplit = false;
			if (vars.CreepongLevel >= 1 && vars.CreepongLevel <= 3 && settings["CreepongLevel" + vars.CreepongLevel]) return true;
			vars.CreepongLevel++;
		}

		// Final boss kill
		if (current.CreepongWin != old.CreepongWin && current.CreepongWin != 0 && vars.CreepongLevel == 4)
		{
			vars.Log("Creepong Boss Win");
			if (settings["CreepongBoss"]) return true;
		}
	}
}

isLoading
{
	return vars.NowLoading;
}

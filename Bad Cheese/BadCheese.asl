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
			{ "FullRun", true, "Full Run", "StartTiming" },
			{ "FromSettings", false, "From Settings (Loads into Steamboat)", "StartTiming" },
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
	{
		const string Msg = "Not all required addresses could be found by scanning.";
		throw new Exception(Msg);
	}

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
	IntPtr MusicBox = Events.InstancePtr("BP_MusicBoxActor_C", "BP_MusicBoxActor_C");
	// IntPtr Objective = Events.InstancePtr("WBP_Objective_C", "WBP_Objective_C");
	// WBP_Objective_C -> LocTextObjectiveMessage -> TextStruct.Key["AllocatorInstance"]
	// vars.Helper["ObjectiveName"] = vars.Helper.MakeString(Objective, 0x2E8, 0x2F0, 0x0);

	// asl-help Helpers
	vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x18);

	// Uhaha Helpers - Load Transitions
	vars.Helper["ReverseTransition"] = vars.Helper.Make<ulong>(Events.FunctionFlag("", "", "ReverseTransitionValue__UpdateFunc"));
	vars.Helper["ScreenTransition"] = vars.Helper.Make<ulong>(Events.FunctionFlag("", "", "ScreenTransitionTimeline__UpdateFunc"));
	vars.Helper["MouthOfFearFadeOut"] = vars.Helper.Make<ulong>(Events.FunctionFlag("BP_MouthOfFear_C", "BP_MouthOfFear_C", "EndTimeline__FinishedFunc"));
	vars.Helper["BathroomMazeTransition"] = vars.Helper.Make<ulong>(Events.FunctionFlag("BP_ExitRoom_C", "BP_ExitRoom_C", "ExecuteUbergraph_BP_ExitRoom"));
	vars.Helper["CheesegateTransition"] = vars.Helper.Make<ulong>(Events.FunctionFlag("BP_Cheesegate_C", "BP_Cheesegate_C", "ExecuteUbergraph_BP_Cheesegate"));
	vars.Helper["LevelEndBoxAudio"] = vars.Helper.Make<ulong>(Events.FunctionFlag("BP_LevelEndBox_C", "BP_LevelEndBox_C", "PlayAudio"));

	// Uhaha Helpers - Death Jumpscares
	// vars.Helper["DaddyDeathScare"] = vars.Helper.Make<ulong>(Events.FunctionFlag("BP_DaddyDeathscare_C", "BP_DaddyDeathscare_C", "ExecuteUbergraph_BP_DaddyDeathscare"));
	// vars.Helper["EggDaddyDeathScare"] = vars.Helper.Make<ulong>(Events.FunctionFlag("BP_EggDaddyDeathscare_C", "BP_EggDaddyDeathscare_C", "ExecuteUbergraph_BP_EggDaddyDeathscare"));
	
	// Uhaha Helpers - End Game
	// vars.Helper["RollCredits"] = vars.Helper.Make<ulong>(Events.FunctionFlag("BP_CreditsCamera_C", "BP_CreditsCamera_C", "RollCredits"));

	current.World = "";
	vars.NowLoading = true;
}

update
{
	vars.Helper.Update();
	vars.Helper.MapPointers();

	var world = vars.FNameToString(current.GWorldName);
	if (world != null && world != "None") current.World = world;
	if (old.World != current.World) vars.Log("World: " + current.World);
	if (current.ReverseTransition != old.ReverseTransition && current.ReverseTransition != 0) vars.NowLoading = false;
	if (current.ScreenTransition != old.ScreenTransition && current.ScreenTransition != 0) vars.NowLoading = true;
	if (current.MouthOfFearFadeOut != old.MouthOfFearFadeOut && current.MouthOfFearFadeOut != 0) vars.NowLoading = true;
	if (current.BathroomMazeTransition != old.BathroomMazeTransition && current.BathroomMazeTransition != 0) vars.NowLoading = true;
	if (current.CheesegateTransition != old.CheesegateTransition && current.CheesegateTransition != 0) vars.NowLoading = true;
	// if (current.DaddyDeathScare != old.DaddyDeathScare && current.DaddyDeathScare != 0) vars.NowLoading = true;
	// if (current.EggDaddyDeathScare != old.EggDaddyDeathScare && current.EggDaddyDeathScare != 0) vars.NowLoading = true;
	// if (old.ObjectiveName != current.ObjectiveName) vars.Log("Objective: " + current.ObjectiveName);
	// if (old.RollCredits != current.RollCredits && current.RollCredits != 0) vars.Log("RollCredits");
	// if (old.LevelEndBoxAudio != current.LevelEndBoxAudio && current.LevelEndBoxAudio != 0) vars.Log("LevelEndBoxAudio");
}

start
{
	return (settings["FullRun"] && old.World == "L_MainMenu" && current.World == "L_01Hallway")
	    || (settings["FromSettings"] && old.World == "L_MainMenu" && current.World == "L_09Steamboat");
}

onStart
{
	timer.IsGameTimePaused = true;
	vars.NowLoading = true;
	vars.CompletedSplits.Clear();
}

split
{
	// if (old.ObjectiveName != current.ObjectiveName && settings[current.ObjectiveName] && !vars.CompletedSplits.Contains(current.ObjectiveName))
	// {
	//     vars.Log("Split: " + current.ObjectiveName);
	//     vars.CompletedSplits.Add(current.ObjectiveName);
	//     if (settings[current.ObjectiveName]) return true;
	// }
	if (old.World != current.World && current.World != "L_MainMenu" && settings[old.World] && !vars.CompletedSplits.Contains(old.World))
	{
		vars.Log("Split: " + old.World);
		vars.CompletedSplits.Add(old.World);
		if (settings[old.World]) return true;
	}
	if (settings["End"] && current.World == "L_Credits" && (old.LevelEndBoxAudio != current.LevelEndBoxAudio && current.LevelEndBoxAudio != 0) && !vars.CompletedSplits.Contains("End"))
	{
		vars.Log("Split: End" );
		vars.CompletedSplits.Add("End");
		return true;
	}
}

isLoading
{
	return vars.NowLoading;
}
state("SwordOfTheSea-Win64-Shipping") {}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
    Assembly.Load(File.ReadAllBytes("Components/uhara8")).CreateInstance("Main");
	vars.Helper.GameName = "Sword of the Sea";
    vars.Helper.AlertLoadless();

	dynamic[,] _settings =
	{
		{ "AutoReset", false, "Auto Reset when returning to Main Menu", null },
		{ "ILMode", false, "Individual Level Start", null },
		{ "Chapter Splits", true, "Chapter Splits", null },
			{ "VeiledSea",       true, "Veiled Sea",         "Chapter Splits" },
			{ "LostGrotto",      true, "Lost Grotto",        "Chapter Splits" },
			{ "ForbiddenValley", true, "Forbidden Valley",   "Chapter Splits" },
			{ "ShadowTundra",    true, "Shadow Tundra",      "Chapter Splits" },
			{ "FrigidChasm",     true, "Frozen Drifts",      "Chapter Splits" },
			{ "SacredRiver",     true, "Sacred River",       "Chapter Splits" },
			{ "BoilingCavern",   true, "Boiling Cavern",     "Chapter Splits" },
			{ "BossMasterLevel", true, "Sky Abyss",          "Chapter Splits" },
	};

	vars.Helper.Settings.Create(_settings);
	vars.CompletedSplits = new HashSet<string>();
}

init
{
    IntPtr gWorld = vars.Helper.ScanRel(3, "48 8B 1D ???????? 48 85 DB 74 ?? 41 B0 01");
    IntPtr gEngine = vars.Helper.ScanRel(3, "48 8B 0D ???????? 41 BE ???????? 41 3B");
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
	IntPtr IntroCutscene = Events.InstancePtr("Intro_DirectorBP_C", "Intro_DirectorBP_C");
	// IntPtr VeiledSeaCutscene = Events.FunctionFlag("OceanSeed_BP_C", "MiniIchorPool_BP_C", "BndEvt__MiniIchorPool_BP_SwordStabInteractionComponent_BP_K2Node_ComponentBoundEvent_0_OnAnimToPointBeginEvent__DelegateSignature");

	// ASL-Help helpers
    vars.Helper["GSync"] = vars.Helper.Make<bool>(gSyncLoadCount);
    vars.Helper["GWorldName"] 				= vars.Helper.Make<ulong>(gWorld, 0x18);
    vars.Helper["CleanseEvents"]      = vars.Helper.Make<IntPtr>(gEngine, 0x10A8, 0x258, 0x490);
    vars.Helper["CleanseEventsCount"] = vars.Helper.Make<int>(gEngine, 0x10A8, 0x258, 0x498);
    vars.Helper["GWorldName"]         = vars.Helper.Make<ulong>(gWorld, 0x18);

	// GEngine -> GameInstance -> LoadingScreen -> bIsEnabled
	vars.Helper["LoadingScreen"] 			= vars.Helper.Make<bool>(gEngine, 0x10A8, 0x330, 0x0D9);
	vars.Helper["LoadingScreen"].FailAction	= MemoryWatcher.ReadFailAction.SetZeroOrNull;
	// vars.Helper["VeiledSeaCutsceneActivate"] = vars.Helper.Make<ulong>(VeiledSeaCutscene);

	// Uhara8 Helpers
	vars.Helper["IntroCutsceneStatus"] = vars.Helper.Make<bool>(IntroCutscene, 0x38, 0x2A8);
	vars.Helper["EndCutscene"] = vars.Helper.Make<ulong>(Events.FunctionFlag("Ending_A_DirectorBP_C", "Ending_A_DirectorBP_C", "SequenceEvent__ENTRYPOINTEnding_A_DirectorBP"));

    current.World = "";
}

start
{
	if (settings["ILMode"])
	{
		return current.World != "MainMenu" && old.LoadingScreen && !current.LoadingScreen;
	}
	else return current.World == "VeiledSea" && !old.IntroCutsceneStatus && current.IntroCutsceneStatus;
}

onStart
{
	timer.IsGameTimePaused = true;
	vars.CompletedSplits.Clear();
}

update
{
    vars.Helper.Update();
    vars.Helper.MapPointers();

    var world = vars.FNameToString(current.GWorldName);
    if (world != null && world != "None") current.World = world;
    if (old.World != current.World) vars.Log("World: " + current.World);

	// if (old.LoadingScreen != current.LoadingScreen) vars.Log("LoadingScreen: " + current.LoadingScreen);
}

isLoading
{
	return current.LoadingScreen;
}

split
{
	if (old.World != current.World && !vars.CompletedSplits.Contains(settings[old.World]))
	{
		vars.CompletedSplits.Add(settings[old.World]);
		if (settings[old.World]) return true;
	}

	if (current.World == "BossMasterLevel" && !vars.CompletedSplits.Contains(settings[current.World])
		&& old.EndCutscene != current.EndCutscene)
	{
		vars.CompletedSplits.Add(settings[current.World]);
		if (settings[current.World]) return true;
	}
}

reset
{
	return settings["AutoReset"] && old.World != "MainMenu" && current.World == "MainMenu";
}
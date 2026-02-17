state("SwordOfTheSea-Win64-Shipping") {}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main");
    vars.Uhara.AlertLoadless();
	vars.CompletedSplits = new HashSet<string>();

	dynamic[,] _settings =
	{
		{ "AutoReset", false, "Auto Reset when returning to Main Menu", null },
		{ "ILMode", false, "Individual Level Start", null },
		{ "AllFrogs", false, "All Frogs Split (End Cutscene of Boiling Cavern)", null },
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

	vars.Uhara.Settings.Create(_settings);	
}

init
{
	vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
	vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");

	IntPtr IntroCutscene = vars.Events.InstancePtr("Intro_DirectorBP_C", "Intro_DirectorBP_C");
	vars.Resolver.Watch<bool>("IntroCutsceneStatus", IntroCutscene, 0x38, 0x2A8);
	vars.Events.FunctionFlag("EndCutscene", "Ending_A_DirectorBP_C", "Ending_A_DirectorBP_C", "SequenceEvent__ENTRYPOINTEnding_A_DirectorBP");
	vars.Events.FunctionFlag("AllFrogs", "WraithDeath_DirectorBP_C", "WraithDeath_DirectorBP_C", "SequenceEvent__ENTRYPOINTWraithDeath_DirectorBP");

	vars.Resolver.Watch<int>("GSync", vars.Utils.GSync);
    vars.Resolver.Watch<uint>("GWorldName", vars.Utils.GWorld, 0x18);

	// GEngine -> GameInstance -> LoadingScreen -> bIsEnabled
	vars.Resolver.Watch<bool>("LoadingScreen", vars.Utils.GEngine, 0x10A8, 0x330, 0x0D9);
	vars.Uhara["LoadingScreen"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
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
    vars.Uhara.Update();

    var world = vars.Utils.FNameToString(current.GWorldName);
    if (world != null && world != "None") current.World = world;
    if (old.World != current.World) vars.Uhara.Log("World: " + current.World);
}

split
{
	if (old.World != current.World && !vars.CompletedSplits.Contains(old.World))
	{
		vars.CompletedSplits.Add(old.World);
		if (settings[old.World]) return true;
	}

	if (current.World == "BossMasterLevel" && !vars.CompletedSplits.Contains(current.World)
		&& vars.Resolver.CheckFlag("EndCutscene"))
	{
		vars.CompletedSplits.Add(current.World);
		if (settings[current.World]) return true;
	}

	if (current.World == "BoilingCavern" && !vars.CompletedSplits.Contains(current.World)
		&& vars.Resolver.CheckFlag("AllFrogs"))
	{
		vars.CompletedSplits.Add("AllFrogs");
		if (settings["AllFrogs"]) return true;
	}
}

isLoading
{
	return current.LoadingScreen;
}

reset
{
	return settings["AutoReset"] && old.World != "MainMenu" && current.World == "MainMenu";
}
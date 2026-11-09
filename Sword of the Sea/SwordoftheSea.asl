state("SwordOfTheSea-Win64-Shipping") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main");
	vars.Uhara.AlertLoadless();
	vars.CompletedSplits = new HashSet<string>();
	vars.CompletedSteles = new HashSet<string>();

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
		{ "OptionalSplits", false, "Optional Splits", null },
			{ "AllFrogs", false, "All Frogs Split (End Cutscene of Boiling Cavern)", "OptionalSplits" },
			{ "50Shells", false, "50 Shells Split (After 50th Shell collected)", "OptionalSplits" },
			{ "Stele", false, "Stele Splits", "OptionalSplits" },
				{ "AllSteles", false, "All Steles (Final Stele in Boiling Cavern)", "Stele" },
				{ "SteleSplits", false, "Split on every Stele", "Stele" },
	};

	vars.Uhara.Settings.Create(_settings);
}

init
{
	var vi = game.MainModule.FileVersionInfo;
	bool useUe58Patterns = vi.FileMajorPart > 5 || (vi.FileMajorPart == 5 && vi.FileMinorPart >= 8);
	vars.Uhara.Log("Game version: " + vi.FileMajorPart + "." + vi.FileMinorPart + "." + vi.FileBuildPart + "." + vi.FilePrivatePart);

	vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");

	if (useUe58Patterns)
	{
		vars.Utils.ExpandScanUtilitySignatures("UObjectProcessEvent",
			"40 55 56 57 41 54 41 55 41 56 41 57 48 81 EC ?? ?? 00 00 48 8D 6C 24 ??" +
			"48 89 9D ?? ?? 00 00 48 8B 05 ?? ?? ?? ?? 48 33 C5 48 89 85 ?? 00 00 00" +
			"8B 41 0C 33 F6 3B 05 ?? ?? ?? ?? 4D 8B F0 48 8B FA 4C 8B F9 7D 1E");

		vars.Utils.ExpandScanUtilitySignatures("UObject_BeginDestroy",
			"40 53 48 83 EC ?? 8B 41 08 48 8B D9 0F BA E0 0F 72 ??" +
			"48 8B 41 18 48 8D 54 24 30");

		vars.Utils.ExpandScanUtilitySignatures("StaticConstructObject_Internal",
			"48 89 5C 24 10 48 89 6C 24 18 56 57 41 54 41 56 41 57 48 81 EC F0 02 00 00");
	}

	vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");

	// Intro Cutscene
	IntPtr IntroCutscene = vars.Events.InstancePtr("Intro_DirectorBP_C", "Intro_DirectorBP_C");
	vars.Resolver.Watch<bool>("IntroCutsceneStatus", IntroCutscene, 0x38, 0x2A8);

	// Steles
	IntPtr SteleSlot = vars.Events.FunctionParentPtr("LoreAncientStele_BP_C", null, "ExecuteUbergraph_LoreObject_BP");
	vars.Uhara.Log("SteleSlot: " + SteleSlot.ToString("X"));
	if (SteleSlot != IntPtr.Zero)
	{
		vars.Resolver.Watch<IntPtr>("SteleInstance", SteleSlot);
	}
	else
	{
		vars.Uhara.Log("SteleSlot unresolved: LoreAncientStele_BP_C / ExecuteUbergraph_LoreObject_BP not found");
	}
	
	// Functions
	vars.Events.FunctionFlag("EndCutscene", "Ending_A_DirectorBP_C", null, "SequenceEvent__ENTRYPOINTEnding_A_DirectorBP");
	vars.Events.FunctionFlag("AllFrogs", "WraithDeath_DirectorBP_C", null, "SequenceEvent__ENTRYPOINTWraithDeath_DirectorBP");

	// World/Level name
	vars.Resolver.Watch<ulong>("GWorldName", vars.Utils.GWorld, 0x18);

	// Versioning
	// GEngine -> GameInstance -> LoadingScreen -> bIsEnabled
	// GEngine -> GameInstance -> LocalPlayer[0] -> MyHUD -> HUDState -> NumShellCount.Current
	if (useUe58Patterns)
	{
		vars.Resolver.Watch<bool>("LoadingScreen", vars.Utils.GEngine, 0x13D8, 0x328, 0x0D9);
		vars.Resolver.Watch<int>("ShellCount", vars.Utils.GEngine, 0x13D8, 0x38, 0x0, 0x30, 0x358, 0x430, 0x108);
		vars.Uhara.Log("Using UE 5.8 offsets");
	}
	else
	{
		vars.Resolver.Watch<bool>("LoadingScreen", vars.Utils.GEngine, 0x10A8, 0x330, 0x0D9);
		vars.Resolver.Watch<int>("ShellCount", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x358, 0x430, 0x108); // needs to be confirmed
		vars.Uhara.Log("Using legacy UE offsets");
	}

	vars.Uhara["LoadingScreen"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
	current.World = "";
	current.SteleInstance = IntPtr.Zero;
}

start
{
	if (settings["ILMode"]) return current.World != "MainMenu" && old.LoadingScreen && !current.LoadingScreen;

	return current.World == "VeiledSea" && !old.IntroCutsceneStatus && current.IntroCutsceneStatus;
}

onStart
{
	timer.IsGameTimePaused = true;
	vars.CompletedSplits.Clear();
	vars.CompletedSteles.Clear();
}

update
{
	vars.Uhara.Update();

	string world = vars.Utils.FNameToString(current.GWorldName);
	if (world != null && world != "None") current.World = world;
	if (old.World != current.World) vars.Uhara.Log("World: " + current.World);

	if (old.IntroCutsceneStatus != current.IntroCutsceneStatus) vars.Uhara.Log("IntroCutsceneStatus: " + current.IntroCutsceneStatus);
	if (old.LoadingScreen != current.LoadingScreen) vars.Uhara.Log("LoadingScreen: " + current.LoadingScreen);

	if (current.SteleInstance != IntPtr.Zero)
	{
		current.SteleNameIndex = vars.Resolver.Read<ulong>(current.SteleInstance + 0x18);
		current.SteleName = current.SteleNameIndex != 0 ? (vars.Utils.FNameToString(current.SteleNameIndex) ?? "") : "";
	}
	else
	{
		current.SteleNameIndex = 0;
		current.SteleName = "";
	}
}

split
{
	if (old.World != current.World && !string.IsNullOrEmpty(old.World) && !vars.CompletedSplits.Contains(old.World) && settings.ContainsKey(old.World))
	{
		vars.CompletedSplits.Add(old.World);

		if (settings[old.World]) return true;
	}

	if (current.World == "BossMasterLevel" && !vars.CompletedSplits.Contains(current.World) && vars.Resolver.CheckFlag("EndCutscene"))
	{
		vars.CompletedSplits.Add(current.World);

		if (settings.ContainsKey(current.World) && settings[current.World]) return true;
	}

	if (current.World == "BoilingCavern" && !vars.CompletedSplits.Contains(current.World) && vars.Resolver.CheckFlag("AllFrogs"))
	{
		vars.CompletedSplits.Add("AllFrogs");

		if (settings.ContainsKey("AllFrogs") && settings["AllFrogs"]) return true;
	}

	if (old.ShellCount != current.ShellCount && current.ShellCount == 50 && !vars.CompletedSplits.Contains("50Shells") 
		&& settings.ContainsKey("50Shells") && settings["50Shells"])
	{
		vars.CompletedSplits.Add("50Shells");
		return true;
	}

	// Final Stele Split
	if (current.SteleName == "LoreAncientStele_BP_C_6" && current.World == "BoilingCavern"
		&& !vars.CompletedSplits.Contains("AllSteles") && settings.ContainsKey("AllSteles") && settings["AllSteles"])
	{
		vars.CompletedSplits.Add("AllSteles");
		vars.CompletedSteles.Add(current.World + "/" + current.SteleName);
		return true;
	}

	// Split on every Stele
	if (current.SteleName != "" && !string.IsNullOrEmpty(current.World) && settings.ContainsKey("SteleSplits") && settings["SteleSplits"])
	{
		string steleKey = current.World + "/" + current.SteleName;
		bool ownedByAllSteles = settings.ContainsKey("AllSteles") && settings["AllSteles"]
			&& steleKey == "BoilingCavern/LoreAncientStele_BP_C_6";
		if (!ownedByAllSteles && !vars.CompletedSteles.Contains(steleKey))
		{
			vars.CompletedSteles.Add(steleKey);
			return true;
		}
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
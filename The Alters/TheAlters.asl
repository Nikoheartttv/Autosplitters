state("TheAlters-Win64-Shipping") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	vars.Helper.GameName = "The Alters";
	vars.Helper.AlertLoadless();

	dynamic[,] _settings =
	{
		{ "WakeUpDay", false, "Split upon when you wake up next day", null },
		{ "ChapterSplits", true, "Chapter Splits - On Completion", null },
			{ "BP_ACT0_Prologue_Chapter_C", true, "Prologue", "ChapterSplits"},
			{ "BP_Journey1_Chapter_C", true, "Journey 1", "ChapterSplits"},
			{ "BP_ACT1_Chapter_C", true, "Act 1", "ChapterSplits" },
			{ "BP_Journey2_Chapter_C", true, "Journey 2", "ChapterSplits" },
			{ "BP_ACT2_Chapter_C", true, "Act 2", "ChapterSplits" },
			{ "BP_Journey3_Chapter_C", true, "Journey 3", "ChapterSplits" },
			{ "BP_INTERLUDIUM_Chapter_C", true, "Interlude", "ChapterSplits" },
			{ "BP_Journey4_Chapter_C", true, "Journey 4", "ChapterSplits" },
			{ "BP_ACT3_Chapter_C", false, "Act 3", "ChapterSplits" },
			{ "BP_ACT3_FinalDay_Chapter_C", false, "Act 3 - Final Day", "ChapterSplits" },
			{ "P9GameplayEvent /Game/P9Playable/Systems/FinalDay/GE_EpilogStarted.GE_EpilogStarted", false, "Epilogue", "ChapterSplits"},
		{ "EndingSplits", true, "Ending Splits", null },
			{ "P9GameplayEvent /Game/P9Playable/Narration/NarrativeQuestLines/Act3_FinalDay/LastGoobyes/Events/GE_Act3FD_LG_EveryAlterHidden.GE_Act3FD_LG_EveryAlterHidden", false, "Alters Hide in Ark Sarcophogus", "EndingSplits" },
			{ "P9GameplayEvent /Game/P9Playable/Narration/NarrativeQuestLines/Act3_FinalDay/SpacecraftArrives/Events/GE_Act3FD_SA_Achievement_FinishTheGameInTheMaxwellsPath.GE_Act3FD_SA_Achievement_FinishTheGameInTheMaxwellsPath", true, "ENDING - Maxwell's Path", "EndingSplits" },
			{ "P9GameplayEvent /Game/P9Playable/Narration/NarrativeQuestLines/Act3_FinalDay/SpacecraftArrives/Events/GE_Act3FD_SA_Achievement_FinishTheGameInTheCorporatePath.GE_Act3FD_SA_Achievement_FinishTheGameInTheCorporatePath", true, "ENDING - The Corporate Way (double check if it works)", "EndingSplits" },
			{ "P9GameplayEvent /Game/P9Playable/Narration/NarrativeQuestLines/Act3_FinalDay/SpacecraftArrives/Events/GE_Act3FD_SA_Achievement_BetrayEverybodyAsTheBotanist.GE_Act3FD_SA_Achievement_BetrayEverybodyAsTheBotanist", true, "ENDING - The Things We Do for Love (double check if it works)", "EndingSplits" },
			{ "P9GameplayEvent /Game/P9Playable/Narration/NarrativeQuestLines/Act3_FinalDay/SpacecraftArrives/Events/GE_Act3FD_SA_Achievement_BlowUpTheBase.GE_Act3FD_SA_Achievement_BlowUpTheBase", true, "ENDING - It Ends In Flames (double check if it works)", "EndingSplits" },
			{ "P9GameplayEvent /Game/P9Playable/Narration/NarrativeQuestLines/Act3_FinalDay/SpacecraftArrives/Events/GE_Act3FD_SA_Achievement_ComeBackToEarthAsTheBotanist.GE_Act3FD_SA_Achievement_ComeBackToEarthAsTheBotanist", true, "ENDING - I Deserved This More", "EndingSplits" },
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

    current.GEngine = gEngine;

	if (gWorld == IntPtr.Zero || gEngine == IntPtr.Zero || fNames == IntPtr.Zero)
	{
		const string Msg = "Not all required addresses could be found by scanning.";
		throw new Exception(Msg);
	}

	vars.Helper["GSync"] = vars.Helper.Make<bool>(gSyncLoadCount); // GSync
	vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x18); // GWorld.FName
    vars.Helper["Loading"] = vars.Helper.Make<int>(gEngine, 0xFC0, 0x200, 0x50); // GEngine.GameInstance.LoadingScreen.???
    // GEngine.GameInstance.LocalPlayers[0].MyHUD.CutsceneOverlay.bIsFocusable
    vars.Helper["CutsceneActive"] = vars.Helper.Make<byte>(gEngine, 0xFC0, 0x38, 0x0, 0x30, 0x348, 0x710, 0x1DC);
    vars.Helper["CutsceneActive"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
	// GWorld.AuthorityGameMode.BP_PlayerStatistics.WakeUpDate.Date
    vars.Helper["WakeUpDay"] = vars.Helper.Make<int>(gWorld, 0x150, 0x580, 0xD0);
    vars.Helper["WakeUpDay"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
	// GWorld -> GameplayStatsSubsystem.EventsSubsystem.EventRecorder.Records
	vars.Helper["EventsSubsystemRecordsList"] = vars.Helper.Make<IntPtr>(gWorld, 0x640, 0x8, 0x240, 0x3E0, 0xE8, 0x28);
	vars.Helper["EventsSubsystemRecordsListArrayNum"] = vars.Helper.Make<int>(gWorld, 0x640, 0x8, 0x240, 0x3E0, 0xE8, 0x30);

	vars.Helper.Update();
	vars.Helper.MapPointers();

    vars.FNameToString = (Func<ulong, string>)(fName =>
	{
		var nameIdx = (fName & 0x000000000000FFFF) >> 0x00;
		var chunkIdx = (fName & 0x00000000FFFF0000) >> 0x10;
		var number = (fName & 0xFFFFFFFF00000000) >> 0x20;

		// IntPtr chunk = vars.Helper.Read<IntPtr>(fNames + 0x10 + (int)chunkIdx * 0x8);
		IntPtr chunk = vars.Helper.Read<IntPtr>(fNames + 0x10 + (int)chunkIdx * 0x8);
		IntPtr entry = chunk + (int)nameIdx * sizeof(short);

		int length = vars.Helper.Read<short>(entry) >> 6;
		string name = vars.Helper.ReadString(length, ReadStringType.UTF8, entry + sizeof(short));

		return number == 0 ? name : name + "_" + number;
	});

	vars.FindSubsystem = (Func<string, IntPtr>)(name =>
    {
		// GEngine.GameInstance.currentnumberofsubsystems
        var subsystems = vars.Helper.Read<int>(gEngine, 0xFC0, 0x110);
        for (int i = 0; i < subsystems; i++)
        {
			//GEngine.GameInstance.subsystem finds on every 0x18 plus 0x8
            var subsystem = vars.Helper.Deref(gEngine, 0xFC0, 0x108, 0x18 * i + 0x8);
            var sysName = vars.FNameToString(vars.Helper.Read<ulong>(subsystem, 0x18));

            if (sysName.StartsWith(name))
            {
                return subsystem;
            }
        }

        throw new InvalidOperationException("Subsystem not found: " + name);
    });
    vars.ChaptersManager = IntPtr.Zero;
	
	current.World = "";
	current.Chapter = "";
	current.CurrentJob = "";
	current.WakeUpDay = 0;
	vars.GWorld = gWorld;
	vars.GEngine = gEngine;
	current.Event = default(ulong);

	vars.EventsList = new List<ulong>();
	for (var i = 0; i < current.EventsSubsystemRecordsListArrayNum; i++)
	{
		var events = vars.Helper.Read<ulong>(vars.GWorld, 0x640, 0x8, 0x240, 0x458, 0x88, 0xE8, 0x28, 0x18 * i);
		vars.EventsList.Add(events);
	}
}

start
{
    return old.World == "MainMenu" && current.World == "StartLevel";
}

onStart
{
	timer.IsGameTimePaused = true;
	vars.CompletedSplits.Clear();
}

update
{
	IntPtr gm;
    if (!vars.Helper.TryRead<IntPtr>(out gm, vars.ChaptersManager))
    {
		// UP9ChaptersManager : public UP9GameInstanceSubsystem
        vars.ChaptersManager = vars.FindSubsystem("P9ChaptersManager");
        // P9ChaptersManager->CurrentChapter->NamePrivate
        vars.Helper["CurrentChapterFName"] = vars.Helper.Make<ulong>(vars.ChaptersManager, 0x138, 0x18);
		// P9ChaptersManager->LevelsManager->Pointer to World???->0x8->P9TreeOLifeSubsystem->DiscoveredLifeEvents
		vars.Helper["DiscoveredLifeEventsList"] = vars.Helper.Make<IntPtr>(vars.ChaptersManager, 0x130, 0x28, 0x8, 0x6F8, 0x200);
		// P9ChaptersManager->LevelsManager->Pointer to World???->0x8->P9TreeOLifeSubsystem->DiscoveredAwarenessess
		vars.Helper["DiscoveredAwarenessList"] = vars.Helper.Make<IntPtr>(vars.ChaptersManager, 0x130, 0x28, 0x8, 0x6F8, 0x210);
    }

	vars.Helper.Update();
	vars.Helper.MapPointers();

	var world = vars.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	if (old.World != current.World)vars.Log("World: " + current.World);

	current.Chapter = vars.FNameToString(current.CurrentChapterFName);
    if (old.Chapter != current.Chapter)
    {
        vars.Log("Chapter: " + old.Chapter + " -> " + current.Chapter);
    }

	current.Event = vars.Helper.Read<ulong>(vars.GWorld, 0x640, 0x8, 0x240, 0x458, 0x88, 0xE8, 0x28, 0x18 * (current.EventsSubsystemRecordsListArrayNum-1));
	if (old.Event != current.Event)
	{
		vars.Log("Event occured: " + vars.FNameToString(current.Event));
	}
}

isLoading
{
	return current.Loading != 0 || current.CutsceneActive == 1 || current.World == "MainMenu";
}

split
{
	if (settings["WakeUpDay"] && old.WakeUpDay != 0 && current.WakeUpDay != 1)
	{
		if (!vars.CompletedSplits.Contains(current.WakeUpDay.ToString()) & old.WakeUpDay != current.WakeUpDay) return true;
	}

	if (old.Chapter != current.Chapter && !vars.CompletedSplits.Contains(old.Chapter.ToString()))
	{
		vars.CompletedSplits.Add(old.Chapter);
		return settings[old.Chapter];
	}

	if (old.Event != current.Event && settings[vars.FNameToString(current.Event)] && !vars.CompletedSplits.Contains(vars.FNameToString(current.Event)))
	{
		vars.CompletedSplits.Add(vars.FNameToString(current.Event));
		if (settings[vars.FNameToString(current.Event)]) return true;
	}
}

state("TheAlters-Win64-Shipping") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	vars.Helper.GameName = "The Alters";
	vars.Helper.AlertLoadless();

	dynamic[,] _settings =
	{
		{ "WakeUpDay", true, "Split upon when you wake up next day", null },
		{ "ChapterSplits", false, "Chapter Splits - UNFINISHED", null },
			{ "BP_ACT0_Prologue_Chapter_C", true, "Prologue", "ChapterSplits"},
			{ "BP_Journey1_Chapter_C", true, "Journey 1", "ChapterSplits"},
			{ "BP_ACT1_Chapter_C", true, "Act 1", "ChapterSplits" },
			{ "BP_Journey2_Chapter_C", true, "Journey 2", "ChapterSplits" },
			{ "BP_ACT2_Chapter_C", true, "Act 2", "ChapterSplits" },
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

	// GSync
	vars.Helper["GSync"] = vars.Helper.Make<bool>(gSyncLoadCount);
	// GWorld.FName
	vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x18);
    // GEngine.GameInstance.LoadingScreen.???
    vars.Helper["Loading"] = vars.Helper.Make<int>(gEngine, 0xFC0, 0x200, 0x50);

	// this chapter instance starts as soon as you were to choose from main menu, too fast?
	// vars.Helper["ChapterName2"] = vars.Helper.Make<ulong>(gEngine, 0xFC0, 0x208, 0x18);
    // GEngine.GameInstance.LocalPlayers[0].MyHUD.CutsceneOverlay.bIsFocusable
    vars.Helper["CutsceneActive"] = vars.Helper.Make<byte>(gEngine, 0xFC0, 0x38, 0x0, 0x30, 0x348, 0x710, 0x1DC);
    vars.Helper["CutsceneActive"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;

	// GWorld.AuthorityGameMode.BP_PlayerStatistics.WakeUpDate.Date
    vars.Helper["WakeUpDay"] = vars.Helper.Make<int>(gWorld, 0x150, 0x580, 0xD0);
    vars.Helper["WakeUpDay"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;

	// GEngine.GameInstance.subsystems.P9GlobalSequenceSubsystem.CurrentJob.NamePrivate
	vars.Helper["CurrentJobFn"] = vars.Helper.Make<ulong>(gEngine, 0xFC0, 0x108, 0x1A0, 0x60, 0x18);

	// GWorld -> CharacterManagementSubsystem
	// vars.Helper["???"] = vars.Helper.Make<???>(gWorld, 0x30, 0x150, 0x8, 0x3A0, 0x240, 0x458, 0x60);
	// GWorld -> ChaptersManagerSubsystem
	// vars.Helper["???"] = vars.Helper.Make<???>(gWorld, 0x30, 0x150, 0x8, 0x3A0, 0x240, 0x458, 0x68);
	// GWorld -> ResourceSystem
	// vars.Helper["???"] = vars.Helper.Make<???>(gWorld, 0x30, 0x150, 0x8, 0x3A0, 0x240, 0x458, 0x70);
	// GWorld -> WorkSubsystem
	// vars.Helper["???"] = vars.Helper.Make<???>(gWorld, 0x30, 0x150, 0x8, 0x3A0, 0x240, 0x458, 0x78);
	// GWorld -> EventsSubsystem !Important
	// vars.Helper["???"] = vars.Helper.Make<???>(gWorld, 0x30, 0x150, 0x8, 0x3A0, 0x240, 0x458, 0x88);
	// GWorld -> EventsSubsystem.EventRecorder.Records
	vars.Helper["EventsSubsystemRecordsList"] = vars.Helper.Make<IntPtr>(gWorld, 0x30, 0x150, 0x8, 0x3A0, 0x240, 0x458, 0x88, 0xE8, 0x28);
	vars.Helper["EventsSubsystemRecordsListArrayNum"] = vars.Helper.Make<int>(gWorld, 0x30, 0x150, 0x8, 0x3A0, 0x240, 0x458, 0x88, 0xE8, 0x30);
	// GWorld -> NarrativeSubsystem
	// vars.Helper["???"] = vars.Helper.Make<???>(gWorld, 0x30, 0x150, 0x8, 0x3A0, 0x240, 0x458, 0x90);
	// GWorld -> ResearchSubsystem
	// vars.Helper["???"] = vars.Helper.Make<???>(gWorld, 0x30, 0x150, 0x8, 0x3A0, 0x240, 0x458, 0x98);
	// GWorld -> CollectiblesSubsystem
	// vars.Helper["???"] = vars.Helper.Make<???>(gWorld, 0x30, 0x150, 0x8, 0x3A0, 0x240, 0x458, 0xA0);
	// GWorld -> PlayerState
	// vars.Helper["???"] = vars.Helper.Make<???>(gWorld, 0x30, 0x150, 0x8, 0x3A0, 0x240, 0x458, 0xB0);

    // this cutscene does work well, but over-extends even when you have movement
    // GWorld.AuthorityGameMode.ExplorationSystem.PawnStatistics.CutsceneSubsystem.bCutsceneInProgress
    // vars.Helper["bCutsceneInProgress"] = vars.Helper.Make<bool>(gWorld, 0x150, 0x5A0, 0x390, 0x260, 0x404);
    // vars.Helper["bCutsceneInProgress"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;

    // Things to look at
    // GEngine.GameInstance.???.PointerToP9GlobalSequenceSubsystem.CurrentJob-> delve further when doing a job
    // vars.Helper["CurrentJob?"] = vars.Helper.Make<???>(gEngine, 0xFC0, 0x108, 0x118, 0x60, ???)

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

	// THIS FAILS
	// vars.EventsList = new List<ulong>();
	// for (var i = 0; i < current.EventsSubsystemRecordsListArrayNum; i++)
	// {
	// 	var events = vars.Helper.Read<ulong>(vars.GWorld, 0x30, 0x150, 0x8, 0x3A0, 0x240, 0x458, 0xE8, 0x28, 0x18 * i);
	// 	vars.EventsList[i] = events;
	// }
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

	// for (var i = 0; i < current.EventsSubsystemRecordsListArrayNum; i++)
	// {
	// 	var events = vars.Helper.Read<ulong>(vars.GEngine, 0x30, 0x150, 0x8, 0x3A0, 0x240, 0x458, 0xE8, 0x28, 0x18 * i);
	// 	if (events != vars.EventsList[i])
	// 	{
	// 		if (events == 0) vars.Log("Event removed: " + vars.FNameToString(vars.EventsList[i]));
	// 		else vars.Log("Event occured: " + vars.FNameToString(events));
	// 		vars.EventsList[i] = events;
	// 	}
	// }

	// current.CurrentJob = vars.FNameToString(current.CurrentJobFn);
    // if (old.CurrentJob != current.CurrentJob)
    // {
    //     vars.Log("Current Job: " + old.CurrentJob + " -> " + current.CurrentJob);
    // }

	// current.Chapter = vars.FNameToString(current.ChapterName2);
	// if (old.ChapterName2 != current.ChapterName2)
    // {
    //     vars.Log("Chapter: " + old.Chapter + " -> " + current.Chapter);
    // }

	// current.Chapter = vars.FNameToString(current.ChaptersManager);
	// vars.Log(current.Chapter);

    // vars.Log(current.GEngine.ToString("X"));
}

isLoading
{
	return current.Loading != 0 || current.CutsceneActive == 1;
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
}

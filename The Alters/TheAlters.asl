state("TheAlters-Win64-Shipping") { }

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main");
	vars.Uhara.AlertLoadless();

	dynamic[,] _settings =
	{
		{ "AutoReset", false, "Auto Reset when returning to Main Menu", null },
		{ "WakeUpDay", false, "Split upon when you wake up next day", null },
		{ "MainGame", true, "Main Game", null },
			{ "ChapterSplits", true, "Chapter Splits - On Completion", "MainGame" },
				{ "BP_ACT0_Prologue_Chapter_C", true, "Prologue", "ChapterSplits" },
				{ "BP_Journey1_Chapter_C", true, "Journey 1", "ChapterSplits" },
				{ "BP_ACT1_Chapter_C", true, "Act 1", "ChapterSplits" },
				{ "BP_Journey2_Chapter_C", true, "Journey 2", "ChapterSplits" },
				{ "BP_ACT2_Chapter_C", true, "Act 2", "ChapterSplits" },
				{ "BP_Journey3_Chapter_C", true, "Journey 3", "ChapterSplits" },
				{ "BP_INTERLUDIUM_Chapter_C", true, "Interlude", "ChapterSplits" },
				{ "BP_Journey4_Chapter_C", true, "Journey 4", "ChapterSplits" },
				{ "BP_ACT3_Chapter_C", false, "Act 3", "ChapterSplits" },
				{ "BP_ACT3_FinalDay_Chapter_C", false, "Act 3 - Final Day", "ChapterSplits" },
				{ "P9GameplayEvent /Game/P9Playable/Systems/FinalDay/GE_EpilogStarted.GE_EpilogStarted", false, "Epilogue", "ChapterSplits" },
			{ "EndingSplits", true, "Ending Splits", "MainGame" },
				{ "P9GameplayEvent /Game/P9Playable/Narration/NarrativeQuestLines/Act3_FinalDay/LastGoobyes/Events/GE_Act3FD_LG_EveryAlterHidden.GE_Act3FD_LG_EveryAlterHidden", false, "Alters Hide in Ark Sarcophogus", "EndingSplits" },
				{ "P9GameplayEvent /Game/P9Playable/Narration/NarrativeQuestLines/Act3_FinalDay/SpacecraftArrives/Events/GE_Act3FD_SA_Achievement_FinishTheGameInTheMaxwellsPath.GE_Act3FD_SA_Achievement_FinishTheGameInTheMaxwellsPath", true, "ENDING - Maxwell's Path", "EndingSplits" },
				{ "P9GameplayEvent /Game/P9Playable/Narration/NarrativeQuestLines/Act3_FinalDay/SpacecraftArrives/Events/GE_Act3FD_SA_Achievement_FinishTheGameInTheCorporatePath.GE_Act3FD_SA_Achievement_FinishTheGameInTheCorporatePath", true, "ENDING - The Corporate Way", "EndingSplits" },
				{ "P9GameplayEvent /Game/P9Playable/Narration/NarrativeQuestLines/Act3_FinalDay/SpacecraftArrives/Events/GE_Act3FD_SA_Achievement_BetrayEverybodyAsTheBotanist.GE_Act3FD_SA_Achievement_BetrayEverybodyAsTheBotanist", true, "ENDING - The Things We Do for Love", "EndingSplits" },
				{ "P9GameplayEvent /Game/P9Playable/Narration/NarrativeQuestLines/Act3_FinalDay/SpacecraftArrives/Events/GE_Act3FD_SA_Achievement_BlowUpTheBase.GE_Act3FD_SA_Achievement_BlowUpTheBase", true, "ENDING - It Ends In Flames", "EndingSplits" },
				{ "P9GameplayEvent /Game/P9Playable/Narration/NarrativeQuestLines/Act3_FinalDay/SpacecraftArrives/Events/GE_Act3FD_SA_Achievement_ComeBackToEarthAsTheBotanist.GE_Act3FD_SA_Achievement_ComeBackToEarthAsTheBotanist", true, "ENDING - I Deserved This More", "EndingSplits" },
		{ "LastVariable", true, "Last Variable DLC", null },
			{ "DLCCycleSplits", false, "Split on DLC cycle advance", "LastVariable" },
				{ "BP_DLC1_Epilogue_Chapter_C", true, "ZPE Activated", "DLCCycleSplits" },
	};
	vars.Uhara.Settings.Create(_settings);

	vars.CompletedDays = new HashSet<int>();
	vars.ProcessedEvents = new HashSet<ulong>();

	vars.ChaptersManager = IntPtr.Zero;
	vars.EventsSubsystem = IntPtr.Zero;
	vars.CycleSubsystem = IntPtr.Zero;
	vars.CutsceneManager = IntPtr.Zero;
	vars.TimeSystem = IntPtr.Zero;
	vars.LoadingSubsystem = IntPtr.Zero;
	vars.LastEventCount = 0;
	vars.NeedsSubsystemRefresh = false;
}

init
{
	vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
	vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");

	if (vars.Utils.GEngine != IntPtr.Zero) vars.Uhara.Log("GEngine found at " + vars.Utils.GEngine.ToString("X"));
	if (vars.Utils.GWorld != IntPtr.Zero) vars.Uhara.Log("GWorld found at " + vars.Utils.GWorld.ToString("X"));
	if (vars.Utils.FNames != IntPtr.Zero) vars.Uhara.Log("FNames found at " + vars.Utils.FNames.ToString("X"));

	// Core world name watcher
	vars.Resolver.Watch<uint>("GWorldName", vars.Utils.GWorld, 0x18);
	
	// Load Removal watchers
	vars.Resolver.Watch<bool>("bIsGameWindowFocused", vars.Utils.GEngine, 0x1220, 0x38, 0x0, 0x30, 0x8D0);
	vars.Resolver.Watch<IntPtr>("CutsceneOverlay", vars.Utils.GEngine, 0x1220, 0x38, 0x0, 0x30, 0x358, 0x760);
	vars.Uhara["CutsceneOverlay"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
	vars.Resolver.Watch<IntPtr>("IsPauseMenuOpen", vars.Utils.GEngine, 0x1220, 0x38, 0x0, 0x30, 0xCA0);
	vars.Uhara["IsPauseMenuOpen"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;

	// Subsystem initialization
	vars.Events.FunctionFlag("MainGameSubsystemInit", "BP_PlayableGameMode_BaseGame_C", "BP_PlayableGameMode_C", "InitializeSubsystems");
	vars.Events.FunctionFlag("DLCSubsystemInit", "BP_PlayableGameMode_DLC1_C", "BP_PlayableGameMode_DLC1_C", "InitializeSubsystems");

	// Subsystem variable setup
	vars.ChaptersManager = IntPtr.Zero;
	vars.EventsSubsystem = IntPtr.Zero;
	vars.CycleSubsystem = IntPtr.Zero;
	vars.CutsceneManager = IntPtr.Zero;
	vars.TimeSystem = IntPtr.Zero;
	vars.LoadingSubsystem = IntPtr.Zero;
	vars.LastEventCount = 0;

	// Action to clear cached state of Subsystems/Variables/Events/Chapters/Cycles/Cutscenes/Time/etc
	vars.ClearCachedState = (Action)(() =>
	{
		vars.EventsSubsystem = IntPtr.Zero;
		vars.CycleSubsystem = IntPtr.Zero;
		vars.CutsceneManager = IntPtr.Zero;
		vars.TimeSystem = IntPtr.Zero;
		vars.LastEventCount = 0;

		current.Event = default(ulong);
		current.CycleIndex = -1;
		current.CutsceneName = "";
		current.CurrentDate = 0;
		current.PauseState = 0;
	});

	// Subsystem finder
	vars.FindSubsystem = (Func<string, string, IntPtr>)((source, prefix) =>
	{
		try
		{
			int subsystemCount = 0;

			if (source == "Engine") subsystemCount = vars.Resolver.Read<int>(vars.Utils.GEngine, 0x1220, 0x110);
			else if (source == "World") subsystemCount = vars.Resolver.Read<int>(vars.Utils.GWorld, 0x868);
			else return IntPtr.Zero;

			for (int i = 0; i < subsystemCount; i++)
			{
				IntPtr subsystem = IntPtr.Zero;

				try
				{
					if (source == "Engine")
						subsystem = vars.Resolver.Read<IntPtr>(vars.Utils.GEngine, 0x1220, 0x108, 0x18 * i + 0x8);
					else
						subsystem = vars.Resolver.Read<IntPtr>(vars.Utils.GWorld, 0x860, 0x18 * i + 0x8);
				}
				catch { continue; }

				if (subsystem == IntPtr.Zero) continue;

				string subsystemName = "";
				try { subsystemName = vars.Utils.FNameToString(vars.Resolver.Read<uint>(subsystem + 0x18)); }
				catch { continue; }

				if (string.IsNullOrEmpty(subsystemName) || subsystemName == "None") continue;

				if (subsystemName.StartsWith(prefix)) return subsystem;
			}
		}
		catch { }

		return IntPtr.Zero;
	});

	// Clear cached state on initial load
	vars.ClearCachedState();

	// Clear current world on initial load
	current.World = "";
	current.Chapter = "";
	current.bIsLoading = false;
}

update
{
	vars.Uhara.Update();

	// World name
	var world = vars.Utils.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	if (old.World != current.World) vars.Uhara.Log("World: " + current.World);

	// Clear cached state on return to main menu
	if (current.World == "MainMenu" && old.World != "MainMenu")
	{
		vars.ClearCachedState();
		vars.Uhara.Log("Returned to MainMenu, cached world state cleared");
	}

	// Check if we're in a game world
	bool inGameWorld = current.World == "StartLevel" || current.World == "StartLevel_DLC1";
	// Check if we're in a DLC
	bool isDLC = current.World == "StartLevel_DLC1";

	// If we're not in a game world, return
	if (!inGameWorld) return;

	// Find subsystems
	if (vars.ChaptersManager == IntPtr.Zero)
	{
		vars.ChaptersManager = vars.FindSubsystem("Engine", "P9ChaptersManager");
		if (vars.ChaptersManager != IntPtr.Zero) vars.Uhara.Log("P9ChaptersManager found at " + vars.ChaptersManager.ToString("X"));
	}

	if (vars.LoadingSubsystem == IntPtr.Zero)
	{
		vars.LoadingSubsystem = vars.FindSubsystem("Engine", "P9LoadingSubsystem");
		if (vars.LoadingSubsystem != IntPtr.Zero)
			vars.Uhara.Log("P9LoadingSubsystem found at " + vars.LoadingSubsystem.ToString("X"));
	}

	// Clear cached state on subsystem initialization
	if (vars.Resolver.CheckFlag("MainGameSubsystemInit") || vars.Resolver.CheckFlag("DLCSubsystemInit"))
	{
		vars.ClearCachedState();
		vars.NeedsSubsystemRefresh = true;
		vars.Uhara.Log("InitializeSubsystems detected, cleared cached world state");
	}

	if (vars.NeedsSubsystemRefresh)
	{
		if (vars.EventsSubsystem == IntPtr.Zero)
		{
			vars.EventsSubsystem = vars.FindSubsystem("World", "P9EventsSubsystem");
			if (vars.EventsSubsystem != IntPtr.Zero) vars.Uhara.Log("P9EventsSubsystem found at " + vars.EventsSubsystem.ToString("X"));
		}


		if (vars.CutsceneManager == IntPtr.Zero)
		{
			vars.CutsceneManager = vars.FindSubsystem("World", "P9CutsceneSystem");
			if (vars.CutsceneManager != IntPtr.Zero) vars.Uhara.Log("P9CutsceneSystem found at " + vars.CutsceneManager.ToString("X"));
		}

		if (vars.TimeSystem == IntPtr.Zero)
		{
			vars.TimeSystem = vars.FindSubsystem("World", "P9TimeSystem");
			if (vars.TimeSystem != IntPtr.Zero) vars.Uhara.Log("P9TimeSystem found at " + vars.TimeSystem.ToString("X"));
		}

		// Find DLC subsystem
		if (isDLC && vars.CycleSubsystem == IntPtr.Zero)
		{
			vars.CycleSubsystem = vars.FindSubsystem("World", "P9CycleSubsystem");
			if (vars.CycleSubsystem != IntPtr.Zero) vars.Uhara.Log("P9CycleSubsystem found at " + vars.CycleSubsystem.ToString("X"));
		}

		if (vars.EventsSubsystem != IntPtr.Zero
			&& vars.CutsceneManager != IntPtr.Zero
			&& vars.TimeSystem != IntPtr.Zero
			&& (!isDLC || vars.CycleSubsystem != IntPtr.Zero))
		{
			vars.NeedsSubsystemRefresh = false;
		}
	}

	// Chapter name
	if (vars.ChaptersManager != IntPtr.Zero)
	{
		IntPtr currentChapterPtr = vars.Resolver.Read<IntPtr>(vars.ChaptersManager + 0x138);

		if (currentChapterPtr != IntPtr.Zero)
		{
			uint currentChapterFName = vars.Resolver.Read<uint>(currentChapterPtr + 0x18);
			string chapter = vars.Utils.FNameToString(currentChapterFName);

			if (!string.IsNullOrEmpty(chapter) && chapter != "None") current.Chapter = chapter;
		}
	}

	// Chapter change log
	if (old.Chapter != current.Chapter) vars.Uhara.Log("Chapter: " + old.Chapter + " -> " + current.Chapter);

	// Latest event occurred
	if (vars.EventsSubsystem != IntPtr.Zero)
	{
		IntPtr eventsList = vars.Resolver.Read<IntPtr>(vars.EventsSubsystem + 0xF0, 0x28);
		int eventCount = vars.Resolver.Read<int>(vars.EventsSubsystem + 0xF0, 0x30);

		if (eventsList != IntPtr.Zero && eventCount > 0)
		{
			if (eventCount != vars.LastEventCount)
			{
				current.Event = vars.Resolver.Read<uint>(eventsList + 0x18 * (eventCount - 1));
				vars.LastEventCount = eventCount;

				if (current.Event != 0) vars.Uhara.Log("Event occurred: " + vars.Utils.FNameToString(current.Event));
			}
		}
		else
		{
			current.Event = default(ulong);
			vars.LastEventCount = 0;
		}
	}
	else
	{
		current.Event = default(ulong);
		vars.LastEventCount = 0;
	}

	// Cycle Number
	if (isDLC && vars.CycleSubsystem != IntPtr.Zero)
	{
		current.CycleIndex = vars.Resolver.Read<int>(vars.CycleSubsystem + 0x100);
	}
	else { current.CycleIndex = -1; }

	if (vars.LoadingSubsystem != IntPtr.Zero) current.bIsLoading = vars.Resolver.Read<bool>(vars.LoadingSubsystem + 0x48);
	else current.bIsLoading = false;

	// Cycle Number change log
	if (old.CycleIndex != current.CycleIndex && current.CycleIndex >= 0)
		vars.Uhara.Log("CycleIndex: " + current.CycleIndex + " (Cycle " + (current.CycleIndex + 1) + ")");

	// Date and Pause State
	if (vars.TimeSystem != IntPtr.Zero)
	{
		current.CurrentDate = vars.Resolver.Read<int>(vars.TimeSystem + 0x130);
		current.PauseState = vars.Resolver.Read<byte>(vars.TimeSystem + 0x140);
	}
	else
	{
		current.CurrentDate = 0;
		current.PauseState = 0;
	}

	// Cutscene Name
	if (vars.CutsceneManager != IntPtr.Zero)
	{
		uint currentCutsceneFName = vars.Resolver.Read<uint>(vars.CutsceneManager + 0x120, 0x2E8, 0x290, 0x18);
		string cutsceneName = vars.Utils.FNameToString(currentCutsceneFName);

		if (!string.IsNullOrEmpty(cutsceneName) && cutsceneName != "None") current.CutsceneName = cutsceneName;
		else current.CutsceneName = "";
	}
	else
	{
		current.CutsceneName = "";
	}

	// Logs for changes of Cutscene Name, Cutscene Overlay and Current Date
	if (old.CutsceneName != current.CutsceneName)
		vars.Uhara.Log("CutsceneName: " + old.CutsceneName + " -> " + current.CutsceneName);

	if (old.CutsceneOverlay != current.CutsceneOverlay)
		vars.Uhara.Log("CutsceneOverlay: " + old.CutsceneOverlay.ToString("X") + " -> " + current.CutsceneOverlay.ToString("X"));

	if (old.CurrentDate != current.CurrentDate)
		vars.Uhara.Log("CurrentDate: " + old.CurrentDate + " -> " + current.CurrentDate);
}

start
{
	return old.World == "MainMenu" && (current.World == "StartLevel" || current.World == "StartLevel_DLC1");
}

onStart
{
	timer.IsGameTimePaused = true;

	vars.CompletedDays.Clear();
	vars.ProcessedEvents.Clear();
	vars.LastEventCount = 0;

	old.Chapter = "";
	old.Event = default(ulong);
	old.CycleIndex = -1;
	old.CurrentDate = 0;
	vars.Uhara.Log("Run started");
}

// isLoading
// {
//     return current.bIsLoading
//         || current.CutsceneOverlay != IntPtr.Zero
//         || (!current.bIsGameWindowFocused && current.PauseState != 0)
//         || (current.IsPauseMenuOpen == IntPtr.Zero && current.PauseState != 0)
//         || (current.World != "StartLevel" && current.World != "StartLevel_DLC1");
// }

isLoading
{
    return current.bIsLoading
        || current.CutsceneOverlay != IntPtr.Zero
        || (current.World != "StartLevel" && current.World != "StartLevel_DLC1");
}

split
{
	bool inGameWorld = current.World == "StartLevel" || current.World == "StartLevel_DLC1";

	// Split on chapter change
	if (inGameWorld && !string.IsNullOrEmpty(old.Chapter) && old.Chapter != "None" && old.Chapter != current.Chapter)
	{
		if (settings.ContainsKey(old.Chapter) && settings[old.Chapter]) return true;
	}

	// Split on change of day waking up
	if (inGameWorld && settings["WakeUpDay"] && old.CurrentDate != 0 && old.CurrentDate != current.CurrentDate)
	{
		if (vars.CompletedDays.Add(current.CurrentDate)) return true;
	}

	// Split on event occurance
	if (inGameWorld && current.Chapter == "BP_ACT3_FinalDay_Chapter_C" && old.Event != current.Event && current.Event != 0)
	{
		var eventName = vars.Utils.FNameToString(current.Event);

		if (!string.IsNullOrEmpty(eventName) && eventName != "None" && vars.ProcessedEvents.Add(current.Event))
		{
			if (settings.ContainsKey(eventName) && settings[eventName]) return true;
		}
	}

	// Split on cycle change (DLC only - to be changed)
	// if (inGameWorld && settings["DLCCycleSplits"] && old.CycleIndex >= 0 && current.CycleIndex > old.CycleIndex) return true;
}

reset
{
	return settings["AutoReset"] && old.World != "MainMenu" && current.World == "MainMenu";
}

onReset
{
	old.Chapter = "";
	old.Event = default(ulong);
	old.CycleIndex = -1;
	old.CurrentDate = 0;

	vars.ClearCachedState();
	vars.CompletedDays.Clear();
	vars.ProcessedEvents.Clear();

	vars.Uhara.Log("Run reset");
}

exit
{
	timer.IsGameTimePaused = true;
	vars.Uhara.Log("Process exit");
}
state("TheAlters-Win64-Shipping") {}

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
        { "LastVariable", true, "Last Variable DLC (INCOMPLETE)", null }
    };
    vars.Uhara.Settings.Create(_settings);

    vars.CompletedDays = new HashSet<int>();
    vars.ProcessedEvents = new HashSet<ulong>();

    vars.ChaptersManager = IntPtr.Zero;
    vars.EventsSubsystem = IntPtr.Zero;
    vars.LastEventCount = 0;
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

    // Load removal watchers
    vars.Resolver.Watch<int>("Loading", vars.Utils.GEngine, 0x1220, 0x210, 0x50);
    vars.Resolver.Watch<byte>("CutsceneActive", vars.Utils.GEngine, 0x1220, 0x38, 0x0, 0x30, 0x358, 0x760, 0x1DC);
    vars.Uhara["CutsceneActive"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;

    // Day progression watcher
    vars.Resolver.Watch<int>("WakeUpDay", vars.Utils.GWorld, 0x158, 0x748, 0xE0);
    vars.Uhara["WakeUpDay"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;

    vars.ChaptersManager = IntPtr.Zero;
    vars.EventsSubsystem = IntPtr.Zero;
    vars.LastEventCount = 0;

    current.World = "";
    current.Chapter = "";
    current.WakeUpDay = 0;
    current.Event = default(ulong);
}

update
{
    vars.Uhara.Update();

    var world = vars.Utils.FNameToString(current.GWorldName);
    if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
    if (old.World != current.World) vars.Uhara.Log("World: " + current.World);

    // Reset cached runtime state when returning to main menu
    if (current.World == "MainMenu" && old.World != "MainMenu")
    {
        vars.ChaptersManager = IntPtr.Zero;
        vars.EventsSubsystem = IntPtr.Zero;
        vars.LastEventCount = 0;

        current.Chapter = "";
        current.Event = default(ulong);

        vars.Uhara.Log("Returned to MainMenu, cached world state cleared");
    }

    // Resolve P9ChaptersManager from GameInstance subsystem collection
    if (vars.ChaptersManager == IntPtr.Zero && !string.IsNullOrEmpty(current.World) && current.World != "None"
        && current.World != "MainMenu" && current.World != "PsoPrecompilationScreenLevel")
    {
        try
        {
            var subsystemCount = vars.Resolver.Read<int>(vars.Utils.GEngine, 0x1220, 0x110);

            for (int i = 0; i < subsystemCount; i++)
            {
                IntPtr subsystem;

                try { subsystem = vars.Resolver.Read<IntPtr>(vars.Utils.GEngine, 0x1220, 0x108, 0x18 * i + 0x8); }
                catch { continue; }

                if (subsystem == IntPtr.Zero) continue;

                try
                {
                    var subsystemName = vars.Utils.FNameToString(vars.Resolver.Read<uint>(subsystem + 0x18));

                    if (string.IsNullOrEmpty(subsystemName) || subsystemName == "None") continue;

                    if (subsystemName.StartsWith("P9ChaptersManager"))
                    if (subsystemName.StartsWith("P9EventsSubsystem"))
					{
						vars.EventsSubsystem = subsystem;

						try { vars.LastEventCount = vars.Resolver.Read<int>(vars.EventsSubsystem + 0xF0, 0x30); }
						catch { vars.LastEventCount = 0; }

						vars.Uhara.Log("P9EventsSubsystem found at " + subsystem.ToString("X"));
						break;
					}
                }
                catch { }
            }
        }
        catch { }
    }

    // Resolve P9EventsSubsystem from the world-side subsystem root
    if (vars.EventsSubsystem == IntPtr.Zero && !string.IsNullOrEmpty(current.World) && current.World != "None"
        && current.World != "MainMenu" && current.World != "PsoPrecompilationScreenLevel")
    {
        try
        {
            var worldSubsystemsRoot = vars.Resolver.Read<IntPtr>(vars.Utils.GWorld, 0x860);

            if (worldSubsystemsRoot != IntPtr.Zero)
            {
                int[] eventsSubsytemOffsets = { 0x4E8, 0x518 };

                foreach (var offset in eventsSubsytemOffsets)
                {
                    IntPtr subsystem;

                    try { subsystem = vars.Resolver.Read<IntPtr>(worldSubsystemsRoot + offset); }
                    catch { continue; }

                    if (subsystem == IntPtr.Zero) continue;

                    try
                    {
                        var subsystemName = vars.Utils.FNameToString(vars.Resolver.Read<uint>(subsystem + 0x18));

                        if (string.IsNullOrEmpty(subsystemName) || subsystemName == "None") continue;

                        if (subsystemName.StartsWith("P9EventsSubsystem"))
                        {
                            vars.EventsSubsystem = subsystem;
                            vars.LastEventCount = 0;
                            vars.Uhara.Log("P9EventsSubsystem found at " + subsystem.ToString("X"));
                            break;
                        }
                    }
                    catch { }
                }
            }
        }
        catch { }
    }

    // Read current chapter directly from P9ChaptersManager->CurrentChapter->NamePrivate
    if (vars.ChaptersManager != IntPtr.Zero)
    {
        var currentChapterPtr = vars.Resolver.Read<IntPtr>(vars.ChaptersManager + 0x138);

        if (currentChapterPtr != IntPtr.Zero)
        {
            var currentChapterFName = vars.Resolver.Read<uint>(currentChapterPtr + 0x18);
            var chapter = vars.Utils.FNameToString(currentChapterFName);

            if (!string.IsNullOrEmpty(chapter) && chapter != "None") current.Chapter = chapter;
        }
    }

    if (old.Chapter != current.Chapter) vars.Uhara.Log("Chapter: " + old.Chapter + " -> " + current.Chapter);

    // Read newest event from P9EventsSubsystem->EventRecorder->Records
    if (vars.EventsSubsystem != IntPtr.Zero)
    {
        var eventsList = vars.Resolver.Read<IntPtr>(vars.EventsSubsystem + 0xF0, 0x28);
        var eventCount = vars.Resolver.Read<int>(vars.EventsSubsystem + 0xF0, 0x30);

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

    old.World = "";
    old.Chapter = "";
    old.Event = default(ulong);
    old.WakeUpDay = 0;

    vars.Uhara.Log("Run started");
}

isLoading
{
    return current.Loading != 0 || current.CutsceneActive == 1 || (current.World != "StartLevel" && current.World != "StartLevel_DLC1");
}

split
{
    // Split when completing a chapter
    if (!string.IsNullOrEmpty(old.Chapter) && old.Chapter != "None" && old.Chapter != current.Chapter)
    {
        if (settings[old.Chapter]) return true;
    }

    // Split when waking up on a new day
    if (settings["WakeUpDay"] && old.WakeUpDay != 0 && old.WakeUpDay != current.WakeUpDay)
    {
        if (vars.CompletedDays.Add(current.WakeUpDay)) return true;
    }

    // Split on selected final-day ending events
    if (current.Chapter == "BP_ACT3_FinalDay_Chapter_C" && old.Event != current.Event && current.Event != 0)
    {
        var eventName = vars.Utils.FNameToString(current.Event);

        if (!string.IsNullOrEmpty(eventName) && eventName != "None" && vars.ProcessedEvents.Add(current.Event))
        {
            if (settings[eventName]) return true;
        }
    }
}

reset
{
    return settings["AutoReset"] && old.World != "MainMenu" && current.World == "MainMenu";
}

onReset
{
    old.World = "";
    old.Chapter = "";
    old.Event = default(ulong);
    old.WakeUpDay = 0;

    vars.ChaptersManager = IntPtr.Zero;
    vars.EventsSubsystem = IntPtr.Zero;
    vars.LastEventCount = 0;

    vars.CompletedDays.Clear();
    vars.ProcessedEvents.Clear();

    current.Chapter = "";
    current.Event = default(ulong);

    vars.Uhara.Log("Run reset");
}

exit
{
    timer.IsGameTimePaused = true;
    vars.Uhara.Log("Process exit");
}
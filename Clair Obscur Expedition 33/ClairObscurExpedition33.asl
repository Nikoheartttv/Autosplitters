// Load Removal made by Nikoheart
// Prior Edits made by ISO2768-mK & PlaccidPenguin
// Complete overhaul and adaptation for uhara10 by Nikoheart
// Additional world splits and settings by ISO2768-mK
// Any queries/edits/changes needed, please contact at @hellonikoheart on X (Twitter) or @nikoheart.com on Bluesky
// or reach out within the #lrt-autosplitter-dev channel in the speedrunning Discord

state("Sandfall-Win64-Shipping") {}
state("SandFallGOG-Win64-Shipping") {}
state("Sandfall-WinGDK-Shipping") {}

startup
{
    vars.Ready = false; // ensures the game is fully loaded
    Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main"); // loads uhara10 helper library
    vars.Uhara.Settings.CreateFromXml("Components/ClairObscurExpedition33.Splits.xml"); // loads splits xml
    vars.HasLocalPlayers = false; // stores if the game has local players
    vars.PreBattleLoadStates = new HashSet<string>() { "InitBattle", "LoadDependencies", "Dependencies loaded" };
    vars.EncounterWon = new HashSet<string>();
    vars.WorldTransitionsEncountered = new HashSet<string>();
}

init
{
    vars.MiniMapOffset = 0x3C8; // default minimap offset
    vars.IsInTransitionOffset = 0x2F0; // default IsInTransition offset (0x298 + 0x58)
    vars.HasInputLockOffset = 0x291; // default HasInputLockFromPreCinematic offset
    vars.SequenceStartedOffset = 0x290; // default CS_SequenceStarted offset
    vars.GFTSIntermediateOffset = 0x360; // default GameFlowTransitionSystem intermediate offset
    vars.BattleWon = false; // stores if a battle has been won
    vars.NewGameStart = false; // stores if a new game has started
    vars.NewGamePlusStart = false; // stores if a new game plus has started
    vars.WaitForVersion = true; // stores if the game is waiting for the version to be detected
    vars.DetectedProjectVersion = ""; // stores the detected project version
    vars.EnteredGameplay = false;
    vars.DuollistePhase2Seen = false;
    vars.BattleLoadingGate = false;
    vars.PostCineTransitionActive = false; // latch post-cinematic transition
    vars.CinematicGapLatched = false; // latch for the bad gap window

    vars.Renoir3FinalFightCutscene = false;
	vars.Renoir3FinalFightCutsceneMaelleStartedStabbing = false;
	vars.Renoir3FinalFightCutsceneMaelleDoneStabbing = false;
	vars.Renoir3TimeStampStartStabbing = TimeStamp.Now;

    // Mod Detection
    vars.exeDir = Path.GetDirectoryName(game.MainModule.FileName);
    vars.paksFolder = Path.GetFullPath(Path.Combine(vars.exeDir, "..", "..", "Content", "Paks"));

    if (Directory.Exists(vars.paksFolder + @"\~mods"))
    {
        var modsMessage = MessageBox.Show(
            "Clair Obscur: Expedition 33 speedruns requires no mods to be in use.\n" +
            "If you are seeing this message, it means that the '~mods' folder has been detected.\n" +
            "Make sure to remove this folder to stop seeing this message and ensure the validity of a legitimate speedrun.\n",
            "Mods Folder Detected",
            MessageBoxButtons.OK,
            MessageBoxIcon.Question
        );

        if (modsMessage == DialogResult.OK) Application.Exit();
    }

    if (Directory.Exists(vars.paksFolder + @"\~mods")) throw new Exception("Mods detected. Stopping ASL.");

    // Initialize uhara10
    vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
    vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");

    // Custom FNameToString that looks at ulongs - uhara only does uint
    vars.FNameToString = (Func<ulong, string>)(fName =>
    {
        var nameIdx = (fName & 0x000000000000FFFF) >> 0x00;
        var chunkIdx = (fName & 0x00000000FFFF0000) >> 0x10;
        var number = (fName & 0xFFFFFFFF00000000) >> 0x20;

        IntPtr chunk = vars.Resolver.Read<IntPtr>(vars.Utils.FNames + 0x10 + (int)chunkIdx * 0x8);
        IntPtr entry = chunk + (int)nameIdx * sizeof(short);

        int length = vars.Resolver.Read<short>(entry) >> 6;
        string name = vars.Resolver.ReadString(length, ReadStringType.UTF8, entry + sizeof(short));

        return number == 0 ? name : name + "_" + number;
    });

    // Custom AOB Scan for GeneralProjectSettings to get ProjectVersion
    IntPtr GPSAOB = vars.Uhara.ScanRel(3, "48 8d 0d ?? ?? ?? ?? e8 ?? ?? ?? ?? 48 8b 05 ?? ?? ?? ?? 48 83 c4 ?? c3 cc 48 89 5c 24 ?? 57 48 83 ec ?? 48 8b d9 48 8b fa 48 8b 0a");
    vars.Resolver.WatchString("ProjectVersion", GPSAOB, 0x110, 0x440 + 0xB8, 0x0);

    // Always active variables
    vars.Resolver.Watch<uint>("GWorldName", vars.Utils.GWorld, 0x18);
    vars.Resolver.Watch<uint>("LocalPlayersPtr", vars.Utils.GEngine, 0x10A8, 0x38);
    vars.Resolver.Watch<uint>("PlayerControllerFName", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x18);
    vars.Uhara["PlayerControllerFName"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
    vars.Resolver.Watch<bool>("IsChangingMap", vars.Utils.GEngine, 0x10A8, 0x1D0);
    vars.Resolver.Watch<bool>("IsChangingArea", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0xDE8);
    vars.Resolver.Watch<bool>("LSW_HasAppeared", vars.Utils.GEngine, 0x10A8, 0xB08, 0x300);

    // bPlayerIsWaiting (used for post-cutscene load)
    vars.Resolver.Watch<byte>("bPlayerIsWaiting", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x4B0);
    vars.Uhara["bPlayerIsWaiting"].FailAction = MemoryWatcher.ReadFailAction.DontUpdate;
    vars.Resolver.Watch<byte>("BattleFlowState", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x9B0);
    vars.Uhara["BattleFlowState"].FailAction = MemoryWatcher.ReadFailAction.DontUpdate;

    // Cinematic System
    vars.Resolver.Watch<uint>("CS_CinematicName", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, 0xA8, 0x290, 0x18);
    vars.Uhara["CS_CinematicName"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
    vars.Resolver.Watch<bool>("CS_IsPlayingCinematic", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, 0x238);
    vars.Uhara["CS_IsPlayingCinematic"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
    vars.Resolver.Watch<bool>("CS_CinematicPaused", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, 0x239);
    vars.Uhara["CS_CinematicPaused"].FailAction = MemoryWatcher.ReadFailAction.DontUpdate;
    // CurrentTriggerCinematicParameters.PostCinematicParameters.GameFlowTransitionRequest.TransitionType (0x1E8)
    vars.Resolver.Watch<byte>("CS_PostCineTransitionType", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, 0x1E8);
    vars.Uhara["CS_PostCineTransitionType"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;

    // Battle Manager
    vars.Resolver.Watch<ulong>("BattleManagerEncounterName", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x920, 0x190);
    vars.Uhara["BattleManagerEncounterName"].FailAction = MemoryWatcher.ReadFailAction.DontUpdate;
    vars.Resolver.Watch<byte>("BattleEndState", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x920, 0x910);
    vars.Uhara["BattleEndState"].FailAction = MemoryWatcher.ReadFailAction.DontUpdate;
    // only in Vxxx
    vars.Resolver.WatchString("BattleDebugLastFlowState", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x920, 0x9D8, 0x0);
    vars.Uhara["BattleDebugLastFlowState"].FailAction = MemoryWatcher.ReadFailAction.DontUpdate;

    // Player Camera Manager
    vars.Resolver.Watch<float>("PCMInGame", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x348, 0x1390);
    vars.Uhara["PCMInGame"].FailAction = MemoryWatcher.ReadFailAction.DontUpdate;

    // Set up default values
    current.World = "";
    current.PlayerController = "";
    current.MiniMapActive = false;
    current.CurrentCinematic = "";
    current.EncounterName = "None";
    current.CS_IsPlayingCinematic = false;
    current.CS_CinematicPaused = false;
    current.CS_SequenceStarted = false;
    current.CS_HasInputLockFromPreCinematic = false;
    current.CS_IsInTransition = false;
    current.BattleManagerEncounterName = 0;
    current.BattleEndState = 0;
    current.BattleFlowState = 0;
    current.BattleDebugLastFlowState = "None";
    current.GFTS_TransitionType = 0;
    current.GFTS_Phase = 0;
    current.CS_PostCineTransitionType = 0;
    current.ProjectVersion = "";

    // Game Start events
    vars.Events.FunctionFlag("StartGameTriggered", "WBP_MM_MainMenu_C", "WBP_MM_MainMenu_C", "OnStartGameSettingsApplied");
    vars.Events.FunctionFlag("NGPlusStartGameTriggeredFirst", "WBP_SavePointMenu_C", "WBP_SavePointMenu_C", "OnFirstNewGamePlusPopupAnswered");
    vars.Events.FunctionFlag("NGPlusStartGameTriggeredSecond", "WBP_SavePointMenu_C", "WBP_SavePointMenu_C", "OnSecondNewGamePlusPopupAnswered");

    // From Main Menu to Game load removal active
    vars.Events.FunctionFlag("MainMenuGameStart", "WBP_MM_MainMenu_C", "WBP_MM_MainMenu_C", "OnFadeToBlackFinished");

    // Load Removal events
    vars.Events.FunctionFlag("LoadingScreenStarted", "WBP_LoadingScreen_Expedition33_C", "LoadingScreenWidget", "StartLoadingScreen");

    // Versions without BattleDebugLastFlowState use this event-based battle gate.
    vars.Events.FunctionFlag("BattleStartWithoutDebugFlowState", "WBP_HUD_BattleScreen_C", "WBP_HUD_BattleScreen_C", "ExecuteUbergraph_WBP_HUD_BattleScreen");

    // Final Renoir Third Fight Load Removal
    vars.Events.FunctionFlag("Renoir3FinalFightCutsceneStarted", "SEQ_Skill_Curator_Finisher_DirectorBP_C", "SEQ_Skill_Curator_Finisher_DirectorBP_C", "SequenceEvent__ENTRYPOINTSEQ_Skill_Curator_Finisher_DirectorBP");
	vars.Renoir3RTDelta = TimeSpan.FromSeconds(13.97);
	vars.Events.FunctionFlag("Renoir3FinalFightCutsceneMaelleDoneStabbing", "ABP_Facial_Cine_Maelle_C", "ABP_Facial_Cine_Maelle_C", "EvaluateGraphExposedInputs_ExecuteUbergraph_ABP_Facial_Cine_Main_AnimGraphNode_TransitionResult_09D0F12D43EE55E3398A2E9FD396BFEF");

    vars.Ready = true;
}

update
{
    vars.Uhara.Update();

    // Project Version Detection
    if (vars.WaitForVersion)
    {
        string projectVersion = (current.ProjectVersion ?? "").Trim();
        if (string.IsNullOrEmpty(projectVersion)) return;

        vars.DetectedProjectVersion = projectVersion;
        vars.Uhara.Log("Detected Project Version: " + projectVersion);

        switch (projectVersion)
        {
            case "1.1.1.0":
                vars.MiniMapOffset = 0x3C8;
                vars.IsInTransitionOffset = 0x358;
                vars.HasInputLockOffset = 0x291;
                vars.SequenceStartedOffset = 0x290;
                vars.GFTSIntermediateOffset = 0x340;
                break;
            case "1.2.0.0": case "1.2.1.0":
            case "1.2.2.0": case "1.2.3.0": case "1.3.0.0":
            case "1.3.1.0":
                vars.MiniMapOffset = 0x3C8;
                vars.IsInTransitionOffset = 0x358;
                vars.HasInputLockOffset = 0x291;
                vars.SequenceStartedOffset = 0x290;
                vars.GFTSIntermediateOffset = 0x340;
                break;
            case "1.4.0.0":
                vars.MiniMapOffset = 0x3D0;
                vars.IsInTransitionOffset = 0x358;
                vars.HasInputLockOffset = 0x291;
                vars.SequenceStartedOffset = 0x290;
                vars.GFTSIntermediateOffset = 0x350;
                break;
            case "1.5.0.0": case "1.5.1.0": case "1.5.2.0":
            case "1.5.3.0": case "1.5.4.0":
            case "1.5.5.0":
            case "1.5.6.0":
                vars.MiniMapOffset = 0x3D0;
                vars.IsInTransitionOffset = 0x350;
                vars.HasInputLockOffset = 0x299;
                vars.SequenceStartedOffset = 0x298;
                vars.GFTSIntermediateOffset = 0x360;
                break;
            default:
                MessageBox.Show(
                    "This version of Clair Obscur: Expedition 33 is not explicitly supported by the autosplitter.\n" +
                    "Detected ProjectVersion: " + projectVersion + "\n\n" +
                    "The autosplitter will try to assign offsets based on prior supported versions, " +
                    "but load removal or splits may be inaccurate until the script is updated.\n\n" +
                    "If this version has not yet been updated for the autosplitter, please contact @Nikoheart " +
                    "in #lrt-autosplitter-dev in the speedrunning Discord.",
                    "Unsupported Game Version Detected",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning);
                var cleanVersion = projectVersion.Replace(".", "");
                int parsedVersion;
                if (int.TryParse(cleanVersion, out parsedVersion))
                {
                    vars.MiniMapOffset = parsedVersion <= 1310 ? 0x3C8 : 0x3D0;
                    vars.IsInTransitionOffset = parsedVersion < 1500 ? 0x358 : 0x350;
                    vars.HasInputLockOffset = parsedVersion < 1500 ? 0x291 : 0x299;
                    vars.SequenceStartedOffset = parsedVersion < 1500 ? 0x290 : 0x298;
                    vars.GFTSIntermediateOffset = parsedVersion < 1400 ? 0x340 : 0x360;
                }
                break;
        }

        vars.WaitForVersion = false;
        return;
    }

    // Versions without BattleDebugLastFlowState use the event-based battle gate.
    if (vars.DetectedProjectVersion == "1.1.1.0")
    {
        if (!vars.BattleLoadingGate && old.BattleFlowState == 0 && current.BattleFlowState == 2)
        {
            vars.BattleLoadingGate = true;
        }

        if (vars.BattleLoadingGate && vars.Resolver.CheckFlag("BattleStartWithoutDebugFlowState"))
        {
            vars.BattleLoadingGate = false;
        }
    }

    // Check if Player Controller has an address
    vars.HasLocalPlayers = current.LocalPlayersPtr != 0;

    // World Name
    if (current.World == "" && current.GWorldName != 0 || current.GWorldName != old.GWorldName)
    {
        var world = vars.Utils.FNameToString(current.GWorldName);
        if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
        if (old.World != current.World) vars.Uhara.Log("World: " + current.World);
    }

    // Player Controller Name
    if (!vars.HasLocalPlayers || current.PlayerControllerFName == 0)
    {
        current.PlayerController = "";
    }
    else if (current.PlayerControllerFName != old.PlayerControllerFName || string.IsNullOrEmpty(current.PlayerController))
    {
        var pc = vars.Utils.FNameToString(current.PlayerControllerFName);
        if (!string.IsNullOrEmpty(pc) && pc != "None") current.PlayerController = pc;
    }

    // From Main Menu to first cutscene load removal
    if (vars.Resolver.CheckFlag("MainMenuGameStart")) vars.EnteredGameplay = true;
    if (vars.EnteredGameplay && current.CS_IsPlayingCinematic) vars.EnteredGameplay = false;

    // New Game Detection between New Game / New Game Plus
    if (vars.Resolver.CheckFlag("StartGameTriggered")) vars.NewGameStart = true;
    if (vars.Resolver.CheckFlag("NGPlusStartGameTriggeredFirst")) vars.NewGamePlusStart = true;
    if (vars.Resolver.CheckFlag("NGPlusStartGameTriggeredSecond")) vars.NewGamePlusStart = true;

    // Version-dependent GameFlowTransitionSystem reads
    current.GFTS_TransitionType = vars.Resolver.Read<byte>("GFTS_TransitionType", vars.Utils.GWorld, 0x158, vars.GFTSIntermediateOffset, 0xA8);
    current.GFTS_Phase = vars.Resolver.Read<byte>("GFTS_Phase", vars.Utils.GWorld, 0x158, vars.GFTSIntermediateOffset, 0xB8);

    if (!vars.Renoir3FinalFightCutscene && vars.Resolver.CheckFlag("Renoir3FinalFightCutsceneStarted"))
	{
		vars.Renoir3FinalFightCutscene = true;
		vars.Renoir3TimeStampStartStabbing = TimeStamp.Now;
	}

	if (vars.Renoir3FinalFightCutscene)
	{
		if (vars.Resolver.CheckFlag("Renoir3FinalFightCutsceneMaelleDoneStabbing")) vars.Renoir3FinalFightCutsceneMaelleDoneStabbing = true;
		vars.Renoir3FinalFightCutsceneMaelleStartedStabbing = ((TimeSpan)(TimeStamp.Now - vars.Renoir3TimeStampStartStabbing) > vars.Renoir3RTDelta);
		if (current.BattleDebugLastFlowState == "StartBattleEndFlow: Victory")
		{
			vars.Renoir3FinalFightCutscene = false;
			vars.Renoir3FinalFightCutsceneMaelleStartedStabbing = false;
			vars.Renoir3FinalFightCutsceneMaelleDoneStabbing = false;
		}
	}

    // Controller-specific reads
    if (current.PlayerController == "BP_jRPG_Controller_World_C" || current.PlayerController == "BP_PlayerController_WorldMap_C")
    {
        current.MiniMapActive = vars.Resolver.Read<bool>("MiniMapActive", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x980, vars.MiniMapOffset, 0x368);
        current.CS_IsInTransition = vars.Resolver.Read<bool>("CS_IsInTransition", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, vars.IsInTransitionOffset);
        current.CS_HasInputLockFromPreCinematic = vars.Resolver.Read<bool>("CS_HasInputLockFromPreCinematic", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, vars.HasInputLockOffset);
        current.CS_SequenceStarted = vars.Resolver.Read<bool>("CS_SequenceStarted", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, vars.SequenceStartedOffset);

        if (old.BattleEndState == 0 && current.BattleEndState == 1) vars.BattleWon = true;

        if (current.CS_CinematicName != old.CS_CinematicName)
        {
            var name = vars.Utils.FNameToString(current.CS_CinematicName);
            if (!string.IsNullOrEmpty(name))
            {
                current.CurrentCinematic = name;
                if (current.CurrentCinematic == "CS_FB_DuollistePhase2") vars.DuollistePhase2Seen = true;
            }
        }

        if (current.BattleManagerEncounterName != old.BattleManagerEncounterName)
        {
            var encounter = vars.FNameToString(current.BattleManagerEncounterName);
            if (!string.IsNullOrEmpty(encounter)) current.EncounterName = encounter;
            else current.EncounterName = "None";
        }

        if (old.BattleDebugLastFlowState != current.BattleDebugLastFlowState && current.BattleDebugLastFlowState == "StartBattleEndFlow: Victory" ||
            old.BattleEndState != current.BattleEndState && current.BattleEndState == 1)
        {
            vars.BattleWon = true;
        }

        if (old.BattleFlowState != current.BattleFlowState) vars.Uhara.Log("BattleFlowState: " + current.BattleFlowState);
        if (old.BattleDebugLastFlowState != current.BattleDebugLastFlowState) vars.Uhara.Log("BattleDebugLastFlowState: " + current.BattleDebugLastFlowState);
    }
    else
    {
        current.MiniMapActive = false;
        current.CurrentCinematic = "";
        current.EncounterName = "None";
        current.CS_HasInputLockFromPreCinematic = false;
        vars.BattleWon = false;
    }

    // Latch post-cinematic transition when TransitionType == 1
    if (current.CS_PostCineTransitionType == 1) vars.PostCineTransitionActive = true;

    // Clear the post-cine latch only when the transition is fully over and no cinematic context remains
    if (current.GFTS_TransitionType == 0 && !current.CS_IsPlayingCinematic && !current.CS_CinematicPaused &&
        (string.IsNullOrEmpty(current.CurrentCinematic) || current.CurrentCinematic == "None"))
    {
        vars.PostCineTransitionActive = false;
    }

    // Latch the cinematic gap when we're in a post-cine transition,
    // GFTS black-screen, and the player is in the wait state (9 or 15).
    if (vars.PostCineTransitionActive && current.GFTS_TransitionType == 1 &&
        (current.bPlayerIsWaiting == 9 || current.bPlayerIsWaiting == 15))
    {
        vars.CinematicGapLatched = true;
    }

    // Clear the gap latch once the black-screen is over or CinematicSystem is clearly active again
    if (current.GFTS_TransitionType == 0 || current.CS_IsPlayingCinematic || current.CS_CinematicPaused) vars.CinematicGapLatched = false;
}

onStart
{
    timer.IsGameTimePaused = true;
    vars.BattleWon = false;
}

start
{
    if (settings["NewGamePlus"] && vars.NewGamePlusStart && vars.Resolver.CheckFlag("LoadingScreenStarted")) return true;
    else if (vars.NewGameStart && current.PlayerController == "BP_jRPG_Controller_World_C") return true;
}

split
{
    string worldEncounter = current.World + "-" + old.EncounterName;
    string phase1Key = worldEncounter + "_Phase1";

    // Leaving World splits
    string worldTransition = old.World + "-worldLeave";
    if ((current.World == "Level_Camp_Main" || current.World == "Level_WorldMap_Main_V2") &&
        !vars.WorldTransitionsEncountered.Contains(worldTransition))
    {
        vars.WorldTransitionsEncountered.Add(worldTransition);
        if (settings.ContainsKey(worldTransition) && settings[worldTransition])
            return true;
    }

    // Entering World splits
    worldTransition = current.World + "-worldEnter";
    if (old.World == "Level_WorldMap_Main_V2" &&
        !vars.WorldTransitionsEncountered.Contains(worldTransition))
    {
        vars.WorldTransitionsEncountered.Add(worldTransition);
        if (settings.ContainsKey(worldTransition) && settings[worldTransition])
            return true;
    }

    // Eveque Split
    if (settings["Eveque"] && vars.BattleWon && old.EncounterName.StartsWith("SM_Eveque") && current.EncounterName == "None" && !vars.EncounterWon.Contains("Eveque"))
    {
        vars.EncounterWon.Add("Eveque");
        vars.BattleWon = false;
        return true;
    }

    // Curator Split
    if (settings["Curator"] && vars.BattleWon && old.EncounterName.StartsWith("GO_Curator_JumpTutorial") && current.EncounterName == "None" && !vars.EncounterWon.Contains("Curator"))
    {
        vars.EncounterWon.Add("Curator");
        vars.BattleWon = false;
        return true;
    }

    // Fake Paintress
    if (settings["FakePaintress"] && current.CurrentCinematic == "MCS_GoingInsideTheMonolith" && !vars.EncounterWon.Contains("FakePaintress"))
    {
        vars.EncounterWon.Add("FakePaintress");
        return true;
    }

    // Paintress Phase 1
    if (current.EncounterName == "L_Boss_Paintress_P1" && current.CurrentCinematic == "MCS_PaintressTransitionToPhase2" && settings.ContainsKey(phase1Key) &&
        settings[phase1Key] && !vars.EncounterWon.Contains("PaintressPhase1"))
    {
        vars.EncounterWon.Add("PaintressPhase1");
        return true;
    }

    // Renoir Phase 1
    if (current.EncounterName == "L_Boss_Curator_P1" && current.CurrentCinematic == "MCS_RenoirFightPhase2to3_PartLumiere" &&
        settings.ContainsKey(phase1Key) && settings[phase1Key] && !vars.EncounterWon.Contains("RenoirPhase1"))
    {
        vars.EncounterWon.Add("RenoirPhase1");
        return true;
    }

    // Duolliste Phase 2 / final victory
    if (settings.ContainsKey("Level_Side_CleasTower-Boss_Duolliste_P1") && settings["Level_Side_CleasTower-Boss_Duolliste_P1"] && current.World == "Level_Side_CleasTower" &&
        old.EncounterName == "Boss_Duolliste_P1" && vars.DuollistePhase2Seen && vars.BattleWon && current.EncounterName == "None" && !vars.EncounterWon.Contains("DuollistePhase2"))
    {
        vars.EncounterWon.Add("DuollistePhase2");
        vars.DuollistePhase2Seen = false;
        vars.BattleWon = false;
        return true;
    }

    // Generic encounter split
    if (current.World != "Level_MainMenu" && vars.BattleWon && old.EncounterName != "None" && current.EncounterName == "None" && settings.ContainsKey(worldEncounter) && settings[worldEncounter])
    {
        vars.BattleWon = false;
        return true;
    }

    // Act splits
    if (old.CurrentCinematic != current.CurrentCinematic && !string.IsNullOrEmpty(current.CurrentCinematic) &&
        settings.ContainsKey(current.CurrentCinematic) && settings[current.CurrentCinematic]) return true;
}

isLoading
{
    // If init is not ready or version hasn't been detected
    if (!vars.Ready || vars.WaitForVersion) return true;

    // Treat as loading when sequence is "done" but player is still in wait state
    bool cinematicFinishing = !current.CS_SequenceStarted && current.bPlayerIsWaiting == 15;

    // Gap hold: we latched that we're in the bad transition gap
    bool cinematicGapHold = vars.CinematicGapLatched;

    // Dependancies init loading usually held in BattleDebugLastFlowState - alternative timing or v1.1.1.0
    bool battleLoadingWithoutDebugFlowState = vars.DetectedProjectVersion == "1.1.1.0" && vars.BattleLoadingGate;

    bool battleLoadingWithDebugFlowState = vars.DetectedProjectVersion != "1.1.1.0" && current.BattleFlowState == 2 &&
        vars.PreBattleLoadStates.Contains(current.BattleDebugLastFlowState);

    bool worldOrBattleLoading = !vars.HasLocalPlayers || current.World == "Map_Game_Bootstrap" ||
        current.IsChangingMap || current.IsChangingArea || current.LSW_HasAppeared ||
        (current.World != "Level_MainMenu" && current.PCMInGame < 0.5) ||
        battleLoadingWithDebugFlowState || (current.World == "Level_WorldMap_Main_V2" && current.MiniMapActive);

    // Only treat non-black GFTS transitions as a load when we're in a cinematic context
    bool inCinematicBlackScreen = current.GFTS_TransitionType > 1 && (current.CS_IsPlayingCinematic || current.CS_CinematicPaused);

    bool cinematicLoading = inCinematicBlackScreen || current.CS_HasInputLockFromPreCinematic ||
        (!current.CS_IsInTransition && current.CS_IsPlayingCinematic && current.CS_CinematicPaused);

    bool renoir3FinalFightCutscene = vars.Renoir3FinalFightCutscene && vars.Renoir3FinalFightCutsceneMaelleStartedStabbing && !vars.Renoir3FinalFightCutsceneMaelleDoneStabbing;

    return worldOrBattleLoading || battleLoadingWithoutDebugFlowState || cinematicLoading || cinematicFinishing || cinematicGapHold || renoir3FinalFightCutscene;
}

reset
{
    if (settings["AutoReset"] && old.World != "Level_MainMenu" && current.World == "Level_MainMenu") return true;
}

onReset
{
    vars.NewGameStart = false;
    vars.NewGamePlusStart = false;
    vars.BattleWon = false;
    vars.EnteredGameplay = false;
    vars.PostCineTransitionActive = false;
    vars.CinematicGapLatched = false;
    vars.BattleLoadingGate = false;
    vars.Renoir3FinalFightCutscene = false;
	vars.Renoir3FinalFightCutsceneMaelleStartedStabbing = false;
	vars.Renoir3FinalFightCutsceneMaelleDoneStabbing = false;
    vars.Renoir3TimeStampStartStabbing = TimeStamp.Now;
    vars.EncounterWon.Clear();
    vars.WorldTransitionsEncountered.Clear();
}

exit
{
    timer.IsGameTimePaused = true;
}
// Load Removal made by Nikoheart
// Prior Edits made by ISO2768-mK & PlaccidPenguin
// Complete overhaul and adaptation for uhara10 by Nikoheart
// Any queries/edits/changes needed, please contact at @hellonikoheart on X (Twitter) or @nikoheart.com on Bluesky
// or reach out within the #lrt-autosplitter-dev channel in the speedrunning Discord

state("Sandfall-Win64-Shipping") {}
state("SandFallGOG-Win64-Shipping") {}
state("Sandfall-WinGDK-Shipping") {}

startup
{
	vars.Ready = false;
	Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main");
	vars.Uhara.Settings.CreateFromXml("Components/ClairObscurExpedition33.Splits.xml");
	vars.TimerModel = new TimerModel { CurrentState = timer };
	vars.EncounterWon = new List<string>();
	vars.HasLocalPlayers = false;
	vars.MiniMapWatchRegistered = false;
	vars.paksFolder = "";

	vars.IgnoreEndCinematicTransitions = new HashSet<string>(StringComparer.Ordinal)
	{
		"SEQ_IW_Lumiere_EmmaArrives",
		"MCS_JarQuest_A"
	};
}

init
{
	vars.MiniMapOffset = 0x3C8;
	vars.PostCineOffset = 0x298;
	vars.BattleWon = false;
	vars.HasEnteredWorldMap = false;
	vars.NewGameStart = false;
	vars.NewGamePlusStart = false;
	vars.WaitForVersion = true;
	vars.DetectedProjectVersion = "";
	vars.Renoir3FinalFightCutscene = false;
	vars.Renoir3FinalFightCutsceneMaelleStartedStabbing = false;
	vars.Renoir3FinalFightCutsceneMaelleDoneStabbing = false;
	vars.Renoir3TimeStampStartStabbing = TimeStamp.Now;
	vars.CinematicTransitioning = false;
	vars.IgnoreEndCinematicTransition = false;
	vars.GameMenuOpen = false;
	vars.KeepTimerUnpaused = false;
	vars.MenuInterruptedCinematic = false;

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

	vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
	vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");
	if (vars.Utils.GEngine != IntPtr.Zero) vars.Uhara.Log("GEngine found at " + vars.Utils.GEngine.ToString("X"));
	if (vars.Utils.GWorld != IntPtr.Zero) vars.Uhara.Log("GWorld found at " + vars.Utils.GWorld.ToString("X"));
	if (vars.Utils.FNames != IntPtr.Zero) vars.Uhara.Log("FNames found at " + vars.Utils.FNames.ToString("X"));

	IntPtr GPSAOB = vars.Uhara.ScanRel(3, "48 8d 0d ?? ?? ?? ?? e8 ?? ?? ?? ?? 48 8b 05 ?? ?? ?? ?? 48 83 c4 ?? c3 cc 48 89 5c 24 ?? 57 48 83 ec ?? 48 8b d9 48 8b fa 48 8b 0a");
	vars.Uhara.Log("GeneralProjectSettings: " + GPSAOB.ToString("X"));
	vars.Resolver.WatchString("ProjectVersion", GPSAOB, 0x110, 0x440 + 0xB8, 0x0);

	// Always on
	vars.Resolver.Watch<uint>("GWorldName", vars.Utils.GWorld, 0x18);
	vars.Resolver.Watch<uint>("LocalPlayersPtr", vars.Utils.GEngine, 0x10A8, 0x38);
	vars.Resolver.Watch<uint>("PlayerControllerFName", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x18);
	vars.Resolver.Watch<bool>("IsChangingMap", vars.Utils.GEngine, 0x10A8, 0x1D0);
	vars.Resolver.Watch<bool>("IsChangingArea", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0xDE8);
	vars.Resolver.Watch<bool>("LSW_HasAppeared", vars.Utils.GEngine, 0x10A8, 0xB08, 0x300);

	// InGame
	vars.Resolver.Watch<byte>("CS_CinematicStatus", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, 0xA8, 0x288);
	vars.Uhara["CS_CinematicStatus"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
	vars.Resolver.Watch<uint>("CS_CinematicName", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, 0xA8, 0x290, 0x18);
	vars.Uhara["CS_CinematicName"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
	vars.Resolver.Watch<uint>("CS_CinematicSerialNumber", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, 0xA8, 0x2A8);
	vars.Uhara["CS_CinematicSerialNumber"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
	vars.Resolver.Watch<bool>("CS_IsPlayingCinematic", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, 0x238);
	vars.Uhara["CS_IsPlayingCinematic"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
	vars.Resolver.Watch<bool>("CS_CinematicPaused", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, 0x239);
	vars.Uhara["CS_CinematicPaused"].FailAction = MemoryWatcher.ReadFailAction.DontUpdate;
	vars.Resolver.Watch<ulong>("BattleManagerEncounterName", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x920, 0x190);
	vars.Uhara["BattleManagerEncounterName"].FailAction = MemoryWatcher.ReadFailAction.DontUpdate;
	vars.Resolver.Watch<byte>("BattleEndState", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x920, 0x910);
	vars.Uhara["BattleEndState"].FailAction = MemoryWatcher.ReadFailAction.DontUpdate;
	vars.Resolver.Watch<byte>("BattleFlowState", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x9B0);
	vars.Uhara["BattleFlowState"].FailAction = MemoryWatcher.ReadFailAction.DontUpdate;
	vars.Resolver.WatchString("BattleDebugLastFlowState", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x920, 0x9D8, 0x0);
	vars.Uhara["BattleDebugLastFlowState"].FailAction = MemoryWatcher.ReadFailAction.DontUpdate;
	vars.Resolver.Watch<float>("PCMInGame", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x348, 0x1390);
	vars.Uhara["PCMInGame"].FailAction = MemoryWatcher.ReadFailAction.DontUpdate;

	current.World = "";
	current.PlayerController = "";
	current.MiniMapActive = false;
	current.CurrentCinematic = "";
	current.EncounterName = "None";
	current.CS_CinematicStatus = 0;
	current.CS_CinematicName = 0;
	current.CS_CinematicSerialNumber = 0;
	current.CS_IsPlayingCinematic = false;
	current.CS_CinematicPaused = false;
	current.CS_EventBeforePostCinematicTransitionStarted = 0;
	current.BattleManagerEncounterName = 0;
	current.BattleEndState = 0;
	current.BattleFlowState = 0;
	current.BattleDebugLastFlowState = "None";
	current.ProjectVersion = "";

	vars.Events.FunctionFlag("StartGameTriggered", "WBP_MM_MainMenu_C", "WBP_MM_MainMenu_C", "OnStartGameSettingsApplied");
	vars.Events.FunctionFlag("NGPlusStartGameTriggeredFirst", "WBP_SavePointMenu_C", "WBP_SavePointMenu_C", "OnFirstNewGamePlusPopupAnswered");
	vars.Events.FunctionFlag("NGPlusStartGameTriggeredSecond", "WBP_SavePointMenu_C", "WBP_SavePointMenu_C", "OnSecondNewGamePlusPopupAnswered");
	vars.Events.FunctionFlag("LoadingScreenStarted", "WBP_LoadingScreen_Expedition33_C", "LoadingScreenWidget", "StartLoadingScreen");
	vars.Events.FunctionFlag("Renoir3FinalFightCutsceneStarted", "SEQ_Skill_Curator_Finisher_DirectorBP_C", "SEQ_Skill_Curator_Finisher_DirectorBP_C", "SequenceEvent__ENTRYPOINTSEQ_Skill_Curator_Finisher_DirectorBP");
	vars.Renoir3RTDelta = TimeSpan.FromSeconds(13.97);
	vars.Events.FunctionFlag("Renoir3FinalFightCutsceneMaelleDoneStabbing", "ABP_Facial_Cine_Maelle_C", "ABP_Facial_Cine_Maelle_C", "EvaluateGraphExposedInputs_ExecuteUbergraph_ABP_Facial_Cine_Main_AnimGraphNode_TransitionResult_09D0F12D43EE55E3398A2E9FD396BFEF");

	vars.Events.FunctionFlag("FadeOutCompleted", "BP_LatentAction_WaitForGameflowTransitionFadeOut_C", "BP_LatentAction_WaitForGameflowTransitionFadeOut_C", "OnFadeOutCompleted");
	vars.Events.FunctionFlag("PreCinematicInputLockTimerElapsed", "BP_CinematicSystem_C", "BP_CinematicSystem", "OnPreCinematicInputLockTimerElapsed");
	vars.Events.FunctionFlag("EnteringCinematicTransition", "WBP_Exploration_HUD_C", "WBP_Exploration_HUD_C", "OnTriggeringCinematic");
	vars.Events.FunctionFlag("EndCinematicTransition", "WBP_Exploration_HUD_C", "WBP_Exploration_HUD_C", "OnAfterPostCinematic");
	vars.Events.FunctionFlag("AfterCinematicWorldReturn", "BP_jRPG_Character_World_C", "BP_jRPG_Character_World_C", "ExecuteUbergraph_BP_jRPG_Character_World");
	vars.Events.FunctionFlag("AfterCinematicIntoBattle", "WBP_HUD_BattleScreen_C", "WBP_HUD_BattleScreen_C", "ExecuteUbergraph_WBP_HUD_BattleScreen");
	vars.Events.FunctionFlag("OnSequenceFinished", "BP_CinematicSystem_C", "BP_CinematicSystem", "OnSequenceFinished");

	vars.Events.FunctionFlag("GameMenuOpened", "BP_GameMenuScene_C", "BP_GameMenuScene_C", "ExecuteUbergraph_BP_GameMenuScene");
	vars.Events.FunctionFlag("GameMenuClosed", "WBP_GameMenu_v3_C", "WBP_GameMenu_v3_C", "BP_OnDeactivated");
	vars.Events.FunctionFlag("JournalOpened", "WBP_JournalEntry_C", "WBP_JournalEntry_C", "OnFocusReceived");

	vars.Ready = true;
}

update
{
	vars.Uhara.Update();

	if (vars.WaitForVersion)
	{
		string projectVersion = (current.ProjectVersion ?? "").Trim();
		if (string.IsNullOrEmpty(projectVersion)) return;

		vars.DetectedProjectVersion = projectVersion;
		vars.Uhara.Log("ProjectVersion: " + projectVersion);

		switch (projectVersion)
		{
			case "1.1.1.0": case "1.2.0.0": case "1.2.1.0":
			case "1.2.2.0": case "1.2.3.0": case "1.3.0.0":
			case "1.3.1.0":
				vars.MiniMapOffset = 0x3C8;
				vars.PostCineOffset = 0x298;
				break;
			case "1.4.0.0":
				vars.MiniMapOffset = 0x3D0;
				vars.PostCineOffset = 0x298;
				break;
			case "1.5.0.0": case "1.5.1.0": case "1.5.2.0":
			case "1.5.3.0": case "1.5.4.0":
			case "1.5.5.0":
				vars.MiniMapOffset = 0x3D0;
				vars.PostCineOffset = 0x2A0;
				break;
			default:
				var cleanVersion = projectVersion.Replace(".", "");
				int parsedVersion;
				if (int.TryParse(cleanVersion, out parsedVersion))
				{
					vars.MiniMapOffset = parsedVersion <= 1310 ? 0x3C8 : 0x3D0;
					vars.PostCineOffset = parsedVersion < 1500 ? 0x298 : 0x2A0;
				}
				break;
		}

		vars.WaitForVersion = false;
		return;
	}

	vars.HasLocalPlayers = current.LocalPlayersPtr != 0;

	var world = vars.Utils.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	if (old.World != current.World) vars.Uhara.Log("World: " + current.World);
	if (!vars.HasEnteredWorldMap && current.World == "Level_WorldMap_Main_V2") vars.HasEnteredWorldMap = true;

	var pc = vars.Utils.FNameToString(current.PlayerControllerFName);
	if (!string.IsNullOrEmpty(pc)) current.PlayerController = pc;
	if (old.PlayerController != current.PlayerController) vars.Uhara.Log("PlayerController: " + current.PlayerController);

	if (vars.Resolver.CheckFlag("StartGameTriggered")) vars.NewGameStart = true;
	if (vars.Resolver.CheckFlag("NGPlusStartGameTriggeredFirst")) vars.NewGamePlusStart = true;
	if (vars.Resolver.CheckFlag("NGPlusStartGameTriggeredSecond")) vars.NewGamePlusStart = true;

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

	bool validGameplayController = current.PlayerController == "BP_jRPG_Controller_World_C" || current.PlayerController == "BP_PlayerController_WorldMap_C";
	if (validGameplayController)
	{
		current.MiniMapActive = vars.Resolver.Read<bool>("MiniMapActive", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x980, vars.MiniMapOffset, 0x368);
		current.CS_EventBeforePostCinematicTransitionStarted = vars.Resolver.Read<ulong>("CS_EventBeforePostCinematicTransitionStarted", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, vars.PostCineOffset);

		var name = vars.Utils.FNameToString(current.CS_CinematicName);
		current.CurrentCinematic = !string.IsNullOrEmpty(name) ? name : old.CurrentCinematic;
		var encounter = vars.Utils.FNameToString(current.BattleManagerEncounterName);
		current.EncounterName = !string.IsNullOrEmpty(encounter) ? encounter : old.EncounterName;

		if (old.BattleDebugLastFlowState != current.BattleDebugLastFlowState && current.BattleDebugLastFlowState == "StartBattleEndFlow: Victory") vars.BattleWon = true;
		if (old.CurrentCinematic != current.CurrentCinematic) vars.Uhara.Log("CurrentCinematic: " + current.CurrentCinematic);
		if (old.EncounterName != current.EncounterName) vars.Uhara.Log("EncounterName: " + current.EncounterName);
		if (old.BattleDebugLastFlowState != current.BattleDebugLastFlowState) vars.Uhara.Log("BattleDebugLastFlowState: " + current.BattleDebugLastFlowState);
		if (current.CS_CinematicPaused != old.CS_CinematicPaused) vars.Uhara.Log("CS_CinematicPaused: " + current.CS_CinematicPaused);
		if (current.BattleFlowState != old.BattleFlowState) vars.Uhara.Log("BattleFlowState: " + current.BattleFlowState);
	}
	else
	{
		current.MiniMapActive = false;
		current.CurrentCinematic = "";
		current.EncounterName = "None";
		current.CS_EventBeforePostCinematicTransitionStarted = 0;
		vars.BattleWon = false;
	}

	if (vars.Resolver.CheckFlag("GameMenuOpened")) vars.GameMenuOpen = true;
	if (vars.Resolver.CheckFlag("GameMenuClosed")) vars.GameMenuOpen = false;

	vars.KeepTimerUnpaused = vars.GameMenuOpen || vars.Resolver.CheckFlag("JournalOpened");

	if ((vars.Resolver.CheckFlag("GameMenuOpened") || vars.Resolver.CheckFlag("JournalOpened")) && current.CS_IsPlayingCinematic) vars.MenuInterruptedCinematic = true;

	if (!current.CS_IsPlayingCinematic || vars.Resolver.CheckFlag("AfterCinematicWorldReturn") 
		|| vars.Resolver.CheckFlag("AfterCinematicIntoBattle") || vars.Resolver.CheckFlag("GameMenuClosed")) vars.MenuInterruptedCinematic = false;

	string cinematicForEndCheck = !string.IsNullOrEmpty(current.CurrentCinematic) && current.CurrentCinematic != "None" ? current.CurrentCinematic : old.CurrentCinematic;
	vars.IgnoreEndCinematicTransition = vars.IgnoreEndCinematicTransitions.Contains(cinematicForEndCheck);

	if (vars.Resolver.CheckFlag("FadeOutCompleted")) vars.CinematicTransitioning = true;
	if (vars.Resolver.CheckFlag("PreCinematicInputLockTimerElapsed")) vars.CinematicTransitioning = true;
	if (vars.Resolver.CheckFlag("OnSequenceFinished") && !vars.IgnoreEndCinematicTransition) vars.CinematicTransitioning = true;
	if (vars.Resolver.CheckFlag("EnteringCinematicTransition")) vars.CinematicTransitioning = false;
	if (vars.Resolver.CheckFlag("EndCinematicTransition") && !vars.IgnoreEndCinematicTransition) vars.CinematicTransitioning = true;

	if (vars.Resolver.CheckFlag("AfterCinematicWorldReturn")) vars.CinematicTransitioning = false;
	if (vars.Resolver.CheckFlag("AfterCinematicIntoBattle")) vars.CinematicTransitioning = false;

	// if (vars.CinematicTransitioning && validGameplayController && !current.IsChangingMap && !current.IsChangingArea && !current.LSW_HasAppeared)
	// if (vars.CinematicTransitioning && validGameplayController && (current.IsChangingMap || current.IsChangingArea || current.LSW_HasAppeared))
	if (vars.CinematicTransitioning && validGameplayController && old.PlayerController != current.PlayerController && current.PlayerController == "BP_jRPG_Controller_WorldMap_C")
	{
		vars.CinematicTransitioning = false;
	}
}

start
{
	if (settings["NewGamePlus"] && vars.NewGamePlusStart && vars.Resolver.CheckFlag("LoadingScreenStarted")) return true;
	else if (vars.NewGameStart && current.PlayerController == "BP_jRPG_Controller_World_C") return true;
}

onStart
{
	timer.IsGameTimePaused = true;
	vars.EncounterWon.Clear();
	vars.BattleWon = false;
	vars.Renoir3FinalFightCutscene = false;
	vars.Renoir3FinalFightCutsceneMaelleStartedStabbing = false;
	vars.Renoir3FinalFightCutsceneMaelleDoneStabbing = false;
}

split
{
	string worldEncounter = current.World + "-" + old.EncounterName;
	if (current.World != "Level_MainMenu" && vars.BattleWon && old.EncounterName != "None" && current.EncounterName == "None" && !vars.EncounterWon.Contains(worldEncounter))
	{
		vars.EncounterWon.Add(worldEncounter);
		vars.BattleWon = false;

		if (settings.ContainsKey(worldEncounter) && settings[worldEncounter]) return true;
	}

	if (old.CurrentCinematic != current.CurrentCinematic && !string.IsNullOrEmpty(current.CurrentCinematic))
	{
		if (settings.ContainsKey(current.CurrentCinematic) && settings[current.CurrentCinematic]) return true;
	}
}

isLoading
{
	if (!vars.Ready || vars.WaitForVersion) return true;

	if (current.CS_IsPlayingCinematic && current.CS_CinematicPaused) return true;

	bool loadingBlock = !vars.HasLocalPlayers || current.World == "Map_Game_Bootstrap"
			|| current.IsChangingMap || current.IsChangingArea || current.LSW_HasAppeared
			|| (current.World != "Level_MainMenu" && current.PCMInGame < 0.5)
			|| (current.BattleFlowState == 2 && (
				current.BattleDebugLastFlowState == "InitBattle" ||
				current.BattleDebugLastFlowState == "LoadDependencies" ||
				current.BattleDebugLastFlowState == "Dependencies loaded"))
			|| (current.CS_IsPlayingCinematic && current.CurrentCinematic == "None")
			|| (current.CS_IsPlayingCinematic && (
				(!vars.MenuInterruptedCinematic && current.CS_CinematicPaused) ||
				(current.CS_CinematicStatus == 0
					&& ((current.CurrentCinematic == "MCS_GobluOutro" && current.CS_CinematicSerialNumber == 3 && current.CS_EventBeforePostCinematicTransitionStarted != 0) ||
						(current.CurrentCinematic == "MCS_PostDuallist" && current.CS_CinematicSerialNumber == 3 && current.CS_EventBeforePostCinematicTransitionStarted != 0) ||
						(current.CurrentCinematic == "MCS_DiscoveringTheTruth_P2" && current.CS_CinematicSerialNumber == 3 && current.CS_EventBeforePostCinematicTransitionStarted != 0) ||
						(current.CurrentCinematic == "CS_GPE_MonolithInterior_Locomotive_MonocoToLumiere" && current.CS_CinematicSerialNumber == 3 && current.CS_EventBeforePostCinematicTransitionStarted != 0) ||
						(current.CurrentCinematic == "CS_CleasFlyingHouse_DuallisteDeath" && current.CS_CinematicSerialNumber == 3 && current.CS_EventBeforePostCinematicTransitionStarted != 0) ||
						(current.CurrentCinematic == "CS_CleasFlyingHouse_EvequeDeath" && current.CS_CinematicSerialNumber == 3 && current.CS_EventBeforePostCinematicTransitionStarted != 0) ||
						(current.CurrentCinematic == "CS_CleasFlyingHouse_GobluDeath" && current.CS_CinematicSerialNumber == 3 && current.CS_EventBeforePostCinematicTransitionStarted != 0) ||
						(current.CurrentCinematic == "CS_CleasFlyingHouse_LampmasterDeath" && current.CS_CinematicSerialNumber == 3 && current.CS_EventBeforePostCinematicTransitionStarted != 0) ||
						(current.CurrentCinematic == "MCS_MirrorCleaOutro" && current.CS_CinematicSerialNumber == 3 && current.CS_EventBeforePostCinematicTransitionStarted != 0)))))
			|| (vars.HasEnteredWorldMap && current.MiniMapActive)
			|| vars.CinematicTransitioning
			|| (vars.Renoir3FinalFightCutscene && vars.Renoir3FinalFightCutsceneMaelleStartedStabbing && !vars.Renoir3FinalFightCutsceneMaelleDoneStabbing);

	return loadingBlock && !vars.KeepTimerUnpaused;
}

reset
{
	if (settings["AutoReset"] && old.World != "Level_MainMenu" && current.World == "Level_MainMenu") return true;
}

onReset
{
	vars.NewGameStart = false;
	vars.NewGamePlusStart = false;
	vars.EncounterWon.Clear();
	vars.BattleWon = false;
	vars.Renoir3FinalFightCutscene = false;
	vars.IgnoreEndCinematicTransition = false;
	vars.GameMenuOpen = false;
	vars.KeepTimerUnpaused = false;
	vars.MenuInterruptedCinematic = false;
	vars.CinematicTransitioning = false;
}

exit
{
	timer.IsGameTimePaused = true;
}
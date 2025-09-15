// Load Removal made by Nikoheart
// Edits made by ISO2768-mK & PlaccidPenguin
// Any queries/edits/changes needed, please contact at @hellonikoheart on X (Twitter) or @nikoheart.com on Bluesky
// or reach out within the #lrt-autosplitter-dev channel in the speedrunning Discord

state("Sandfall-Win64-Shipping") {}
state("Sandfall-WinGDK-Shipping") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	vars.Helper.Settings.CreateFromXml("Components/ClairObscurExpedition33.Splits.xml");
	vars.Helper.GameName = "Clair Obscur: Expedition 33";
	vars.Helper.AlertLoadless();
	vars.TimerModel = new TimerModel { CurrentState = timer };
	vars.EncounterWon = new List<string>();
	vars.paksFolder = ""; // read in onStart, so should be initialized
}

init
{
	vars.WaitForPlayer = true;
	vars.WaitForBuild = true;
	print("Awaiting player...");

	vars.ModsDetected = false;
	vars.gameModule = modules.First();
	vars.sandfallLocation = Path.GetFullPath(Path.Combine(vars.gameModule.FileName, @"../../../"));
	vars.paksFolder = Path.GetFullPath(Path.Combine(vars.sandfallLocation, @"Content\Paks\"));
	if (Directory.Exists(vars.paksFolder + @"~mods"))
	{
		var modsMessage = MessageBox.Show (
			"Clair Obscur: Expedition 33 speedruns requires no mods to be in use.\n"+
				"If you are seeing this message, it means that the '~mods' folder has been detected.\n"+
				"Make sure to remove this folder to stop seeing this message and ensure the validity of a legitimate speedrun.\n",
				"Mods Folder Detected",
			MessageBoxButtons.OK,MessageBoxIcon.Question
			);
		
			if (modsMessage == DialogResult.OK)
			{
				Application.Exit();
			}
	}
	if (Directory.Exists(vars.paksFolder + @"~mods"))
	{
		throw new Exception("Mods detected. Stopping ASL.");
	}

	vars.TryInit = (Func<bool>)(() =>
	{
		IntPtr gWorld = vars.Helper.ScanRel(3, "48 8B 1D ???????? 48 85 DB 74 ?? 41 B0 01");
		IntPtr gEngine = vars.Helper.ScanRel(3, "48 8B 0D ???????? 66 0F 5A C9 E8");
		IntPtr fNames = vars.Helper.ScanRel(7, "8B D9 74 ?? 48 8D 15 ???????? EB");

		if (gWorld == IntPtr.Zero || gEngine == IntPtr.Zero || fNames == IntPtr.Zero)
		{
			return false;
		}

		ulong localPlayer = vars.Helper.Read<ulong>(gEngine, 0x10A8, 0x38);
		if (localPlayer == 0) { // Likely found the wrong game engine due to early startup, so wait a bit
			return false;
		}

		// We've found the correct roots, so init is complete
		print("Game engine with player found");
		vars.WaitForPlayer = false;

		const LiveSplit.ComponentUtil.MemoryWatcher.ReadFailAction dontUpdate = LiveSplit.ComponentUtil.MemoryWatcher.ReadFailAction.DontUpdate;
		const LiveSplit.ComponentUtil.MemoryWatcher.ReadFailAction setZeroOrNull = LiveSplit.ComponentUtil.MemoryWatcher.ReadFailAction.SetZeroOrNull;

		const string always = "";
		const string mainMenu = "BP_jRPG_Controller_MainMenu_C";
		const string inGame = "BP_jRPG_Controller_World_C";
		const string inGameWorldMap = "BP_PlayerController_WorldMap_C";

		vars.AllHelpers = new List<string>();

		vars.HelpersForPlayerType = new Dictionary<string, List<string>>();
		vars.HelpersForPlayerType[mainMenu] = new List<string>();
		vars.HelpersForPlayerType[inGame] = new List<string>();
		vars.HelpersForPlayerType[inGameWorldMap] = new List<string>();
		vars.HelpersForPlayerType[always] = new List<string>();

		vars.UpdateActionsForPlayerType = new Dictionary<string, List<Action>>();
		vars.UpdateActionsForPlayerType[mainMenu] = new List<Action>();
		vars.UpdateActionsForPlayerType[inGame] = new List<Action>();
		vars.UpdateActionsForPlayerType[inGameWorldMap] = new List<Action>();
		vars.UpdateActionsForPlayerType[always] = new List<Action>();

		// Player types that have the same memory layouts as others, which may depend on build version
		vars.PlayerTypeAliases = new Dictionary<string, string>();

		vars.playerWatcher = vars.Helper.Make<ulong>(gEngine, 0x10A8, 0x38);
		vars.playerWatcher.FailAction = setZeroOrNull;
		vars.playerTypeWatcher = vars.Helper.Make<ulong>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x18);
		vars.playerTypeWatcher.FailAction = setZeroOrNull;

		// Registers a memory watcher with the Basic as well as the player type dictionary. If the player type is empty, then the watcher is always enabled.
		vars.RegisterHelper = (Action<string, string, LiveSplit.ComponentUtil.MemoryWatcher.ReadFailAction, LiveSplit.ComponentUtil.MemoryWatcher>)((name, playerType, failAction, ptr) =>
		{
			ptr.FailAction = failAction;
			if (string.IsNullOrEmpty(playerType))
			{
				ptr.Enabled = true;
			}
			else
			{
				ptr.Enabled = false;
				vars.HelpersForPlayerType[playerType].Add(name);
			}
			vars.Helper[name] = ptr;
			vars.AllHelpers.Add(name);
		});

		vars.SetActiveHelpers = (Action<string>)((playerType) =>
		{
			foreach (KeyValuePair<string, List<string>> entry in vars.HelpersForPlayerType)
			{
				entry.Value.ForEach(helperName => {
					vars.Helper[helperName].Enabled = (playerType == entry.Key);

					// Also zero the values of setZeroOrNull watchers when they watch a different player type
					if (playerType != entry.Key && vars.Helper[helperName].FailAction == setZeroOrNull)
					{
						vars.Helper[helperName].Reset();
					}
				});
			}
		});

		// Memory watchers that should be installed when first initializing
		vars.FillStartupHelpers = (Action)(() =>
		{
			// GWorld.FName
			vars.RegisterHelper("GWorldName", always, dontUpdate, vars.Helper.Make<ulong>(gWorld, 0x18));
			vars.RegisterHelper("BuildVersion", mainMenu, dontUpdate, vars.Helper.MakeString(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x878, 0x440, 0x1A0, 0x28, 0x0));
		});

		// Memory watchers that should be installed once the build version is determined
		vars.FillBuildSpecificHelpers = (Action<string>)((buildVersion) =>
		{
			// GEngine.GameInstance.LocalPlayers[0].IsPauseMenuVisible
			vars.RegisterHelper("IsPauseMenuVisible", inGame, dontUpdate, vars.Helper.Make<bool>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0xBC8));  
			// GEngine.GameInstance.LocalPlayers[0].IsChangingArea
			vars.RegisterHelper("IsChangingArea", inGame, dontUpdate, vars.Helper.Make<bool>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0xDE8));
			// GEngine.GameInstance.LocalPlayers[0].BP_CinematicSystem.LevelSequenceActor.Status
			vars.RegisterHelper("CS_CinematicStatus", inGame, setZeroOrNull, vars.Helper.Make<uint>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, 0xA8, 0x288));
			// GEngine.GameInstance.LocalPlayers[0].BP_CinematicSystem.LevelSequenceActor.Sequence
			vars.RegisterHelper("CS_CinematicName", inGame, setZeroOrNull, vars.Helper.Make<ulong>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, 0xA8, 0x290, 0x18));
			// GEngine.GameInstance.LocalPlayers[0].BP_CinematicSystem.LevelSequenceActor.SerialNumber
			vars.RegisterHelper("CS_CinematicSerialNumber", inGame, setZeroOrNull, vars.Helper.Make<uint>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, 0xA8, 0x2A8));
			// GEngine.GameInstance.LocalPlayers[0].BP_CinematicSystem.IsPlayingCinematic
			vars.RegisterHelper("CS_IsPlayingCinematic", inGame, setZeroOrNull, vars.Helper.Make<bool>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, 0x238));
			// GEngine.GameInstance.LocalPlayers[0].BP_CinematicSystem.CinematicPaused
			vars.RegisterHelper("CS_CinematicPaused", inGame, dontUpdate, vars.Helper.Make<bool>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, 0x239));
			// GEngine.GameInstance.LocalPlayers[0].BP_CinematicSystem.EventBeforePostCinematicTransitionStarted // First field is sufficient for null check
			vars.RegisterHelper("CS_EventBeforePostCinematicTransitionStarted", inGame, dontUpdate, vars.Helper.Make<ulong>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, 0x298));
			// GEngine.GameInstance.LocalPlayers[0].AC_jRPG_BattleManager.EncounterName
			vars.RegisterHelper("BattleManagerEncounterName", inGame, dontUpdate, vars.Helper.Make<ulong>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x920, 0x190));
			// GEngine.GameInstance.LocalPlayers[0].AC_jRPG_BattleManager.BattleEndState
			vars.RegisterHelper("BattleEndState", inGame, dontUpdate, vars.Helper.Make<byte>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x920, 0x910));
			// GEngine.GameInstance.LocalPlayers[0].ExplorationHUDWidget.MiniMapWidget.bIsActive
			switch(buildVersion)
			{
				case "57661":
					vars.RegisterHelper("MiniMapActive", inGame, dontUpdate, vars.Helper.Make<bool>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x980, 0x3D0, 0x368));
					break;
				default:
					vars.RegisterHelper("MiniMapActive", inGame, dontUpdate, vars.Helper.Make<bool>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x980, 0x3C8, 0x368));
					break;
			}
			// GEngine.GameInstance.LocalPlayers[0].BattleFlowState
			vars.RegisterHelper("BattleFlowState", inGame, dontUpdate, vars.Helper.Make<byte>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x9B0));
			// GEngine.GameInstance.LocalPlayers[0].IsSavePointMenuVisible
			vars.RegisterHelper("IsSavePointMenuVisible", inGame, dontUpdate, vars.Helper.Make<bool>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0xBE0));
			// GEngine.GameInstance.IsChangingMap
			vars.RegisterHelper("IsChangingMap", inGame, dontUpdate, vars.Helper.Make<bool>(gEngine, 0x10A8, 0x1D0));
			// GEngine.GameInstance.LocalPlayers[0].TimePlayed
			vars.RegisterHelper("TimePlayed", inGame, dontUpdate, vars.Helper.Make<double>(gEngine, 0x10A8, 0x1F0));
			// GEngine.GameInstance.Loading_Screen_Widget.HasAppeared
			vars.RegisterHelper("LSW_HasAppeared", inGame, dontUpdate, vars.Helper.Make<bool>(gEngine, 0x10A8, 0xB08, 0x300));
			// GEngine.GameInstance.FinishedGameCount
			vars.RegisterHelper("FinishedGameCount", inGame, dontUpdate, vars.Helper.Make<int>(gEngine, 0x10A8, 0xE4C));
			// GEngine.GameInstance.PlayerController[0].PlayerCameraManager.CameraCachePrivate.Timestamp
			vars.RegisterHelper("PCMInGame", inGame, dontUpdate, vars.Helper.Make<float>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x348, 0x1390));

			vars.UpdateActionsForPlayerType[inGame].Add((Action)(() =>
			{
				IntPtr dialoguePtr;
				if (vars.Helper.TryDeref(out dialoguePtr, gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8F8, 0xA8, 0x310)) current.DialogueGuid = vars.ReadGuid(dialoguePtr);
				else current.DialogueGuid = Guid.Empty;

				IntPtr battleDebugLastFlowStatePtr;
				if (vars.Helper.TryDeref(out battleDebugLastFlowStatePtr, gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x920, 0x9D8)) current.BattleDebugLastFlowState = vars.ReadFString(battleDebugLastFlowStatePtr);
				else current.BattleDebugLastFlowState = "";
			}));

			vars.PlayerTypeAliases.Add(inGameWorldMap, inGame);
		});

		vars.FNameToString = (Func<ulong, bool, string>)((fName, includeNumber) =>
		{
			var nameIdx = (fName & 0x000000000000FFFF) >> 0x00;
			var chunkIdx = (fName & 0x00000000FFFF0000) >> 0x10;
			var number = (fName & 0xFFFFFFFF00000000) >> 0x20;

			IntPtr chunk = vars.Helper.Read<IntPtr>(fNames + 0x10 + (int)chunkIdx * 0x8);
			IntPtr entry = chunk + (int)nameIdx * sizeof(short);

			int length = vars.Helper.Read<short>(entry) >> 6;
			string name = vars.Helper.ReadString(length, ReadStringType.UTF8, entry + sizeof(short));

			return includeNumber && number != 0 ? name + "_" + number : name;
		});

		vars.ReadGuid = (Func<IntPtr, Guid>)(ptr =>
		{
			byte[] buffer = new byte[16];
			for (var i = 0; i < 16; i++)
			{
				buffer[i] = vars.Helper.Read<byte>(ptr + i);
			}

			return new Guid(buffer);
		});

		vars.ReadFString = (Func<IntPtr, string>)(ptr =>
		{
			byte[] buffer = new byte[12];
			if (!game.ReadBytes(ptr, 12, out buffer)) return "";
			IntPtr strAddr = new IntPtr(BitConverter.ToInt64(buffer, 0));
			int length = BitConverter.ToInt32(buffer, 8);
			if (strAddr == IntPtr.Zero || length < 1) return "";
			return vars.Helper.ReadString(2*length, ReadStringType.UTF16, strAddr);
		});

		vars.WaitForBuild = true;
		print("Awaiting build version...");

		vars.FillStartupHelpers();

		vars.ActivePlayerTypeFName = 0UL;
		vars.ActivePlayerType = "";
		vars.SetActiveHelpers("");

		current.World = "";
		current.EncounterName = "";
		current.BattleDebugLastFlowState = "";
		current.CurrentCinematic = "";
		current.BattleEndState = 0;
		current.FinishedGameCount = 0;
		current.IsSavePointMenuVisible = false;
		current.WorldMapMiniMap = false;
		current.TimePlayed = 0;
		current.DialogueGuid = Guid.Empty;
		vars.BattleWon = false;
		vars.HasEnteredWorldMap = false;

		vars.EvequeEncounters = new HashSet<string>() { "SM_Eveque_ShieldTutorial*1", "SM_Eveque*1" };
		vars.CuratorEncounters = new HashSet<string>() { "GO_Curator_JumpTutorial*1", "GO_Curator_JumpTutorial_NoTuto*1" };

		return true;
	});
}

update
{
	if (vars.WaitForPlayer)
	{
		if (!vars.TryInit()) return false;
		vars.WaitForPlayer = false;
		vars.WaitForBuild = true;
	}

	vars.playerWatcher.Update(game);
	if (vars.playerWatcher.Current == 0) // Quitting
	{
		timer.IsGameTimePaused = true;
		return false;
	}

	vars.playerTypeWatcher.Update(game);
	ulong playerTypeFName = vars.playerTypeWatcher.Current;
	if (playerTypeFName != vars.ActivePlayerTypeFName) // Optimization
	{
		vars.ActivePlayerTypeFName = playerTypeFName;
		vars.ActivePlayerType = vars.FNameToString(vars.ActivePlayerTypeFName, false);
		while (vars.PlayerTypeAliases.ContainsKey(vars.ActivePlayerType)) vars.ActivePlayerType = vars.PlayerTypeAliases[vars.ActivePlayerType];
		vars.SetActiveHelpers(vars.ActivePlayerType);
	}

	vars.Helper.Update();
	vars.Helper.MapPointers();

	if (vars.WaitForBuild)
	{
		string buildVersion = current.BuildVersion;
		if (!string.IsNullOrEmpty(buildVersion) && buildVersion.All(char.IsDigit) && buildVersion != "999999")
		{
			print("Detected build: " + buildVersion);
			vars.FillBuildSpecificHelpers(buildVersion);
			vars.WaitForBuild = false;
			print("Installed build-specific memory watchers");
		}
		return false; // If we just captured the build version, then we'll update all the newly registered helpers on the next tick
	}

	// We have a build version and helpers for the player type have updated, so we can now safely perform most update calculations.

	if (vars.ModsDetected)
	{
		vars.TimerModel.Reset();
		return false;
	}

	List<Action> actions;
	if (vars.UpdateActionsForPlayerType.TryGetValue(vars.ActivePlayerType, out actions))
	{
		foreach (Action action in actions)
		{
			if (action != null) action.Invoke();
		}
	}

	var world = vars.FNameToString(current.GWorldName, true);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;

	if (!vars.HasEnteredWorldMap && current.World == "Level_WorldMap_Main_V2") vars.HasEnteredWorldMap = true;
	if (old.BattleEndState == 0 && current.BattleEndState == 1) vars.BattleWon = true;

	var encounter = vars.FNameToString(current.BattleManagerEncounterName, true);
	if (!string.IsNullOrEmpty(encounter) && current.World != "Level_MainMenu") current.EncounterName = encounter;

	if (current.CS_CinematicName == 0) current.CurrentCinematic = "";
	else current.CurrentCinematic = vars.FNameToString(current.CS_CinematicName, true);
}

start
{
	if (vars.WaitForBuild) return false;

	if (!settings["NewGamePlus"])
	{
		if (((current.World == "Level_MainMenu" || current.World == "Level_Lumiere_Main_V2") && old.TimePlayed == 0 && current.TimePlayed > 0 && current.TimePlayed < 10)) return true;
	}
	else if (settings["NewGamePlus"])
	{
		if (old.CurrentCinematic != current.CurrentCinematic && current.CurrentCinematic.Contains("MCS_MyFlower")) return true;
	}
}

onStart
{
	if (Directory.Exists(vars.paksFolder + @"~mods"))
	{
		var modsMessage = MessageBox.Show (
			"Clair Obscur: Expedition 33 speedruns requires no mods to be in use.\n"+
				"If you are seeing this message, it means that the '~mods' folder has been detected.\n"+
				"Make sure to remove the '~mods' folder to stop seeing this message and ensure the validity of a legitimate speedrun.\n",
				"Mods Folder Detected",
			MessageBoxButtons.OK,MessageBoxIcon.Question
			);
		
			if (modsMessage == DialogResult.OK)
			{
				Application.Exit();
			}
	}
	if (Directory.Exists(vars.paksFolder + @"~mods"))
	{
		vars.ModsDetected = true;
		throw new Exception("Mods detected. Stopping ASL.");
	}
	timer.IsGameTimePaused = true;
	vars.BattleWon = false;
	vars.HasEnteredWorldMap = false;
	vars.EncounterWon.Clear();
}


isLoading
{
	if (vars.WaitForBuild) return true; // stays paused during boot up after game crash

	return
		current.World == "Map_Game_Bootstrap" || current.World == "Level_MainMenu" || // Startup
		current.IsChangingMap || current.IsChangingArea || current.LSW_HasAppeared || // Visible loading screens
		(current.World != "Level_MainMenu" && current.PCMInGame < 0.5) ||

		// Hidden loading screen during post-processed freeze-frame before a battle:
		(current.BattleFlowState == 2 && (
			current.BattleDebugLastFlowState == "InitBattle"
			|| current.BattleDebugLastFlowState == "LoadDependencies"
			|| current.BattleDebugLastFlowState == "Dependencies loaded"
		)) ||

		// Cinematic stuff:
		(current.CS_IsPlayingCinematic && (
			current.CS_CinematicPaused || // Cinematic paused by player, ready to skip
			(
				// Certain cutscene segments hide expensive asset loads. Cannot write a general rule, so we list them explicitly as they are found:
				current.CS_CinematicStatus == 0 // Current cinematic sequence is stopped (distinct from paused)
				&& (
					(current.CurrentCinematic == "MCS_GobluOutro" && current.CS_CinematicSerialNumber == 3 && current.CS_EventBeforePostCinematicTransitionStarted != 0) ||
					(current.CurrentCinematic == "MCS_PostDuallist" && current.CS_CinematicSerialNumber == 3 && current.CS_EventBeforePostCinematicTransitionStarted != 0) ||
					(current.CurrentCinematic == "MCS_DiscoveringTheTruth_P2" && current.CS_CinematicSerialNumber == 3 && current.CS_EventBeforePostCinematicTransitionStarted != 0) ||
					(current.CurrentCinematic == "CS_GPE_MonolithInterior_Locomotive_MonocoToLumiere" && current.CS_CinematicSerialNumber == 3 && current.CS_EventBeforePostCinematicTransitionStarted != 0) ||
					(current.CurrentCinematic == "CS_CleasFlyingHouse_DuallisteDeath" && current.CS_CinematicSerialNumber == 3 && current.CS_EventBeforePostCinematicTransitionStarted != 0) ||
					(current.CurrentCinematic == "CS_CleasFlyingHouse_EvequeDeath" && current.CS_CinematicSerialNumber == 3 && current.CS_EventBeforePostCinematicTransitionStarted != 0) ||
					(current.CurrentCinematic == "CS_CleasFlyingHouse_GobluDeath" && current.CS_CinematicSerialNumber == 3 && current.CS_EventBeforePostCinematicTransitionStarted != 0) ||
					(current.CurrentCinematic == "CS_CleasFlyingHouse_LampmasterDeath" && current.CS_CinematicSerialNumber == 3 && current.CS_EventBeforePostCinematicTransitionStarted != 0) ||
					(current.CurrentCinematic == "MCS_MirrorCleaOutro" && current.CS_CinematicSerialNumber == 3 && current.CS_EventBeforePostCinematicTransitionStarted != 0)
				)
			)
		)) ||

		(vars.HasEnteredWorldMap && current.MiniMapActive); // World map open
}

split
{
	if (vars.WaitForBuild) return false;

	string worldEncounter = current.World + "-" + old.EncounterName;

	// Eveque Split
	if (settings["Eveque"] && vars.BattleWon && vars.EvequeEncounters.Contains(old.EncounterName) && current.EncounterName == "None" && !vars.EncounterWon.Contains(worldEncounter))
	{
		vars.EncounterWon.Add(worldEncounter);
		vars.BattleWon = false;
		if (settings["Eveque"]) return true;
	}

	// Curator Split
	if (settings["Curator"] && vars.BattleWon && vars.CuratorEncounters.Contains(old.EncounterName) && current.EncounterName == "None" && !vars.EncounterWon.Contains(worldEncounter))
	{
		vars.EncounterWon.Add(worldEncounter);
		vars.BattleWon = false;
		if (settings["Curator"]) return true;
	}

	// Fake Paintress Split
	if (settings["FakePaintress"] && current.CurrentCinematic == "MCS_GoingInsideTheMonolith" && !vars.EncounterWon.Contains("FakePaintress"))
	{
		vars.EncounterWon.Add("FakePaintress");
		if (settings["FakePaintress"]) return true;
	}

	// Paintress First Phase Split
	if (current.EncounterName == "L_Boss_Paintress_P1" && current.CurrentCinematic == "MCS_PaintressTransitionToPhase2" 
		&& !vars.EncounterWon.Contains(worldEncounter + "_Phase1"))
		{
			vars.EncounterWon.Add(worldEncounter + "_Phase1");
			if (settings[worldEncounter + "_Phase1"]) return true;
		}

	// Final Renoir First Phase Split
	if (current.EncounterName == "L_Boss_Curator_P1" && current.CurrentCinematic == "MCS_RenoirFightPhase2to3_PartLumiere" 
		&& !vars.EncounterWon.Contains(worldEncounter + "_Phase1"))
		{
			vars.EncounterWon.Add(worldEncounter + "_Phase1");
			if (settings[worldEncounter + "_Phase1"]) return true;
		}

	// Encounter splits
	if (current.World != "Level_MainMenu" && vars.BattleWon &&
		old.EncounterName != "None" && current.EncounterName == "None" && !vars.EncounterWon.Contains(worldEncounter))
	{
		vars.EncounterWon.Add(worldEncounter);
		vars.BattleWon = false;
		if (settings.ContainsKey(worldEncounter) && settings[worldEncounter]) return true;
	}

	// Act Splits
	if (old.CurrentCinematic != current.CurrentCinematic && !string.IsNullOrEmpty(current.CurrentCinematic))
	{
		if (settings.ContainsKey(current.CurrentCinematic)) return settings[current.CurrentCinematic];
	}
}

reset
{
	if (vars.WaitForBuild) return false;
	if (settings["AutoReset"] && old.World != "Level_MainMenu" && current.World == "Level_MainMenu") return true;
}

exit
{
	timer.IsGameTimePaused = true;

	vars.WaitForPlayer = true;
	((List<string>)vars.AllHelpers).ForEach(helperName => {
		vars.Helper.RemoveWatcher(helperName);
	});
}
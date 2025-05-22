// Load Removal made by Nikoheart
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
}

init
{
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
		const string Msg = "Mods detected. Stopping ASL.";
		throw new Exception(Msg);
	}

	IntPtr gWorld = vars.Helper.ScanRel(3, "48 8B 1D ???????? 48 85 DB 74 ?? 41 B0 01");
	IntPtr gEngine = vars.Helper.ScanRel(3, "48 8B 0D ???????? 66 0F 5A C9 E8");
	IntPtr fNames = vars.Helper.ScanRel(7, "8B D9 74 ?? 48 8D 15 ???????? EB");

	vars.gEngine = gEngine;

	if (gWorld == IntPtr.Zero || gEngine == IntPtr.Zero || fNames == IntPtr.Zero)
	{
		const string Msg = "Not all required addresses could be found by scanning.";
		throw new Exception(Msg);
	}

	// GWorld.FName
	vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x18);
	// GEngine.GameInstance.LocalPlayers[0].IsPauseMenuVisible
	vars.Helper["IsPauseMenuVisible"] = vars.Helper.Make<bool>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0xBC8);
	// GEngine.GameInstance.LocalPlayers[0].IsChangingArea
	vars.Helper["IsChangingArea"] = vars.Helper.Make<bool>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0xDE8);
	// GEngine.GameInstance.LocalPlayers[0].BP_CinematicSystem.LevelSequenceActor.Sequence
	vars.Helper["CS_CinematicName"] = vars.Helper.Make<ulong>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, 0xA8, 0x290, 0x18);
	// GEngine.GameInstance.LocalPlayers[0].BP_CinematicSystem.CinematicPaused
	vars.Helper["CS_CinematicPaused"] = vars.Helper.Make<bool>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, 0x239);
	// GEngine.GameInstance.LocalPlayers[0].AC_jRPG_BattleManager.EncounterName
	vars.Helper["BattleManagerEncounterName"] = vars.Helper.Make<ulong>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x920, 0x190);
	// GEngine.GameInstance.LocalPlayers[0].AC_jRPG_BattleManager.BattleEndState
	vars.Helper["BattleEndState"] = vars.Helper.Make<byte>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x920, 0x910);
	// GEngine.GameInstance.LocalPlayers[0].ExplorationHUDWidget.MiniMapWidget.bIsActive
	vars.Helper["MiniMapActive"] = vars.Helper.Make<bool>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x980, 0x3C8, 0x368);
	// GEngine.GameInstance.LocalPlayers[0].BattleFlowState
	vars.Helper["BattleFlowState"] = vars.Helper.Make<byte>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x9B0);
	// GEngine.GameInstance.LocalPlayers[0].IsSavePointMenuVisible
	vars.Helper["IsSavePointMenuVisible"] = vars.Helper.Make<bool>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0xBE0);
	// GEngine.GameInstance.IsChangingMap
	vars.Helper["IsChangingMap"] = vars.Helper.Make<bool>(gEngine, 0x10A8, 0x1D0);
	// GEngine.GameInstance.LocalPlayers[0].TimePlayed
	vars.Helper["TimePlayed"] = vars.Helper.Make<double>(gEngine, 0x10A8, 0x1F0);
	// GEngine.GameInstance.Loading_Screen_Widget.HasAppeared
	vars.Helper["LSW_HasAppeared"] = vars.Helper.Make<bool>(gEngine, 0x10A8, 0xB08, 0x300);
	// GEngine.GameInstance.FinishedGameCount
	vars.Helper["FinishedGameCount"] = vars.Helper.Make<int>(gEngine, 0x10A8, 0xE4C);

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

	vars.ReadGuid = (Func<IntPtr, Guid>)(ptr =>
	{
		byte[] buffer = new byte[16];
		for (var i = 0; i < 16; i++)
		{
			// buffer[i] = vars.Helper.Read<byte>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8F8, 0xA8, 0x310 + i);
			buffer[i] = vars.Helper.Read<byte>(ptr + i);
		}

		return new Guid(buffer);
	});

	current.World = "";
	current.EncounterName = "";
	current.CurrentCinematic = "";
	current.BattleEndState = 0;
	current.FinishedGameCount = 0;
	current.IsSavePointMenuVisible = false;
	current.WorldMapMiniMap = false;
	current.TimePlayed = 0;
	current.DialogueGuid = Guid.Empty;
	vars.BattleWon = false;
	vars.NewGamePlus = false;
	vars.HasEnteredWorldMap = false;

	vars.EvequeEncounters = new HashSet<string>() { "SM_Eveque_ShieldTutorial*1", "SM_Eveque*1" };
	vars.CuratorEncounters = new HashSet<string>() { "GO_Curator_JumpTutorial*1", "GO_Curator_JumpTutorial_NoTuto*1" };
}

start
{
	if (!settings["NewGamePlus"])
	{
		if ((current.World == "Level_MainMenu" && old.TimePlayed == 0 && current.TimePlayed != 0) 
		|| current.World == "Level_MainMenu" && current.World != "Level_MainMenu" 
		&& old.TimePlayed == 0 && current.TimePlayed != 0) return true;
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
				"Make sure to remove the~mods folder to stop seeing this message and ensure the validity of a legitimate speedrun.\n",
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
		const string Msg = "Mods detected. Stopping ASL.";
		throw new Exception(Msg);
	}
	timer.IsGameTimePaused = true;
	vars.BattleWon = false;
	vars.NewGamePlus = false;
	vars.HasEnteredWorldMap = false;
	vars.EncounterWon.Clear();
}

update
{
	vars.Helper.Update();
	vars.Helper.MapPointers();

	if (vars.ModsDetected) vars.TimerModel.Reset();

	// Dialogue
	IntPtr dialoguePtr;
	if (vars.Helper.TryDeref(out dialoguePtr, vars.gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8F8, 0xA8, 0x310)) current.DialogueGuid = vars.ReadGuid(dialoguePtr);
	else current.DialogueGuid = Guid.Empty;

	if (!vars.HasEnteredWorldMap && current.World == "Level_WorldMap_Main_V2") vars.HasEnteredWorldMap = true;
	if (old.BattleEndState == 0 && current.BattleEndState == 1) vars.BattleWon = true;

	var world = vars.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	if (old.World != current.World)vars.Log(current.World);

	var encounter = vars.FNameToString(current.BattleManagerEncounterName);
	if (!string.IsNullOrEmpty(encounter)) current.EncounterName = encounter;
	if (old.EncounterName != current.EncounterName) vars.Log("Encounter Name: " + old.EncounterName + " -> " + current.EncounterName);

	var cinematic = vars.FNameToString(current.CS_CinematicName);
	if (!string.IsNullOrEmpty(cinematic)) current.CurrentCinematic = cinematic;

	// if (old.DialogueGuid != current.DialogueGuid) vars.Log("Current Dialogue GUID is: " + current.DialogueGuid.ToString());
}

isLoading
{
	return current.IsChangingMap || current.IsChangingArea || current.CS_CinematicPaused ||
			current.IsPauseMenuVisible || current.BattleFlowState == 1 || 
			current.LSW_HasAppeared || (vars.HasEnteredWorldMap && current.MiniMapActive) || 
			current.World == "Map_Game_Bootstrap" || current.World == "Level_MainMenu";
}


split
{
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
		& !vars.EncounterWon.Contains(worldEncounter + "_Phase1"))
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
		if (settings[worldEncounter]) return true;
	}

	// Act Splits
	if (old.CurrentCinematic != current.CurrentCinematic)
	{
		if (settings.ContainsKey(current.CurrentCinematic)) return settings[current.CurrentCinematic];
	}
}

exit
{
	timer.IsGameTimePaused = true;
}

onReset
{
	vars.NewGamePlus = false;
}

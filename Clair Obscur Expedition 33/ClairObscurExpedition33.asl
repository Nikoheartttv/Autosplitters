// Load Removal made by Nikoheart
// Any queries/edits/changes needed, please contact at @hellonikoheart on X (Twitter) or @nikoheart.com on Bluesky
// or reach out within the #lrt-autosplitter-dev channel in the speedrunning Discord

state("Sandfall-Win64-Shipping") {}
state("Sandfall-WinGDK-Shipping") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	vars.Helper.GameName = "Clair Obscur: Expedition 33";
	vars.Helper.AlertLoadless();
	vars.TimerModel = new TimerModel { CurrentState = timer };

	dynamic[,] _settings =
	{
		{ "NewGamePlus", false, "Turn On NG+ Run", null},
		{ "ActSplits", true, "Start of Act Splits", null },
			{ "LS_Title_Act1", true, "Act 1", "ActSplits" },
			{ "LS_Title_Act2", true, "Act 2", "ActSplits" },
			{ "LS_Title_Act3", true, "Act 3", "ActSplits" },
		{ "EncounterSplits", true, "Major Encounters Splits", null },
			{ "Prologue", true, "Prologue", "EncounterSplits" },
				{ "Lumiere", true, "Lumière", "Prologue" },
					{ "LU_Act1_MaelleNoTutorialCivilian", false, "Maelle Fight", "Lumiere" },
			{ "Act1", true, "Act 1", "EncounterSplits" },
				{ "SpringMeadows", true, "Spring Meadows", "Act1" },
					{ "SM_FirstLancelierNoTuto*1", false, "First Lancelier", "SpringMeadows" },
					{ "SM_FirstPortier_NoTuto*1", false, "First Portier", "SpringMeadows" },
					{ "SM_Volester_TutoFlying*1", false, "First Volesters", "SpringMeadows" },
					{ "Eveque", true, "Évêque", "SpringMeadows" },
				{ "FlyingWaters", true, "Flying Waters", "Act1" },
					{ "Curator", false, "Curator", "FlyingWaters" },
					{ "GO_Goblu", true, "Goblu", "FlyingWaters" },
				{ "AncientSanctuary", true, "Ancient Sanctuary", "Act1" },
					{ "AS_PotatoBagTank*1_IntroFight", false, "Robust Sakapatate", "AncientSanctuary" },
					{ "AS_PotatoBag_Boss", true, "Ultimate Sakapatate", "AncientSanctuary" },
				{ "GestralVillage", true, "Gestral Village", "Act1" },
					{ "QUEST_BertrandBigHands*1", false, "Bertrand Big Hands", "GestralVillage" },
					{ "QUEST_DominiqueGiantFeet*1", false, "Domique Giant Feet", "GestralVillage" },
					{ "QUEST_MatthieuTheColossus*1", false, "Matthieu The Colossus", "GestralVillage" },
					{ "GV_Sciel*1", true, "Sciel", "GestralVillage" },
				{ "EsquiesNest", true, "Esquie's Nest", "Act1" },
					{ "EN_Francois", true, "François", "EsquiesNest" },
				{ "StoneWaveCliffs", true, "Stone Wave Cliffs", "Act1" },
					{ "SC_LampMaster", true, "Lampmaster", "StoneWaveCliffs" },
			{ "Act2", true, "Act 2", "EncounterSplits" },
				{ "ForgottenBattleField", true, "Forgotten Battlefield", "Act2" },
					{ "FB_Chalier_GradientCounterTutorial*1", false, "Chalier", "ForgottenBattleField" },
					{ "FB_DuallisteLR", true, "Dualliste", "ForgottenBattleField" },
				{ "MonocosStation", true, "Monoco's Station", "Act2" },
					{ "MS_Monoco", true, "Monoco", "MonocosStation" },
					{ "MM_Stalact_GradientAttackTutorial*1", true, "Stalact", "MonocosStation" },
				{ "OldLumiere", true, "Old Lumière", "Act2" },
					{ "OL_VersoDisappears_Chevaliere*2", false, "Ceramic & Steel Chevalière", "OldLumiere" },
					{ "OL_MirrorRenoir_FirstFight", true, "Renoir", "OldLumiere" },
				{ "Visages", true, "Visages", "Act2" },
					{ "MF_Axon_Visages", true, "Mask Keeper", "Visages" },
				{ "Sirene", true, "Sirène", "Act2" },
					{ "SI_Glissando*1", false, "Glissando", "Sirene" },
					{ "SI_Axon_Sirene", true, "Sirène", "Sirene" },
				{ "TheMonolith", true, "The Monolith", "Act2" },
					{ "FakePaintress", false, "Fake Paintress", "TheMonolith" },
					{ "MM_MirrorRenoir", true, "Renoir", "TheMonolith" },
					{ "L_Boss_Paintress_P1_Phase1", false, "The Paintress Phase 1", "TheMonolith" },
					{ "L_Boss_Paintress_P1", true, "The Paintress Phase 2", "TheMonolith" },
			{ "Act3", true, "Act 3", "EncounterSplits" },
				{ "ReturnToLumiere", true, "Return To Lumière", "Act3" },
					{ "L_Boss_Curator_P1_Phase1", false, "Renoir Phase 1", "ReturnToLumiere" },
					{ "L_Boss_Curator_P1", true, "Renoir Phase 2", "ReturnToLumiere" },
					{ "FinalBossVerso", true, "Verso", "ReturnToLumiere" },
					{ "FinalBossMaelle", true, "Maelle", "ReturnToLumiere" },
	};
	vars.Helper.Settings.Create(_settings);
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

	current.World = "";
	current.EncounterName = "";
	current.CurrentCinematic = "";
	current.BattleEndState = 0;
	current.FinishedGameCount = 0;
	current.IsSavePointMenuVisible = false;
	current.WorldMapMiniMap = false;
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

	// Touched Flag, pressed NG+, NG+ realised and turns vars.NetGamePlus to true
	if (current.IsSavePointMenuVisible && old.FinishedGameCount < current.FinishedGameCount) vars.NewGamePlus = true;
	if (!vars.HasEnteredWorldMap && current.World == "Level_WorldMap_Main_V2") vars.HasEnteredWorldMap = true;
	
	if (old.BattleEndState == 0 && current.BattleEndState == 1) vars.BattleWon = true;

	var world = vars.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;

	var encounter = vars.FNameToString(current.BattleManagerEncounterName);
	if (!string.IsNullOrEmpty(encounter) && world != "None") current.EncounterName = encounter;

	var cinematic = vars.FNameToString(current.CS_CinematicName);
	if (!string.IsNullOrEmpty(cinematic) && world != "None") current.CurrentCinematic = cinematic;
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

	// Eveque Split
	if (settings["Eveque"] && vars.BattleWon && vars.EvequeEncounters.Contains(old.EncounterName) && current.EncounterName == "None" && !vars.EncounterWon.Contains(old.EncounterName))
	{
		vars.EncounterWon.Add(old.EncounterName);
		vars.BattleWon = false;
		if (settings["Eveque"]) return true;
	}

	// Curator Split
	if (settings["Curator"] && vars.BattleWon && vars.CuratorEncounters.Contains(old.EncounterName) && current.EncounterName == "None" && !vars.EncounterWon.Contains(old.EncounterName))
	{
		vars.EncounterWon.Add(old.EncounterName);
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
		&& !vars.EncounterWon.Contains(old.EncounterName + "_Phase1"))
		{
			vars.EncounterWon.Add(old.EncounterName + "_Phase1");
			if (settings[old.EncounterName + "_Phase1"]) return true;
		}

	// Final Renoir First Phase Split
	if (current.EncounterName == "L_Boss_Curator_P1" && current.CurrentCinematic == "MCS_RenoirFightPhase2to3_PartLumiere" 
		& !vars.EncounterWon.Contains(old.EncounterName + "_Phase1"))
		{
			vars.EncounterWon.Add(old.EncounterName + "_Phase1");
			if (settings[old.EncounterName + "_Phase1"]) return true;
		}

	// Encounter splits
	if (current.World != "Level_MainMenu" && vars.BattleWon &&
		old.EncounterName != "None" && current.EncounterName == "None" && !vars.EncounterWon.Contains(old.EncounterName))
	{
		vars.EncounterWon.Add(old.EncounterName);
		vars.BattleWon = false;
		if (settings[old.EncounterName]) return true;
	}

	// Act Splits
	if (old.CurrentCinematic != current.CurrentCinematic)
		{
			return settings[current.CurrentCinematic];
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

state("Ikai-Win64-Shipping"){}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
    vars.Helper.GameName = "Ikai";
    vars.Helper.AlertLoadless();

    dynamic[,] _settings =
	{
		{ "Splits", true, "Splits", null },
			{ "GameStart", true, "Talismans & Grab Broom", "Splits" },
            { "BlindfoldMinigame", true, "Blindfolded Minigame", "Splits" },
            { "BlindfoldReturn", true, "Blindfold Return", "Splits" },
            { "Laundry", true, "Laundry", "Splits" },
            { "PathToRiverStart", true, "Path to River", "Splits" },
            { "PathClue1", true, "Path Clue 1", "Splits" },
            { "PathClue2", true, "Path Clue 2", "Splits" },
            { "PathClue3", true, "Path Clue 3", "Splits" },
            { "PathClue4", true, "Path Clue 4", "Splits" },
            { "PathToShrineStart", true, "Path Back to Shrine", "Splits" },
            { "Fires", true, "Fires", "Splits" },
            { "Fires2", true, "Fires 2", "Splits" },
            { "CheckpointStart", true, "Back at Shrine", "Splits" },
            { "HaidenCheckPoint", true, "Haiden Checkpoint", "Splits" },
            { "HaidenClosed", true, "Haiden Closed", "Splits" },
            { "ArmShadowsCheckPoint", true, "Arm Shadows", "Splits" },
            { "LibraryCheckPoint", true, "Library", "Splits" },
            { "KijoBossCheckpoint", true, "Kijo Boss", "Splits" },
            { "PriestStart", true, "Encounter Priest", "Splits" },
            { "SnakeChase", true, "Snake Chase", "Splits" },
            { "SnakeBlockCheckPoint", true, "Snake Block", "Splits" },
            { "SnakeHide", true, "Snake Hide", "Splits" },
            { "HatchRoom", true, "Enter Hatch Room", "Splits" },
            { "HatchRoomSealCompleted", true, "Hatch Room Seal Completed", "Splits" },
            { "HatchRoomUnlocked", true, "Hatch Room Unlocked", "Splits" },
            { "CaveStart", true, "Cave Start", "Splits" },
            { "CaveRoadBlock", true, "Cave Road Block", "Splits" },
            { "WellStart", true, "Well Start", "Splits" },
            { "WellSubcave", true, "Well Subcave", "Splits" },
            { "SouthForestStart", true, "South Forest Start", "Splits" },
            { "SouthForestEnd", true, "South Forest End", "Splits" },
            { "SouthWallEntrance", true, "South Wall Entrance", "Splits" },
            { "PriestFountain", true, "Priest Fountain", "Splits" },
            { "SnakeHaiden", true, "Snake Haiden", "Splits" },
            { "JorogumoStart", true, "Jorogumo Start", "Splits" },
            { "BiwaPuzzle", true, "Biwa Puzzle", "Splits" },
            { "InkLibrary", true, "Ink Library", "Splits" },
            { "JorogumoFinal", true, "Jorogumo Final", "Splits" },
            { "IllusionStart", true, "Illusion Start", "Splits" },
            { "DarkIllusionStart", true, "Dark Illusion Start", "Splits" },
            { "DarkIllusionLetter", true, "Dark Illusion Letter", "Splits" },
            { "SisterHouseStart", true, "Sister House Start", "Splits" },
            { "EyesCorridor", true, "Eyes Corridor", "Splits" },
            { "FindKatana", true, "Find Katana", "Splits" },
            { "KatanaFound", true, "Katana Found", "Splits" },
            { "SamuraiRoom", true, "Samurai Room", "Splits" },
            { "Dojo", true, "Dojo", "Splits" },
            { "FinalStart", true, "Final Start", "Splits" },
            { "SisterMinigame", true, "Sister Minigame", "Splits" },
            { "SisterMinigameReturn", true, "Sister Minigame Return", "Splits" },
            { "CabinetPuzzle", true, "CabinetPuzzle", "Splits" },
            { "FinalCinematic", true, "Final Cinematic & End", "Splits"}
    };

	vars.Helper.Settings.Create(_settings);
    vars.CompletedSplits = new HashSet<string>();
}

init
{
    IntPtr gWorld = vars.Helper.ScanRel(3, "48 8B 1D ???????? 48 85 DB 74 ?? 41 B0 01");
    IntPtr fNames = vars.Helper.ScanRel(13, "89 5C 24 ?? 89 44 24 ?? 74 ?? 48 8D 15");

    if (gWorld == IntPtr.Zero || fNames == IntPtr.Zero)
    {
        const string Msg = "Not all required addresses could be found by scanning.";
        throw new Exception(Msg);
    }

    vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x18);
    // GWorld.AuthorityGameMode.GameManager.lastCheckPoint
    vars.Helper["CheckpointID"] = vars.Helper.Make<ulong>(gWorld, 0x118, 0x3B0, 0x50, 0x230);
    // GWorld.AuthorityGameMode.loadingScreenWidget.LoadingGameCanvas.Visibility
    vars.Helper["Loading"] = vars.Helper.Make<byte>(gWorld, 0x118, 0x3A8, 0x278, 0xC3);
    // // GWorld.AuthorityGameMode.loadingScreenWidget.Visibility
    // vars.Helper["LoadingTest"] = vars.Helper.Make<byte>(gWorld, 0x118, 0x3A8, 0xC3);
    // GWorld.AuthorityGameMode.loadingScreenWidget.Throber_235.Image[bIsDynamicallyLoaded]
    // vars.Helper["LoadingTest2"] = vars.Helper.Make<bool>(gWorld, 0x118, 0x3A8, 0x288, 0x198);
    // vars.Helper["LoadingTest2"] = vars.Helper.Make<bool>(gWorld, 0x118, 0x3A8, 0x288, 0x118, 0x80);
    // GWorld.OwningGameInstance.LocalPlayers[0].MenuInputManager.menuWidget.Visibility
    vars.Helper["Paused"] = vars.Helper.Make<byte>(gWorld, 0x180, 0x38, 0x0, 0x30, 0x5D8, 0x220, 0xC3);

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
    current.Checkpoint = "";
}

start
{
    return old.World == "MainMenu" && current.World == "MasterGameMap";
}

update
{
	vars.Helper.Update();
	vars.Helper.MapPointers();

	var world = vars.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None")
		current.World = world;
		// if (old.World != current.World) vars.Log("World: " + old.World + " -> " + current.World);
	var checkpointid = vars.FNameToString(current.CheckpointID);
	if (!string.IsNullOrEmpty(checkpointid) && checkpointid != "None")
		current.Checkpoint = checkpointid;
		// if (old.Checkpoint != current.Checkpoint) vars.Log("Checkpoint: " + old.Checkpoint + " -> " + current.Checkpoint);

    // if (old.Loading != current.Loading) vars.Log("Loading: " + current.Loading);
    if (old.LoadingTest2 != current.LoadingTest2) vars.Log("LoadingTest2: " + current.LoadingTest2);
    // if (old.LoadingTest2 != current.LoadingTest2) vars.Log("LoadingTest2: " + current.LoadingTest2);
    // if (old.Paused != current.Paused) vars.Log("Paused: " + current.Paused);
}

split
{
    if (old.Checkpoint != current.Checkpoint && settings[old.Checkpoint] && !vars.CompletedSplits.Contains(old.Checkpoint))
	{
		vars.CompletedSplits.Add(old.Level);
		return true;
	}
}

isLoading
{
    return current.Paused == 0 || current.Loading == 0;
    // return current.Loading == 0;
}
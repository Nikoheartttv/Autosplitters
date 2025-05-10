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
}

init
{
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
    // GEngine.GameInstance.IsChangingMap
    vars.Helper["IsChangingMap"] = vars.Helper.Make<bool>(gEngine, 0x10A8, 0x1D0);
    // GEngine.GameInstance.IsLoadingMapFromLoadGame
    vars.Helper["IsLoadingMapFromLoadGame"] = vars.Helper.Make<bool>(gEngine, 0x10A8, 0xCC9);
    // GEngine.GameInstance.LocalPlayers[0].IsChangingArea
    vars.Helper["IsChangingArea"] = vars.Helper.Make<bool>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0xDE8);
    // GEngine.GameInstance.LocalPlayers[0].IsPauseMenuVisible
	vars.Helper["IsPauseMenuVisible"] = vars.Helper.Make<bool>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0xDE8);
    // GEngine.GameInstance.LocalPlayers[0].BattleFlowState
	vars.Helper["BattleFlowState"] = vars.Helper.Make<byte>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x9B0);
    // GEngine.GameInstance.LocalPlayers[0].AcknowledgedPawn.IsTeleporting?
    vars.Helper["IsTeleporting"] = vars.Helper.Make<bool>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x338, 0xDC0);
    // GEngine.GameInstance.LocalPlayers[0].BP_CinematicSystem.IsInTransition
    vars.Helper["CS_IsInTransition"] = vars.Helper.Make<bool>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8A8, 0x358);
    // GEngine.GameInstance.Loading_Screen_Widget.HasAppeared
    vars.Helper["LSW_HasAppeared"] = vars.Helper.Make<bool>(gEngine, 0x10A8, 0xB08, 0x300);

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
    current.MapName = "";
}

start
{
    return old.World == "Level_MainMenu" && current.World != "Level_MainMenu";
}

onStart
{
    timer.IsGameTimePaused = true;
}

update
{
	vars.Helper.Update();
	vars.Helper.MapPointers();

	var world = vars.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	if (old.World != current.World) vars.Log("World: " + old.World + " -> " + current.World);
}

isLoading
{
    return current.IsChangingMap || current.IsLoadingMapFromLoadGame || current.IsChangingArea || 
    current.IsPauseMenuVisible || current.BattleFlowState == 1 || 
    current.LSW_HasAppeared || current.World == "Map_Game_Bootstrap" || current.World == "Level_MainMenu";
    // current.CS_IsInTransition
}

exit
{
    timer.IsGameTimePaused = true;
}

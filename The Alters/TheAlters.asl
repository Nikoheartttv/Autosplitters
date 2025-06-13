state("TheAlters-Win64-Shipping") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	vars.Helper.GameName = "The Alters";
	vars.Helper.AlertLoadless();

    vars.VisitedLevel = new List<string>();
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
    // GEngine.GameInstance.LocalPlayers[0].MyHUD.CutsceneOverlay.bIsFocusable
    vars.Helper["CutsceneActive"] = vars.Helper.Make<byte>(gEngine, 0xFC0, 0x38, 0x0, 0x30, 0x348, 0x6F0, 0x1DC);
    vars.Helper["CutsceneActive"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;

    // this cutscene does work well, but over-extends even when you have movement
    // GWorld.AuthorityGameMode.ExplorationSystem.PawnStatistics.CutsceneSubsystem.bCutsceneInProgress
    // vars.Helper["bCutsceneInProgress"] = vars.Helper.Make<bool>(gWorld, 0x150, 0x5A0, 0x390, 0x260, 0x404);
    // vars.Helper["bCutsceneInProgress"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;

    // Things to look at
    // GEngine.GameInstance.???.PointerToP9GlobalSequenceSubsystem.CurrentJob-> delve further when doing a job
    // vars.Helper["CurrentJob?"] = vars.Helper.Make<???>(gEngine, 0xFC0, 0x108, 0x118, 0x60, ???)

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
}

start
{
    return old.World == "MainMenu" && current.World == "StartLevel";
}

// onStart
// {
// 	vars.VisitedLevel.Clear();
// }

update
{
	vars.Helper.Update();
	vars.Helper.MapPointers();

	var world = vars.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	if (old.World != current.World)vars.Log("World: " + current.World);

    // vars.Log(current.GEngine.ToString("X"));
}

isLoading
{
	return current.Loading != 0 || current.CutsceneActive == 1;
}

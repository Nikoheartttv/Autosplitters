state("Luto-Win64-Shipping") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	vars.Helper.GameName = "Luto";
    vars.Helper.AlertLoadless();
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

    vars.Helper["GSync"] = vars.Helper.Make<bool>(gSyncLoadCount); // GSync
	vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x18); // GWorld.FName
    // GWorld -> PersistentLevel -> LevelScriptActor -> MainMenuWidget -> NewGame_Btn -> HoverSound -> ???
	// vars.Helper["HoverSound"] = vars.Helper.Make<bool>(gWorld, 0x30, 0xF0, 0x3A8, 0x3B0, 0x3C0, 0x7D0);
    // GWorld -> PersistentLevel -> LevelScriptActor -> MainMenuWidget -> NewGame_Btn -> HoverSound -> ???
	vars.Helper["NewGameClickSoundConfirm"] = vars.Helper.Make<bool>(gWorld, 0x30, 0xF0, 0x3A8, 0x3B0, 0x3B8, 0x7D0);
    vars.Helper["NewGameClickSoundConfirm"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
    vars.Helper["ContinueClickSoundConfirm"] = vars.Helper.Make<bool>(gWorld, 0x30, 0xF0, 0x3A8, 0x330, 0x3B8, 0x7D0);
    vars.Helper["ContinueClickSoundConfirm"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;

    // GWorld -> PersistentLevel -> LevelScriptActor -> BP_GlitchController -> LS_ToPlay -> SequencePlayer -> Sequence -> NamePrivate
	vars.Helper["GlitchLS_ToPlayFName"] = vars.Helper.Make<ulong>(gWorld, 0x30, 0xF0, 0x3B0, 0x320, 0x2E8, 0x290, 0x18);
    vars.Helper["GlitchLS_ToPlayFName"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
    
    // GWorld -> PersistentLevel -> LevelScriptActor -> BP_GlitchController -> LS_ToPlay -> SequencePlayer -> Status
	vars.Helper["GlitchLS_ToPlayStatus"] = vars.Helper.Make<bool>(gWorld, 0x30, 0xF0, 0x3B0, 0x320, 0x2E8, 0x288);
    vars.Helper["GlitchLS_ToPlayStatus"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;

    // GEngine -> GameInstance -> CurrentLevel
    vars.Helper["CurrentLevel"] = vars.Helper.Make<ulong>(gEngine, 0x11F8, 0x1C8);
    vars.Helper["NextLevel"] = vars.Helper.Make<ulong>(gEngine, 0x11F8, 0x1D0);

    vars.Helper["LastLevelPlayed"] = vars.Helper.Make<ulong>(gEngine, 0x11F8, 0x218, 0x28);
    vars.Helper["LastLevelCompleted"] = vars.Helper.Make<ulong>(gEngine, 0x11F8, 0x218, 0x30);

    // // GEngine -> PersistentLevel -> ??? -> ??? -> Level -> ??? -> LevelSequenceActor -> SequencePlayer -> Status
    // vars.Helper["CutsceneAnimationStatus"] = vars.Helper.Make<bool>(gWorld, 0x30, 0x2E0, 0x28, 0xE0, 0xA0, 0x230, 0x2E8, 0x288);
    // vars.Helper["CutsceneAnimationStatus"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
    // // GEngine -> PersistentLevel -> ??? -> ??? -> Level -> ??? -> LevelSequenceActor -> SequencePlayer -> Sequence -> NamePrivate
    // vars.Helper["CutsceneAnimationFName"] = vars.Helper.Make<ulong>(gWorld, 0x30, 0x2E0, 0x28, 0xE0, 0xA0, 0x230, 0x2E8, 0x290, 0x18);
    // vars.Helper["CutsceneAnimationFName"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;

    // GWorld -> PersistentLevel -> ??? -> ??? -> Level -> ??? -> LevelSequenceActor -> SequencePlayer -> Status
    vars.Helper["CutsceneAnimationStatus"] = vars.Helper.Make<bool>(gWorld, 0x178, 0x70, 0xF0, 0x660, 0x2E8, 0x288);
    vars.Helper["CutsceneAnimationStatus"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
    // GWorld -> Levels[AllocatorInstance] -> [14](Object(Level)) -> LevelScriptActor -> LevelSequenceActor -> SequencePlayer -> Sequence -> NamePrivate
    vars.Helper["CutsceneAnimationFName"] = vars.Helper.Make<ulong>(gWorld, 0x178, 0x70, 0xF0, 0x660, 0x2E8, 0x290, 0x18);
    vars.Helper["CutsceneAnimationFName"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;

    // GEngine -> GameInstance -> LocalPlayer[0] -> PlayerController -> AcknowledgedPawn -> CanPlayerMove
    vars.Helper["CanPlayerMove"] = vars.Helper.Make<bool>(gEngine, 0x11F8, 0x38, 0x0, 0x30, 0x350, 0x728);
    // GEngine -> GameInstance -> LocalPlayer[0] -> PlayerController -> AcknowledgedPawn -> IsInspecting
    vars.Helper["IsInspecting"] = vars.Helper.Make<bool>(gEngine, 0x11F8, 0x38, 0x0, 0x30, 0x350, 0x7D8);
    // GEngine -> GameInstance -> LocalPlayer[0] -> PlayerController -> AcknowledgedPawn -> InventoryComponent -> IsShowingUI
    vars.Helper["InventoryUI"] = vars.Helper.Make<bool>(gEngine, 0x11F8, 0x38, 0x0, 0x30, 0x350, 0x660, 0x1F0);

     // GEngine -> GameInstance -> LocalPlayer[0] -> PlayerController -> AcknowledgedPawn -> InspectingActor -> NamePrivate
    vars.Helper["InspectingActor"] = vars.Helper.Make<ulong>(gEngine, 0x11F8, 0x38, 0x0, 0x30, 0x350, 0x7F0, 0x18);
    vars.Helper["InspectingActor"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;

    // GEngine -> GameInstance -> SaveGame -> PlayerProgressFlags[0]
    // Progress Flags could be good for splits
    vars.Helper["ProgressFlag0"] = vars.Helper.Make<ulong>(gEngine, 0x11F8, 0x218, 0x150, 0x18);
    vars.Helper["ProgressFlag0"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;

    vars.Helper["PlayerProgressFlags"] = vars.Helper.Make<IntPtr>(gEngine, 0x11F8, 0x218, 0x150);
    vars.Helper["PlayerProgressFlagsArrayNum"] = vars.Helper.Make<int>(gEngine, 0x11F8, 0x218, 0x158);

    // GEngine -> GameInstance -> LocalPlayer[0] -> PlayerController -> bPlayerIsWaiting
    vars.Helper["bPlayerIsWaiting"] = vars.Helper.Make<int>(gEngine, 0x11F8, 0x38, 0x0, 0x30, 0x4B8);
    
    vars.Helper.Update();
	vars.Helper.MapPointers();

    // bPLayerIsWaiting goes to 11 during animations?

    current.World = "";
    current.Glitch = "";
    current.Cutscene = "";
    current.CurLvl = "";
    current.NextLvl = "";
    current.LastLvlPlayed = "";
    current.LastLvlCompleted = "";
    vars.StartClickSound = false;
    vars.StartGameGlitch = 0;
    vars.PlayerCanMove = false;
    current.LookingAt = "";
    current.ProgressFlag = "";
    vars.GEngine = gEngine;
    current.ProgressFlag = default(ulong);



    vars.ProgressFlagsList = new List<ulong>();
	for (var i = 0; i < current.PlayerProgressFlagsArrayNum; i++)
	{
		var progress = vars.Helper.Read<ulong>(vars.GEngine, 0x11F8, 0x218, 0x150, 0x8 * i);
		vars.ProgressFlagsList.Add(progress);
	}
}

start
{
    // if ((old.NewGameClickSoundConfirm == false && current.NewGameClickSoundConfirm == true) || (old.ContinueClickSoundConfirm == false && current.ContinueClickSoundConfirm == true))
    // {
    //     return true;
    // }
    // if (old.NewGameClickSoundConfirm == false && current.NewGameClickSoundConfirm == true) vars.StartClickSound = true;
    // if (vars.StartClickSound && vars.StartGameGlitch == 1) return true;
    return vars.FNameToString(current.ProgressFlag).Contains("IntroGlitchSequencePlayed");
}

onStart
{
    timer.IsGameTimePaused = true;
    vars.ProgressFlagsList.Clear();
}

update
{
    vars.Helper.Update();
	vars.Helper.MapPointers();

    if (old.GlitchLS_ToPlayStatus != current.GlitchLS_ToPlayStatus) vars.StartGameGlitch++;

    var world = vars.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	if (old.World != current.World)vars.Log("World: " + current.World);

    var glitch = vars.FNameToString(current.GlitchLS_ToPlayFName);
	if (!string.IsNullOrEmpty(glitch)) current.Glitch = glitch;
	if (old.Glitch != current.Glitch) vars.Log("Glitch: " + current.Glitch);
    if (old.GlitchLS_ToPlayStatus != current.GlitchLS_ToPlayStatus) vars.Log("Glitch Status: " + current.GlitchLS_ToPlayStatus);

    // if (old.HoverSound != current.HoverSound) vars.Log("HoverSound:" + current.HoverSound);
    if (old.NewGameClickSoundConfirm != current.NewGameClickSoundConfirm) vars.Log("NewGameClickSoundConfirm:" + current.NewGameClickSoundConfirm);
    if (old.ContinueClickSoundConfirm != current.ContinueClickSoundConfirm) vars.Log("ContinueClickSoundConfirm:" + current.ContinueClickSoundConfirm);

    var currentlevel = vars.FNameToString(current.CurrentLevel);
	if (!string.IsNullOrEmpty(currentlevel)) current.CurLvl = currentlevel;
	if (old.CurLvl != current.CurLvl)vars.Log("Current Level: " + current.CurLvl);

    var nextlevel = vars.FNameToString(current.NextLevel);
	if (!string.IsNullOrEmpty(nextlevel)) current.NextLvl = nextlevel;
	if (old.NextLvl != current.NextLvl)vars.Log("Next Level: " + current.NextLvl);

    var llp = vars.FNameToString(current.LastLevelPlayed);
	if (!string.IsNullOrEmpty(llp)) current.LastLvlPlayed = llp;
	if (old.LastLvlPlayed != current.LastLvlPlayed)vars.Log("LastLvlPlayed: " + current.LastLvlPlayed);

    var llc = vars.FNameToString(current.LastLevelCompleted);
	if (!string.IsNullOrEmpty(llc)) current.LastLvlCompleted = llc;
	if (old.LastLvlCompleted != current.LastLvlCompleted)vars.Log("LastLvlCompleted: " + current.LastLvlCompleted);

    var cutscene = vars.FNameToString(current.CutsceneAnimationFName);
	if (!string.IsNullOrEmpty(cutscene)) current.Cutscene = cutscene;
	if (old.Cutscene != current.Cutscene) vars.Log("Cutscene: " + current.Cutscene);
    if (old.CutsceneAnimationStatus != current.CutsceneAnimationStatus) vars.Log("CutsceneAnimationStatus: " + current.CutsceneAnimationStatus);

    if ((current.CanPlayerMove && !current.IsInspecting && !current.InventoryUI && !current.LookingAt.Contains("BP_InteractivePhone")) 
        || (!current.CanPlayerMove && current.IsInspecting && !current.InventoryUI && !current.LookingAt.Contains("BP_InteractivePhone"))
        || (!current.CanPlayerMove && !current.IsInspecting && current.InventoryUI && !current.LookingAt.Contains("BP_InteractivePhone"))
        || (!current.CanPlayerMove && !current.IsInspecting && !current.InventoryUI && current.LookingAt.Contains("BP_InteractivePhone"))) vars.PlayerCanMove = false;
    if (!current.CanPlayerMove && !current.IsInspecting && !current.InventoryUI && !current.LookingAt.Contains("BP_InteractivePhone")) vars.PlayerCanMove = true;

    var ia = vars.FNameToString(current.InspectingActor);
	if (!string.IsNullOrEmpty(ia)) current.LookingAt = ia;
	if (old.LookingAt != current.LookingAt)vars.Log("Looking At: " + current.LookingAt);

    var sf = vars.FNameToString(current.ProgressFlag0);
	if (!string.IsNullOrEmpty(sf)) current.ProgressFlag = sf;

    current.ProgressFlag = vars.Helper.Read<ulong>(vars.GEngine, 0x11F8, 0x218, 0x150, 0x8 * (current.PlayerProgressFlagsArrayNum-1));
	if (old.ProgressFlag != current.ProgressFlag)
	{
		vars.Log("ProgressFlag occured: " + vars.FNameToString(current.ProgressFlag));
	}
}

isLoading
{
    // if (current.World != "LVL_Desert" && current.IsInspecting)
    // {
    //     return false;
    // }
    // else if (vars.StartGameGlitch == 0 || current.GlitchLS_ToPlayStatus || current.CutsceneAnimationStatus || current.GSync || !current.CanPlayerMove)
    // {
    //     return true;
    // }

    // return vars.StartGameGlitch == 0 || current.GlitchLS_ToPlayStatus || current.GSync || vars.PlayerCanMove;
    return current.GSync || vars.PlayerCanMove;
}

onReset
{
    vars.StartClickSound = false;
    vars.StartGameGlitch = 0;
}


state("Luto-Win64-Shipping") { }

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
    Assembly.Load(File.ReadAllBytes("Components/uhara7")).CreateInstance("Main");

    vars.Helper.GameName = "Luto";
    vars.Helper.AlertGameTime();
}

init
{
    // uhara
    vars.CatchInstance = vars.Uhara.CreateTool("UnrealEngine", "CatchInstance");
    IntPtr FNamePool = vars.Uhara.ScanRel(7, "8B D9 74 ?? 48 8D 15 ???????? EB");

    IntPtr gWorld = vars.Helper.ScanRel(3, "48 8B 1D ???????? 48 85 DB 74 ?? 41 B0 01");
	IntPtr gEngine = vars.Helper.ScanRel(3, "48 8B 0D ???????? 66 0F 5A C9 E8");

    vars.GEngine = gEngine;
        
    IntPtr SomeObject = vars.CatchInstance.Add("LevelSequenceActor", 5);
    IntPtr TestObject = vars.CatchInstance.Add("WB_PauseMenu_C");
    IntPtr World = vars.CatchInstance.Add("World");

    vars.CatchInstance.ProcessQueue();


    // asl-help
    vars.Helper["GWorldName"] = vars.Helper.Make<ulong>(gWorld, 0x18); // GWorld.FName
    vars.Helper["CutsceneStatus1"] = vars.Helper.Make<bool>(SomeObject, 0x2E8, 0x288);
    vars.Helper["CutsceneFName1"] = vars.Helper.Make<ulong>(SomeObject, 0x2E8, 0x290, 0x18);
    vars.Helper["CutsceneStatus2"] = vars.Helper.Make<bool>(SomeObject + 0x8, 0x2E8, 0x288);
    vars.Helper["CutsceneFName2"] = vars.Helper.Make<ulong>(SomeObject + 0x8, 0x2E8, 0x290, 0x18);
    vars.Helper["CutsceneStatus3"] = vars.Helper.Make<bool>(SomeObject + 0x10, 0x2E8, 0x288);
    vars.Helper["CutsceneFName3"] = vars.Helper.Make<ulong>(SomeObject + 0x10, 0x2E8, 0x290, 0x18);
    vars.Helper["CutsceneStatus4"] = vars.Helper.Make<bool>(SomeObject + 0x18, 0x2E8, 0x288);
    vars.Helper["CutsceneFName4"] = vars.Helper.Make<ulong>(SomeObject + 0x18, 0x2E8, 0x290, 0x18);
    vars.Helper["CutsceneStatus5"] = vars.Helper.Make<bool>(SomeObject + 0x20, 0x2E8, 0x288);
    vars.Helper["CutsceneFName5"] = vars.Helper.Make<ulong>(SomeObject + 0x20, 0x2E8, 0x290, 0x18);

    vars.Helper["TestObject"] = vars.Helper.Make<ulong>(TestObject);

    vars.Helper["PlayerProgressFlags"] = vars.Helper.Make<IntPtr>(gEngine, 0x11F8, 0x218, 0x150);
    vars.Helper["PlayerProgressFlagsArrayNum"] = vars.Helper.Make<int>(gEngine, 0x11F8, 0x218, 0x158);

    vars.FNameToString = (Func<ulong, string>)(fName =>
	{
		var nameIdx = (fName & 0x000000000000FFFF) >> 0x00;
		var chunkIdx = (fName & 0x00000000FFFF0000) >> 0x10;
		var number = (fName & 0xFFFFFFFF00000000) >> 0x20;

		// IntPtr chunk = vars.Helper.Read<IntPtr>(fNames + 0x10 + (int)chunkIdx * 0x8);
		IntPtr chunk = vars.Helper.Read<IntPtr>(FNamePool + 0x10 + (int)chunkIdx * 0x8);
		IntPtr entry = chunk + (int)nameIdx * sizeof(short);

		int length = vars.Helper.Read<short>(entry) >> 6;
		string name = vars.Helper.ReadString(length, ReadStringType.UTF8, entry + sizeof(short));

		return number == 0 ? name : name + "_" + number;
	});

    current.CutsceneName1 = "";
    current.CutsceneStatus1 = "";
    current.CutsceneName2 = "";
    current.CutsceneStatus2 = "";
    current.CutsceneName3 = "";
    current.CutsceneStatus3 = "";
    current.CutsceneName4 = "";
    current.CutsceneStatus4 = "";
    current.CutsceneName5 = "";
    current.CutsceneStatus5 = "";
    current.ProgressFlag = "";
    current.ChapterNumber = "";
    current.World = "";

    vars.cutsceneNames = new List<string> { 
        "Urridos_Set", 
        "LVL_1_WakeUp", 
        "OpenDoorCinematic",
        "LS_BasementOpenHatch",
        "LS_BottomExit_InteractiveLadder",
        "LS_Basement_EnterLadder",
        "LS_LVL2_MaguaCatchingYou",
        "PlayerWakeUp",
        "LS_ExitCaveToDesert",
        "LS_BathWakeUp",
        "LVL3_MoveObject_Sequence",
        "LS_Urrido_PlayAudio_01_WhiteScreen",
        "LS_BathWakeUp",
        "LS_LVL5_JumpToHole" 
    };
}

start
{
    return old.ProgressFlag != current.ProgressFlag && vars.FNameToString(current.ProgressFlag).Contains("IntroGlitchSequencePlayed");
}

update
{
    vars.Helper.Update();
    vars.Helper.MapPointers();

    var world = vars.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	// if (old.World != current.World)vars.Log("World: " + current.World);
    
    if (old.CutsceneStatus1 != current.CutsceneStatus1) vars.Log("1: " + current.CutsceneStatus1);
    if (old.CutsceneStatus2 != current.CutsceneStatus2) vars.Log("2: " + current.CutsceneStatus2);
    if (old.CutsceneStatus3 != current.CutsceneStatus3) vars.Log("3: " + current.CutsceneStatus3);
    if (old.CutsceneStatus4 != current.CutsceneStatus4) vars.Log("4: " + current.CutsceneStatus4);
    if (old.CutsceneStatus5 != current.CutsceneStatus5) vars.Log("5: " + current.CutsceneStatus5);
    var cs1 = vars.FNameToString(current.CutsceneFName1);
	if (!string.IsNullOrEmpty(cs1)) current.CutsceneName1 = cs1;
	if (old.CutsceneName1 != current.CutsceneName1) vars.Log("CutsceneName1: " + current.CutsceneName1);
    var cs2 = vars.FNameToString(current.CutsceneFName2);
	if (!string.IsNullOrEmpty(cs2)) current.CutsceneName2 = cs2;
	if (old.CutsceneName2 != current.CutsceneName2) vars.Log("CutsceneName2: " + current.CutsceneName2);
    var cs3 = vars.FNameToString(current.CutsceneFName3);
	if (!string.IsNullOrEmpty(cs3)) current.CutsceneName3 = cs3;
	if (old.CutsceneName3 != current.CutsceneName3) vars.Log("CutsceneName3: " + current.CutsceneName3);
    var cs4 = vars.FNameToString(current.CutsceneFName4);
	if (!string.IsNullOrEmpty(cs4)) current.CutsceneName4 = cs4;
	if (old.CutsceneName4 != current.CutsceneName4) vars.Log("CutsceneName4: " + current.CutsceneName4);
    var cs5 = vars.FNameToString(current.CutsceneFName5);
	if (!string.IsNullOrEmpty(cs5)) current.CutsceneName5 = cs5;
	if (old.CutsceneName5 != current.CutsceneName5) vars.Log("CutsceneName5: " + current.CutsceneName5);
    
	if (current.TestObject != old.TestObject)
    {
        print("[UHARA] -> 0x" + current.TestObject.ToString("X"));
    }

    current.ProgressFlag = vars.Helper.Read<ulong>(vars.GEngine, 0x11F8, 0x218, 0x150, 0x8 * (current.PlayerProgressFlagsArrayNum-1));
	if (old.ProgressFlag != current.ProgressFlag)
	{
		vars.Log("ProgressFlag occured: " + vars.FNameToString(current.ProgressFlag));
	}

}

isLoading
{
    var names = new[] {
        current.CutsceneName1,
        current.CutsceneName2,
        current.CutsceneName3,
        current.CutsceneName4,
        current.CutsceneName5,
    };

    var statuses = new[] {
        current.CutsceneStatus1,
        current.CutsceneStatus2,
        current.CutsceneStatus3,
        current.CutsceneStatus4,
        current.CutsceneStatus5,
    };

    for (int i = 0; i < names.Length; i++)
    {
        if (!statuses[i]) continue;

        foreach (var match in vars.cutsceneNames)
        {
            if (names[i].StartsWith(match))
                return true;
        }
    }

    return false;
}

exit
{
	timer.IsGameTimePaused = true;
}
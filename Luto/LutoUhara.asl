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
    IntPtr FNamePool = vars.Uhara.ScanRel(7, "8B D9 74 ?? 48 8D 15 ???????? EB");
    IntPtr ConstructObject = vars.Uhara.ScanSingle("4C 8B DC 49 89 5B 20 55 56 57 41 55");
    IntPtr BeginDestroy = vars.Uhara.ScanSingle("40 53 48 83 EC 30 8B 41 08 48 8B D9 C1 E8 0F");

    IntPtr gWorld = vars.Helper.ScanRel(3, "48 8B 1D ???????? 48 85 DB 74 ?? 41 B0 01");
	IntPtr gEngine = vars.Helper.ScanRel(3, "48 8B 0D ???????? 66 0F 5A C9 E8");
    
    print(FNamePool.ToString("X"));
    print(ConstructObject.ToString("X"));
    print(BeginDestroy.ToString("X"));
    
    vars.CatchInstance = vars.Uhara.CreateTool("UnrealEngine", "CatchInstance");
    vars.CatchInstance.SetData(FNamePool, ConstructObject, BeginDestroy);
    
    IntPtr SomeObject = vars.CatchInstance.AddObject("LevelSequenceActor", 5);
    IntPtr ChapterText = vars.CatchInstance.AddObject("WB_ChapterText_C");
    
    vars.CatchInstance.ProcessQueue();
    
    // asl-help
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
    // vars.Helper["CutsceneStatus6"] = vars.Helper.Make<bool>(SomeObject + 0x28, 0x2E8, 0x288);
    // vars.Helper["CutsceneFName6"] = vars.Helper.Make<ulong>(SomeObject + 0x28, 0x2E8, 0x290, 0x18);
    // vars.Helper["CutsceneStatus7"] = vars.Helper.Make<bool>(SomeObject + 0x30, 0x2E8, 0x288);
    // vars.Helper["CutsceneFName7"] = vars.Helper.Make<ulong>(SomeObject + 0x30, 0x2E8, 0x290, 0x18);
    // vars.Helper["CutsceneStatus8"] = vars.Helper.Make<bool>(SomeObject + 0x38, 0x2E8, 0x288);
    // vars.Helper["CutsceneFName8"] = vars.Helper.Make<ulong>(SomeObject + 0x38, 0x2E8, 0x290, 0x18);
    // vars.Helper["CutsceneStatus9"] = vars.Helper.Make<bool>(SomeObject + 0x40, 0x2E8, 0x288);
    // vars.Helper["CutsceneFName9"] = vars.Helper.Make<ulong>(SomeObject + 0x40, 0x2E8, 0x290, 0x18);
    // vars.Helper["CutsceneStatus10"] = vars.Helper.Make<bool>(SomeObject + 0x48, 0x2E8, 0x288);
    // vars.Helper["CutsceneFName10"] = vars.Helper.Make<ulong>(SomeObject + 0x48, 0x2E8, 0x290, 0x18);

    vars.Helper["TextToShow"] = vars.Helper.Make<ulong>(gEngine, 0x11F8, 0x38, 0x0, 0x30, 0x880, 0x338);
    vars.Helper["TestObject"] = vars.Helper.Make<ulong>(ChapterText);

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

    current.Cutscene1Name = "";
    current.Cutscene2Name = "";
    current.Cutscene3Name = "";
    current.Cutscene4Name = "";
    current.Cutscene5Name = "";
    current.Cutscene6Name = "";
    current.Cutscene7Name = "";
    current.Cutscene8Name = "";
    current.Cutscene9Name = "";
    current.Cutscene10Name = "";
    current.ChapterNumber = "";
    current.TextCenter = "";
    current.Text = "";

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

update
{
    vars.Helper.Update();
    vars.Helper.MapPointers();
    
    if (old.CutsceneStatus1 != current.CutsceneStatus1) vars.Log("1: " + current.CutsceneStatus1);
    if (old.CutsceneStatus2 != current.CutsceneStatus2) vars.Log("2: " + current.CutsceneStatus2);
    if (old.CutsceneStatus3 != current.CutsceneStatus3) vars.Log("3: " + current.CutsceneStatus3);
    if (old.CutsceneStatus4 != current.CutsceneStatus4) vars.Log("4: " + current.CutsceneStatus4);
    if (old.CutsceneStatus5 != current.CutsceneStatus5) vars.Log("5: " + current.CutsceneStatus5);
    var cs1 = vars.FNameToString(current.CutsceneFName1);
	if (!string.IsNullOrEmpty(cs1)) current.Cutscene1Name = cs1;
	if (old.Cutscene1Name != current.Cutscene1Name) vars.Log("Cutscene1Name: " + current.Cutscene1Name);
    var cs2 = vars.FNameToString(current.CutsceneFName2);
	if (!string.IsNullOrEmpty(cs2)) current.Cutscene2Name = cs2;
	if (old.Cutscene2Name != current.Cutscene2Name) vars.Log("Cutscene2Name: " + current.Cutscene2Name);
    var cs3 = vars.FNameToString(current.CutsceneFName3);
	if (!string.IsNullOrEmpty(cs3)) current.Cutscene3Name = cs3;
	if (old.Cutscene3Name != current.Cutscene3Name) vars.Log("Cutscene3Name: " + current.Cutscene3Name);
    var cs4 = vars.FNameToString(current.CutsceneFName4);
	if (!string.IsNullOrEmpty(cs4)) current.Cutscene4Name = cs4;
	if (old.Cutscene4Name != current.Cutscene4Name) vars.Log("Cutscene4Name: " + current.Cutscene4Name);
    var cs5 = vars.FNameToString(current.CutsceneFName5);
	if (!string.IsNullOrEmpty(cs5)) current.Cutscene5Name = cs5;
	if (old.Cutscene5Name != current.Cutscene5Name) vars.Log("Cutscene5Name: " + current.Cutscene5Name);
    // var cs6 = vars.FNameToString(current.CutsceneFName6);
	// if (!string.IsNullOrEmpty(cs5)) current.Cutscene6Name = cs6;
	// if (old.Cutscene6Name != current.Cutscene6Name) vars.Log("Cutscene6Name: " + current.Cutscene6Name);
    // var cs7 = vars.FNameToString(current.CutsceneFName7);
	// if (!string.IsNullOrEmpty(cs7)) current.Cutscene7Name = cs7;
	// if (old.Cutscene7Name != current.Cutscene7Name) vars.Log("Cutscene7Name: " + current.Cutscene7Name);
    // var cs8 = vars.FNameToString(current.CutsceneFName8);
	// if (!string.IsNullOrEmpty(cs8)) current.Cutscene8Name = cs8;
	// if (old.Cutscene8Name != current.Cutscene8Name) vars.Log("Cutscene8Name: " + current.Cutscene8Name);
    // var cs9 = vars.FNameToString(current.CutsceneFName9);
	// if (!string.IsNullOrEmpty(cs9)) current.Cutscene9Name = cs9;
	// if (old.Cutscene9Name != current.Cutscene9Name) vars.Log("Cutscene9Name: " + current.Cutscene9Name);
    // var cs10 = vars.FNameToString(current.CutsceneFName10);
	// if (!string.IsNullOrEmpty(cs10)) current.Cutscene10Name = cs10;
	// if (old.Cutscene10Name != current.Cutscene10Name) vars.Log("Cutscene10Name: " + current.Cutscene10Name);
    
    // var textc = vars.FNameToString(current.CenterTextWidget);
	// if (!string.IsNullOrEmpty(textc)) current.TextCenter = textc;
	// if (old.ChapterNumber != current.ChapterNumber) vars.Log("ChapterNumber: " + current.ChapterNumber);
    // vars.Log("Text: " + current.CenterTextWidget);

    // if (old.ChapterNum != current.ChapterNum) vars.Log("Chapter Num: " + current.ChapterNum);
    // var tts = vars.FNameToString(current.TextToShow);
	// if (!string.IsNullOrEmpty(tts)) current.Text = tts;
	if (current.TestObject != old.TestObject)
    {
        print("0x" + current.TestObject.ToString("X"));
    }
    // vars.Log("Chapter Title: " + current.ChapterTitleTest);
}

isLoading
{
    // var names = new[] {
    //     current.Cutscene1Name,
    //     current.Cutscene2Name,
    //     current.Cutscene3Name,
    //     current.Cutscene4Name,
    //     current.Cutscene5Name,
    //     current.Cutscene6Name,
    //     current.Cutscene7Name,
    //     current.Cutscene8Name,
    //     current.Cutscene9Name,
    //     current.Cutscene10Name
    // };

     var names = new[] {
        current.Cutscene1Name,
        current.Cutscene2Name,
        current.Cutscene3Name,
        current.Cutscene4Name,
        current.Cutscene5Name,
    };

    // var statuses = new[] {
    //     current.CutsceneStatus1,
    //     current.CutsceneStatus2,
    //     current.CutsceneStatus3,
    //     current.CutsceneStatus4,
    //     current.CutsceneStatus5,
    //     current.CutsceneStatus6,
    //     current.CutsceneStatus7,
    //     current.CutsceneStatus8,
    //     current.CutsceneStatus9,
    //     current.CutsceneStatus10
    // };

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

// to do, igt pause for logos
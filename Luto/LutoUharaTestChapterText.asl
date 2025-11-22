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
    IntPtr ConstructObject = vars.Uhara.ScanSingle("4C 8B DC 49 89 5B 20 55 56 57 41 55"); // Only works with 5.5.4
    IntPtr BeginDestroy = vars.Uhara.ScanSingle("40 53 48 83 EC 30 8B 41 08 48 8B D9 C1 E8 0F"); // Only works with 5.5.4

    if (FNamePool == IntPtr.Zero || ConstructObject == IntPtr.Zero || BeginDestroy == IntPtr.Zero)
    {
        MessageBox.Show("One of FNamePool / ConstructObject / BeginDestroy is 0.\n"+
                        "FNamePool: " + FNamePool.ToString("X") + "\n"+
                        "ConstructObject: " + ConstructObject.ToString("X") + "\n"+
                        "BeginDestroy: " + BeginDestroy.ToString("X"));
    }

    IntPtr gWorld = vars.Helper.ScanRel(3, "48 8B 1D ???????? 48 85 DB 74 ?? 41 B0 01");
	IntPtr gEngine = vars.Helper.ScanRel(3, "48 8B 0D ???????? 66 0F 5A C9 E8");
    
    print(FNamePool.ToString("X"));
    print(ConstructObject.ToString("X"));
    print(BeginDestroy.ToString("X"));
    
    vars.CatchInstance = vars.Uhara.CreateTool("UnrealEngine", "CatchInstance");
    vars.CatchInstance.SetData(FNamePool, ConstructObject, BeginDestroy);
    
    IntPtr ChapterText = vars.CatchInstance.AddObject("WB_ChapterText_C", 2);
    IntPtr SomeObject = vars.CatchInstance.AddObject("LevelSequenceActor", 10);
    
    vars.CatchInstance.ProcessQueue();

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
    
    // asl-help
    vars.Helper["ChapterTextClass"] = vars.Helper.Make<IntPtr>(ChapterText);
    vars.Helper["ChapterTextFName"] = vars.Helper.Make<ulong>(ChapterText, 0x18);

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

    current.CurrentChapter = "";
}

update
{
    vars.Helper.Update();
    vars.Helper.MapPointers();
    
    if (current.ChapterTextClass != old.ChapterTextClass)
    {
        print("0x" + current.ChapterTextClass.ToString("X"));
    }

    var text = vars.FNameToString(current.ChapterTextFName);
	if (!string.IsNullOrEmpty(text)) current.CurrentChapter = text;
	if (old.CurrentChapter != current.CurrentChapter) vars.Log("CurrentChapter: " + current.CurrentChapter);
}
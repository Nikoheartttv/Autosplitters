state("SHf-Win64-Shipping"){}
state("SHf-WinGDK-Shipping"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Basic");
	Assembly.Load(File.ReadAllBytes("Components/uhara9")).CreateInstance("Main");
	vars.Helper.GameName = "Silent Hill f";
	vars.Helper.AlertLoadless();
	vars.Uhara.EnableDebug();

    settings.Add("AutoStart", false, "Auto-Start");
    settings.Add("AutoReset", false, "Auto-Reset upon New Game's Intro Cutscene");
}

init
{
	IntPtr gWorld = vars.Helper.ScanRel(3, "48 8B 05 ???????? 48 85 C0 75 ?? 48 83 C4 ?? 5B");
	IntPtr gEngine = vars.Helper.ScanRel(3, "48 8B 0D ???????? 48 8B BC 24 ???????? 48 8B 9C 24");
	IntPtr fNames = vars.Helper.ScanRel(3, "48 8D 0D ???????? E8 ???????? C6 05 ?????????? 0F 10 07");

	vars.CompletedSplits = new HashSet<string>();
	vars.GEngine = gEngine;

	if (gWorld == IntPtr.Zero || gEngine == IntPtr.Zero || fNames == IntPtr.Zero)
		throw new Exception("Not all required addresses could be found by scanning.");

    vars.FNameToShortString = (Func<uint, string>)(fName =>
    {
        string name = vars.Events.FNameToString(fName);
        int under = name.LastIndexOf('_');
        return name.Substring(0, under + 1);
    });

    // uhara helpers
	vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");
	IntPtr WBP_Cutscene_C = vars.Events.InstancePtr("WBP_Cutscene_C", "");
	vars.Helper["CutsceneName"] = vars.Helper.Make<uint>(WBP_Cutscene_C, 0x460);
	vars.Helper["CutsceneName"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;

    // asl-help helpers
    vars.Helper["GWorldName"] = vars.Helper.Make<uint>(gWorld, 0x18);
    vars.Helper["IsGameInitialized"] = vars.Helper.Make<bool>(gWorld, 0x158, 0x37A);
    vars.Helper["bWaitForRevive"] = vars.Helper.Make<bool>(gWorld, 0x158, 0x3B1);
	vars.Helper["LocalPlayer"] = vars.Helper.Make<uint>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x18);
	vars.Helper["bIsInEvent"] = vars.Helper.Make<bool>(gEngine, 0x10A8, 0x38, 0x0, 0x30, 0x298, 0x708);
	
	current.Cutscene = "";
	current.Progress = "";
	current.World = "";
	current.Item = "";
	current.bIsInEvent = false;
    vars.gameStartCutscene = false;
	vars.cutsceneActive = false;
	vars.cutsceneHold = false;
    current.LocalPlayer = 0;

	vars.CutscenesToWatch = new HashSet<string>() 
    { 
        "LS_SC0106",
        "LS_SC0203", 
        "LS_SC0303", 
        "LS_SC0404", 
        "LS_SC0504",
        "LS_SC0604",
        "LS_SC0704",
        "LS_SC0806",
        "LS_SC1007",
        "LS_SC1103",
        "LS_SC1202",
        "LS_SC1301",
        "LS_SC1402",
    };
}

start
{
	if (settings["AutoStart"] && current.Cutscene.Contains("LS_SC0101"))
	{
		vars.gameStartCutscene = true;
	}
	return vars.gameStartCutscene && current.World == "NoceWorld" && !current.bIsInEvent;
}

onStart
{
    vars.gameStartCutscene = false;
	vars.CompletedSplits.Clear();
	timer.IsGameTimePaused = true;
}

update
{
	vars.Helper.Update();
	vars.Helper.MapPointers();

	string cutscene = vars.Events.FNameToString(current.CutsceneName); 
	string newCutscene = (!string.IsNullOrEmpty(cutscene) && cutscene != "None") ? cutscene : "";

	if (newCutscene != current.Cutscene) current.Cutscene = newCutscene;

    string world = vars.Events.FNameToString(current.GWorldName);
    if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
    if (old.World != current.World) vars.Log("/// World Log: " + current.World);
}

isLoading
{
    bool loading = current.World == "NoceEntry"
                   || current.bWaitForRevive
                   || !current.IsGameInitialized
                   || vars.FNameToShortString(current.LocalPlayer) != "BP_Pl_Hina_PlayerController_"
                   || !string.IsNullOrEmpty(current.Cutscene);

    bool loading2 = vars.cutsceneHold;

    if (!string.IsNullOrEmpty(current.Cutscene) || vars.cutsceneActive)
    {
        vars.cutsceneActive = true;
        loading = true;

        if (string.IsNullOrEmpty(current.Cutscene) && !current.bIsInEvent)
        {
            vars.cutsceneActive = false;
        }
    }

    if (!vars.cutsceneHold && !string.IsNullOrEmpty(current.Cutscene) 
        && vars.CutscenesToWatch.Contains(current.Cutscene.Substring(0, 9)))
    {
        vars.cutsceneHold = true;
    }

    if (vars.cutsceneHold && !string.IsNullOrEmpty(current.Cutscene) 
        && !vars.CutscenesToWatch.Contains(current.Cutscene.Substring(0, 9)))
    {
        vars.cutsceneHold = false;
    }

    return loading || loading2;
}

reset
{
    if (settings["AutoReset"] && current.Cutscene.Contains("LS_SC0101") && old.Cutscene == "")
    {
        return true;
    }
}

exit
{
	timer.IsGameTimePaused = true;
}
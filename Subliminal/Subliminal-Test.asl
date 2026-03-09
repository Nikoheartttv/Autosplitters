state("Subliminal-Win64-Shipping") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main");
    vars.Uhara.AlertLoadless();
    vars.Uhara.EnableDebug();
}

init
{
    string MD5Hash = vars.Uhara.GetMD5Hash();
	if (string.IsNullOrEmpty(MD5Hash)) throw new Exception();
    print("Hash is: " + MD5Hash);

    switch (MD5Hash)
	{
		case "D56F16A3CE56BA3F433A1443F3F8B680":
            version = "Demo v1.4.0 (07.03.26)";
            break;
		case "BEEFBBF9FB814A03BFF2CC8B665E43DC":
			version = "Demo (19.11.25)";
			break;
		case "A179EFA7BDAB0C0EC95CF6DFA620C66B":
			version = "Demo (21.12.25)";
			break;
		default:
			version = "Demo (Prior to 19.11.25)";
			break;
	}

    vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
	vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");
	
	vars.Utils.ExpandScanUtilitySignatures("UObject_BeginDestroy", "40 53 48 83 EC 40 8B 41 08 48 8B D9 0F BA E0 0F 72");

	vars.Utils.GEngine = vars.Uhara.ScanRel(3, "48 89 05 ?? ?? ?? ?? E8 ?? ?? ?? ?? 80 3D ?? ?? ?? ?? ?? 72 ?? 48");
    if (vars.Utils.GEngine != IntPtr.Zero) vars.Uhara.Log("GEngine found at " + vars.Utils.GEngine.ToString("X"));
    if (vars.Utils.GWorld != IntPtr.Zero) vars.Uhara.Log("GWorld found at " + vars.Utils.GWorld.ToString("X")); 
    if (vars.Utils.FNames != IntPtr.Zero) vars.Uhara.Log("FNames found at " + vars.Utils.FNames.ToString("X"));

	// vars.Resolver.Watch<bool>("CanMove", vars.Events.InstancePtr("SubliminalCharacter_C", "SubliminalCharacter_C"), 0x891);

    switch(version)
    {
		case "Demo v1.4.0 (07.03.26)":
			vars.Resolver.Watch<bool>("CanMove", vars.Utils.GEngine, 0x12C8, 0x1E0, 0x891);
			break;
        case "Demo (19.11.25)":
            vars.Resolver.Watch<bool>("CanMove", vars.Utils.GEngine, 0x1248, 0x1D8, 0x90C);
            break;
        case "Demo (21.12.25)":
            vars.Resolver.Watch<bool>("CanMove", vars.Utils.GEngine, 0x1248, 0x1D8, 0x8B9);
            break;
        case "Demo (Prior to 19.11.25)":
            vars.Resolver.Watch<bool>("CanMove", vars.Utils.GEngine, 0x1248, 0x1D8, 0x90C);
            break;
    }
	vars.Events.FunctionFlag("EmptySpaceStart", "BP_EmptySpace_Intro_C", "BP_EmptySpace_Intro_C", "Timeline__UpdateFunc");
	vars.Events.FunctionFlag("EndCardTrigger", "BP_EndcardTrigger_SNF_C", "BP_EndcardTrigger_SNF_C", "ExecuteUbergraph_BP_EndcardTrigger_SNF");
	vars.Events.FunctionFlag("TitleScreenEnter", "BP_TitleScreen_NextFest_C", "BP_TitleScreen_C", "ExecuteUbergraph_BP_TitleScreen_NextFest");

	vars.MainMenu = false;
	current.CanMove = false;
	current.World = "";
}

start
{
	return old.CanMove != current.CanMove && current.CanMove && !vars.MainMenu && vars.Resolver.CheckFlag("EmptySpaceStart");
}

onStart
{
	timer.IsGameTimePaused = true;
}

update
{
    vars.Uhara.Update();
	if (vars.Resolver.CheckFlag("EmptySpaceStart")) vars.MainMenu = false;
	if (vars.Resolver.CheckFlag("TitleScreenEnter")) vars.MainMenu = true;

	if (old.CanMove != current.CanMove) vars.Uhara.Log("CanMove:" + current.CanMove);
	    
}

split
{
    if (vars.Resolver.CheckFlag("EndCardTrigger")) return true;
}

isLoading
{
	return vars.MainMenu;
}

onReset
{
	vars.MainMenu = false;
}
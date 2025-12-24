state("Subliminal-Win64-Shipping") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara9")).CreateInstance("Main");
    vars.Uhara.AlertLoadless();
    vars.Uhara.EnableDebug();
}

init
{
    string MD5Hash;
    using (var md5 = System.Security.Cryptography.MD5.Create())
    	using (var s = File.Open(modules.First().FileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
    		MD5Hash = md5.ComputeHash(s).Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);
    print("Hash is: " + MD5Hash);

    switch (MD5Hash)
	{
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

    if (vars.Utils.GEngine != IntPtr.Zero) vars.Uhara.Log("GEngine found at " + vars.Utils.GEngine.ToString("X"));
    if (vars.Utils.GWorld != IntPtr.Zero) vars.Uhara.Log("GWorld found at " + vars.Utils.GWorld.ToString("X")); 
    if (vars.Utils.FNames != IntPtr.Zero) vars.Uhara.Log("FNames found at " + vars.Utils.FNames.ToString("X"));

    switch(version)
    {
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
    vars.Resolver.Watch<ulong>("EmptySpaceStart", vars.Events.FunctionFlag("BP_EmptySpace_Intro_C", "BP_EmptySpace_Intro_C", "Timeline__UpdateFunc"));
    vars.Resolver.Watch<ulong>("EndCardTrigger", vars.Events.FunctionFlag("BP_EndcardTrigger_SNF_C", "BP_EndcardTrigger_SNF_C", "ExecuteUbergraph_BP_EndcardTrigger_SNF"));
	vars.Resolver.Watch<ulong>("TitleScreenEnter", vars.Events.FunctionFlag("BP_TitleScreen_NextFest_C", "BP_TitleScreen_C", "ExecuteUbergraph_BP_TitleScreen_NextFest"));

	vars.StartCanMove = true;
}

start
{
    return old.EmptySpaceStart != current.EmptySpaceStart && current.EmptySpaceStart != 0 && current.CanMove && !vars.StartCanMove;
}

update
{
    vars.Uhara.Update();

	if (current.CanMove && vars.StartCanMove) vars.StartCanMove = false;
	if (old.TitleScreenEnter != current.TitleScreenEnter && current.TitleScreenEnter != 0) vars.StartCanMove = true;
}

split
{
    if (old.EndCardTrigger != current.EndCardTrigger && current.EndCardTrigger != 0) return true;
}

isLoading
{
	return vars.StartCanMove;
}

onReset
{
	vars.StartCanMove = true;
}
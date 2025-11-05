state("Subliminal-Win64-Shipping") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara9")).CreateInstance("Main");
    vars.Uhara.AlertLoadless();
    vars.Uhara.EnableDebug();
}

init
{
    vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
	vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");
    vars.Resolver.Watch<bool>("CanMove", vars.Utils.GEngine, 0x1248, 0x1D8, 0x90C);
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
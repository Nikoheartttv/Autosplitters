state("Subliminal-Win64-Shipping") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara9")).CreateInstance("Main");
    vars.Uhara.AlertLoadless();
    vars.Uhara.EnableDebug();
}

init
{
    vars.Tool = vars.Uhara.CreateTool("UnrealEngine", "Events");

    vars.Resolver.Watch<ulong>("EmptySpaceStart", vars.Tool.FunctionFlag("BP_EmptySpace_Intro_C", "BP_EmptySpace_Intro_C", "Timeline__UpdateFunc"));
    vars.Resolver.Watch<ulong>("EndCardTrigger", vars.Tool.FunctionFlag("BP_EndcardTrigger_SNF_C", "BP_EndcardTrigger_SNF_C", "ExecuteUbergraph_BP_EndcardTrigger_SNF"));
}

update
{
    vars.Uhara.Update();
}


start
{
    return old.EmptySpaceStart != current.EmptySpaceStart && current.EmptySpaceStart != 0;
}
    
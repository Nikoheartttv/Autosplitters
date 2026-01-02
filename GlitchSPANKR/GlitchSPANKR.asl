state("GlitchSpank-Win64-Shipping") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara9")).CreateInstance("Main");
	vars.Uhara.AlertLoadless();
	vars.Uhara.EnableDebug();
	vars.Uhara.Settings.CreateFromXml("Components/GlitchSPANKR.Splits.xml");
	vars.BeatenLevelsList = new List<string>();
}

init
{
	vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
	vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");
	var GSync = vars.Utils.GSync;
	if (vars.Utils.GEngine != IntPtr.Zero) vars.Uhara.Log("GEngine: " + vars.Utils.GEngine.ToString("X"));
	if (vars.Utils.GWorld != IntPtr.Zero) vars.Uhara.Log("GWorld: " + vars.Utils.GWorld.ToString("X"));
	if (vars.Utils.FNames != IntPtr.Zero) vars.Uhara.Log("FNames: " + vars.Utils.FNames.ToString("X"));

	vars.Resolver.Watch<uint>("GWorldName", vars.Utils.GWorld, 0x18);
	vars.Resolver.Watch<int>("CurrentLevelIndex", vars.Utils.GEngine, 0x10A8, 0x1E0);
	vars.Resolver.Watch<int>("CurrentBranch", vars.Utils.GEngine, 0x10A8, 0x1E4);
	vars.Resolver.Watch<IntPtr>("BeatenLevels", vars.Utils.GEngine, 0x10A8, 0x1D8, 0xB0);
	vars.Resolver.Watch<int>("BeatenLevelsSize", vars.Utils.GEngine, 0x10A8, 0x1D8, 0xB8);
	vars.Resolver.Watch<int>("GSync", vars.Utils.GSync);
	vars.Resolver.Watch<ulong>("CreditsBadTrigger", vars.Events.FunctionFlag("BP_FallingMaster_BadCredits_C", "BP_FallingMaster_BadCredits_C", "ExecuteUbergraph_BP_FallingMaster_BadCredits"));

	current.World = "";
	current.Test = "";
	current.BeatenLevels = 0;
	current.LevelTitle = "";
	current.BeatenLevelsSize = 0;
	current.GSync = 0;
	current.PrevBeatenLevelsSize = 0;
	current.CreditsBadTrigger = 0;
	vars.splitTriggered = false; 
}

onStart
{
	vars.BeatenLevelsList.Clear();
	vars.LoggedLevels.Clear();
}

start
{
	return (old.World == "PrologueIntro" || old.World == "ShaderCompile") && current.World == "MainMenuBedroom";
}

update
{
	vars.Uhara.Update();

	var world = vars.Utils.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	if (old.World != current.World) vars.Uhara.Log("World: " + current.World);

	if (old.GSync != current.GSync)	vars.Uhara.Log("GSync changed: " + current.GSync);
}

split
{
    if (current.BeatenLevelsSize > current.PrevBeatenLevelsSize)
    {
        for (var i = current.PrevBeatenLevelsSize; i < current.BeatenLevelsSize; i++)
        {
            string levelName = vars.Resolver.ReadString(256, ReadStringType.UTF16, current.BeatenLevels + (i * 0x10), 0x0);
            if (!string.IsNullOrEmpty(levelName) && !vars.BeatenLevelsList.Contains(levelName) && settings.ContainsKey(levelName) && settings[levelName])
            {
                vars.BeatenLevelsList.Add(levelName);
                vars.Uhara.Log("Split triggered for '" + levelName + "'");
                current.PrevBeatenLevelsSize = current.BeatenLevelsSize;
                vars.splitTriggered = true;
                return true;
            }
        }
        current.PrevBeatenLevelsSize = current.BeatenLevelsSize;
    }

    if (!vars.splitTriggered && old.World != current.World &&
        (old.World == "The_Decision" || old.World == "Its_MY_Game" || old.World == "FINAL_HUB" || old.World == "Youre_Worth_It") &&
        settings.ContainsKey(old.World) && settings[old.World] && !vars.BeatenLevelsList.Contains(old.World))
    {
        vars.BeatenLevelsList.Add(old.World);
        vars.Uhara.Log("Failsafe world split triggered for '" + old.World + "' (on leaving)");
        vars.splitTriggered = true;
        return true;
    }

    if (!vars.splitTriggered && old.CreditsBadTrigger != current.CreditsBadTrigger && current.CreditsBadTrigger != 0 &&
        settings["CreditsBadSplit"] && !vars.BeatenLevelsList.Contains("CreditsBadSplit"))
    {
        vars.BeatenLevelsList.Add("Big_Booty_Slapper_6");
        vars.BeatenLevelsList.Add("CreditsBadSplit");
        vars.Uhara.Log("Credits Bad split triggered");
        vars.splitTriggered = true;
        return true;
    }

    if (old.World != current.World && settings["SPANKR_HQ"] && current.World == "SPANKR_HQ")
    {
        vars.BeatenLevelsList.Add("SPANKR_HQ");
        vars.Uhara.Log("SPANKR_HQ split triggered");
        return true;
    }
}

isLoading
{
	return current.GSync != 0;
}

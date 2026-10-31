state("PBZ") {}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/uhara10-PBZ")).CreateInstance("Main");
    vars.Uhara.AlertLoadless();
    vars.IsLaunched = false;
}

init
{
    int moduleSize = modules.First().ModuleMemorySize;

    if (moduleSize < 2000000)
    {
        vars.IsLaunched = true;
        timer.IsGameTimePaused = true;
        vars.Uhara.Reject(moduleSize);
        return;
    }

    vars.IsLaunched = false;

    vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
    vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");

    if (vars.Utils.GWorld == IntPtr.Zero) throw new Exception("GWorld not found");
    if (vars.Utils.GEngine == IntPtr.Zero) throw new Exception("GEngine not found");
    if (vars.Utils.FNames == IntPtr.Zero) throw new Exception("FNamePool not found");

    vars.Resolver.Watch<ulong>("GWorldName", vars.Utils.GWorld, 0x18);
    vars.Resolver.Watch<bool>("IsLoadingLevel", vars.Utils.GEngine, 0x12E0, 0x7A2);

    vars.Events.FunctionFlag("StartLoadingScreen", null, null, "StartPBZLoadingScreen");
    vars.Events.FunctionFlag("EndLoadingScreen", null, null, "EndPBZLoadingScreen");
    vars.Events.FunctionFlag("TempLoadingStart", "WB_TempLoadingScreen_C", null, "BP_OnActivated");
    vars.Events.FunctionFlag("TempLoadingEnd", "WB_TempLoadingScreen_C", null, "OnDisappeared");

    vars.Events.FunctionParentPtr<IntPtr>("SequenceNode", "PlayLevelSequence_C", null, "ExecuteUbergraph_PlayLevelSequence");
    vars.Events.FunctionParentPtr<IntPtr>("QTESequenceNode", "PlayLevelSequence_QTE_C", null, null);
    vars.Events.FunctionParentPtr<IntPtr>("ExSequenceNode", "PlayLevelSequenceEx_C", null, null);
    vars.Events.FunctionParentPtr<IntPtr>("QTEBase", "W_QTEBase_C", null, null);

    current.World = "";
    current.IsLoadingLevel = false;
    current.LoadingScreen = false;

    current.SequenceNode = IntPtr.Zero;
    current.QTESequenceNode = IntPtr.Zero;
    current.ExSequenceNode = IntPtr.Zero;
    current.QTEBase = IntPtr.Zero;

    current.StandardSequenceStatus = false;
    current.QTESequenceStatus = false;
    current.ExSequenceStatus = false;
    current.CutscenePlaying = false;

    current.QTEExited = -1;
    current.QTECountdown = -1;
    current.QTELongPress = -1;
    current.QTEActive = false;
}

start
{
    if (vars.IsLaunched) return false;

    return old.World == "PBZ_StartMenu_CE_WP" && (current.World == "PBZ_WP_ZhuLinGuWu" || current.World == "PBZ_Xigu_WP");
}

onStart
{
    timer.IsGameTimePaused = true;
}

update
{
    if (vars.IsLaunched)
    {
        timer.IsGameTimePaused = true;
        return;
    }

    vars.Uhara.Update();

    // World
    if (old.GWorldName != current.GWorldName || string.IsNullOrEmpty(current.World))
    {
        string world = vars.Utils.FNameToString(current.GWorldName);
        if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
    }

    // Loading starts
    if (vars.Resolver.CheckFlag("StartLoadingScreen")) current.LoadingScreen = true;
    if (vars.Resolver.CheckFlag("TempLoadingStart")) current.LoadingScreen = true;

    // Loading ends
    if (vars.Resolver.CheckFlag("EndLoadingScreen")) current.LoadingScreen = false;
    if (vars.Resolver.CheckFlag("TempLoadingEnd")) current.LoadingScreen = false;

    // Sequence playback
    current.StandardSequenceStatus = current.SequenceNode != IntPtr.Zero && vars.Resolver.Read<byte>(current.SequenceNode + 0x1F0, 0x290) == 1;
    current.QTESequenceStatus = current.QTESequenceNode != IntPtr.Zero && vars.Resolver.Read<byte>(current.QTESequenceNode + 0x1F0, 0x290) == 1;
    current.ExSequenceStatus = current.ExSequenceNode != IntPtr.Zero && vars.Resolver.Read<byte>(current.ExSequenceNode + 0x1F0, 0x290) == 1;

    current.CutscenePlaying = current.StandardSequenceStatus || current.QTESequenceStatus || current.ExSequenceStatus;

    // QTE override - Exited takes priority over Countdown and LongPress
    current.QTEExited = current.QTEBase != IntPtr.Zero ? vars.Resolver.Read<byte>(current.QTEBase + 0x490) : -1;
    current.QTECountdown = current.QTEBase != IntPtr.Zero ? vars.Resolver.Read<byte>(current.QTEBase + 0x491) : -1;
    current.QTELongPress = current.QTEBase != IntPtr.Zero ? vars.Resolver.Read<byte>(current.QTEBase + 0x493) : -1;

    if (current.QTEBase != old.QTEBase) current.QTEActive = false;

    if (current.QTEBase == IntPtr.Zero || current.QTEExited == 1 || current.QTEExited < 0) current.QTEActive = false;
    else if (current.QTECountdown == 1 || current.QTELongPress == 1) current.QTEActive = true;
    else if (current.QTECountdown < 0 || current.QTELongPress < 0) current.QTEActive = false;
}

isLoading
{
    if (vars.IsLaunched) return true;

    return current.IsLoadingLevel || current.LoadingScreen || current.World == "ServerCheck"
        || current.World == "PBZ_StartMenu_CE_WP" || (current.CutscenePlaying && !current.QTEActive);
}

exit
{
    timer.IsGameTimePaused = true;
}
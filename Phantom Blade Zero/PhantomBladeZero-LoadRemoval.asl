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

    vars.Events.FunctionFlag("LiftFadeIn", "BlackScreenForLift_C", null, "FadeInFinish");
    vars.Events.FunctionFlag("LiftFadeOut", "BlackScreenForLift_C", null, "ExecuteUbergraph_BlackScreenForLift");
    vars.Events.FunctionFlag("BlackScreenActivated", "WB_BlackScreen_Flow_C", null, "BP_OnActivated");
    vars.Events.FunctionFlag("BlackScreenDeactivated", "WB_BlackScreen_Flow_C", null, "BP_OnDeactivated");

    // Wildcard catches all PlayLevelSequence variants
    vars.Events.FunctionParentPtr<IntPtr>("LevelSequenceNode", "PlayLevelSequence*", null, null);
    vars.Events.FunctionParentPtr<IntPtr>("QTEBase", "W_QTEBase_C", null, null);

    current.World = "";
    current.IsLoadingLevel = false;
    current.LoadingScreen = false;
    current.BlackScreen = false;

    current.LevelSequenceNode = IntPtr.Zero;
    current.SequenceNode = IntPtr.Zero;
    current.QTEBase = IntPtr.Zero;

    current.SequenceStatus = false;
    current.CutscenePlaying = false;
    current.SequenceFName = 0UL;
    current.SequenceName = "";

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
    if (vars.Resolver.CheckFlag("BlackScreenActivated")) current.BlackScreen = true;
    if (vars.Resolver.CheckFlag("LiftFadeIn")) current.LoadingScreen = true;
    if (vars.Resolver.CheckFlag("LiftFadeOut")) current.LoadingScreen = false;

    // Loading ends
    if (vars.Resolver.CheckFlag("EndLoadingScreen")) current.LoadingScreen = false;
    if (vars.Resolver.CheckFlag("TempLoadingEnd")) current.LoadingScreen = false;
    if (vars.Resolver.CheckFlag("BlackScreenDeactivated")) current.BlackScreen = false;

    // Validate captured node: only update SequenceNode if we have a valid one
    if (current.LevelSequenceNode != IntPtr.Zero)
    {
        IntPtr loadedSeq = vars.Resolver.Read<IntPtr>(current.LevelSequenceNode + 0x1B8);
        if (loadedSeq != IntPtr.Zero)
        {
            ulong fName = vars.Resolver.Read<ulong>(loadedSeq + 0x18);
            string seqName = vars.Utils.FNameToString(fName);
            if (!string.IsNullOrEmpty(seqName) && seqName != "None")
            {
                if (current.SequenceNode == IntPtr.Zero)
                {
                    current.SequenceNode = current.LevelSequenceNode;
                    current.SequenceName = seqName;
                }
                else
                {
                    current.SequenceNode = current.LevelSequenceNode;
                    current.SequenceFName = fName;
                }
            }
        }
        current.LevelSequenceNode = IntPtr.Zero;
    }

    // Validate stored node: clear if no valid LoadedLevelSequence or name
    if (current.SequenceNode != IntPtr.Zero)
    {
        IntPtr loadedSeq = vars.Resolver.Read<IntPtr>(current.SequenceNode + 0x1B8);
        if (loadedSeq == IntPtr.Zero)
        {
            current.SequenceNode = IntPtr.Zero;
        }
        else
        {
            ulong fName = vars.Resolver.Read<ulong>(loadedSeq + 0x18);
            string seqName = vars.Utils.FNameToString(fName);
            if (string.IsNullOrEmpty(seqName) || seqName == "None") current.SequenceNode = IntPtr.Zero;
        }
    }

    // Sequence status: node presence = cutscene active
    current.SequenceStatus = current.SequenceNode != IntPtr.Zero && vars.Resolver.Read<byte>(current.SequenceNode + 0x1F0, 0x290) == 1;
    current.CutscenePlaying = current.SequenceNode != IntPtr.Zero;

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

    return current.IsLoadingLevel || current.LoadingScreen || current.BlackScreen
        || current.World == "ServerCheck" || current.World == "PBZ_StartMenu_CE_WP"
        || (current.CutscenePlaying && !current.QTEActive);
}


exit
{
    timer.IsGameTimePaused = true;
}
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

    if (vars.Utils.GWorld == IntPtr.Zero || vars.Utils.GEngine == IntPtr.Zero || vars.Utils.FNames == IntPtr.Zero)
        throw new Exception("GWorld, GEngine or FNamePool not found");

    vars.Resolver.Watch<ulong>("GWorldName", vars.Utils.GWorld, 0x18);
    vars.Resolver.Watch<bool>("IsLoadingLevel", vars.Utils.GEngine, 0x12E0, 0x7A2);

    vars.Events.FunctionFlag("StartLoadingScreen", null, null, "StartPBZLoadingScreen");
    vars.Events.FunctionFlag("EndLoadingScreen", null, null, "EndPBZLoadingScreen");
    vars.Events.FunctionFlag("TempLoadingStart", "WB_TempLoadingScreen_C", null, "BP_OnActivated");
    vars.Events.FunctionFlag("TempLoadingEnd", "WB_TempLoadingScreen_C", null, "OnDisappeared");
    vars.Events.FunctionFlag("BlackScreenActivated", "WB_BlackScreen*", null, "BP_OnActivated");
    vars.Events.FunctionFlag("BlackScreenDeactivated", "WB_BlackScreen*", null, "BP_OnDeactivated");

    vars.Events.FunctionParentPtr<IntPtr>("SeqNode_Capture", "PlayLevelSequence*", null, null);
    vars.Events.FunctionParentPtr<IntPtr>("QTEBase", "W_QTE*", null, null);

    current.World = "";
    current.IsLoadingLevel = false;
    current.LoadingScreen = false;
    current.BlackScreen = false;

    current.SeqNode_Capture = IntPtr.Zero;
    current.SequenceNode = IntPtr.Zero;
    current.CutscenePlaying = false;

    current.QTEBase = IntPtr.Zero;
    current.QTEClass = "";
    current.QTEExited = -1;
    current.QTECountdown = -1;
    current.QTERepeatedPress = -1;
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

    // Loading screens
    if (vars.Resolver.CheckFlag("StartLoadingScreen")) current.LoadingScreen = true;
    if (vars.Resolver.CheckFlag("TempLoadingStart")) current.LoadingScreen = true;
    if (vars.Resolver.CheckFlag("EndLoadingScreen")) current.LoadingScreen = false;
    if (vars.Resolver.CheckFlag("TempLoadingEnd")) current.LoadingScreen = false;
    if (vars.Resolver.CheckFlag("BlackScreenActivated")) current.BlackScreen = true;
    if (vars.Resolver.CheckFlag("BlackScreenDeactivated")) current.BlackScreen = false;

    // Accept a captured sequence only when its loaded sequence and name are valid.
    bool captureAccepted = false;

    if (current.SeqNode_Capture != IntPtr.Zero)
    {
        IntPtr ls = vars.Resolver.Read<IntPtr>(current.SeqNode_Capture + 0x1B8);
        if (ls != IntPtr.Zero)
        {
            string sn = vars.Utils.FNameToString(vars.Resolver.Read<ulong>(ls + 0x18));

            if (!string.IsNullOrEmpty(sn) && sn != "None")
            {
                current.SequenceNode = current.SeqNode_Capture;
                captureAccepted = true;
            }
        }

        current.SeqNode_Capture = IntPtr.Zero;
    }

    // Avoid revalidating a newly accepted capture in the same update.
    if (!captureAccepted && current.SequenceNode != IntPtr.Zero)
    {
        IntPtr ls = vars.Resolver.Read<IntPtr>(current.SequenceNode + 0x1B8);

        if (ls == IntPtr.Zero) current.SequenceNode = IntPtr.Zero;
        else
        {
            string sn = vars.Utils.FNameToString(vars.Resolver.Read<ulong>(ls + 0x18));
            if (string.IsNullOrEmpty(sn) || sn == "None") current.SequenceNode = IntPtr.Zero;
        }
    }

    current.CutscenePlaying = current.SequenceNode != IntPtr.Zero;

    // QTE: only read the known layout on supported widget classes.
    if (current.QTEBase == IntPtr.Zero)
    {
        current.QTEClass = "";
        current.QTEExited = -1;
        current.QTECountdown = -1;
        current.QTERepeatedPress = -1;
        current.QTELongPress = -1;
        current.QTEActive = false;
    }
    else
    {
        if (current.QTEBase != old.QTEBase || string.IsNullOrEmpty(current.QTEClass))
        {
            current.QTEClass = "";
            IntPtr classPtr = vars.Resolver.Read<IntPtr>(current.QTEBase + 0x10);

            if (classPtr != IntPtr.Zero) current.QTEClass = vars.Utils.FNameToString(vars.Resolver.Read<ulong>(classPtr + 0x18));
        }

        if (current.QTEBase != old.QTEBase || current.QTEClass != old.QTEClass) current.QTEActive = false;

        if (current.QTEClass == "W_QTEBase_C" || current.QTEClass == "W_QTERepatedPressed_C")
        {
            current.QTEExited = vars.Resolver.Read<byte>(current.QTEBase + 0x490);
            current.QTECountdown = vars.Resolver.Read<byte>(current.QTEBase + 0x491);
            current.QTERepeatedPress = vars.Resolver.Read<byte>(current.QTEBase + 0x492);
            current.QTELongPress = vars.Resolver.Read<byte>(current.QTEBase + 0x493);

            // Exit takes priority. Otherwise preserve the existing active latch.
            if (current.QTEExited != 0) current.QTEActive = false;
            else if (current.QTECountdown == 1 || current.QTERepeatedPress == 1 || current.QTELongPress == 1) current.QTEActive = true;
            else if (current.QTECountdown != 0 || current.QTERepeatedPress != 0 || current.QTELongPress != 0) current.QTEActive = false;
        }
        else
        {
            current.QTEExited = -1;
            current.QTECountdown = -1;
            current.QTERepeatedPress = -1;
            current.QTELongPress = -1;
            current.QTEActive = false;
        }
    }
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
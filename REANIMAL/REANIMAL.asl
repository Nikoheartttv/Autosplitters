state("REANIMAL"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main");
	vars.Uhara.AlertLoadless();
	vars.CompletedSplits = new List<string>();

	dynamic[,] _settings =
	{
		{ "TheCleaningHouse", true, "Chapter 1 - Dead In The Water", null },
		{ "AfterTheFlood", true, "Chapter 2 - The Cleaning House", null },
		{ "NoShelter", true, "Chapter 3 - After The Flood", null },
		{ "DownInAHole", true, "Chapter 4 - No Shelter", null },
		{ "NobodyLeftBehind", true, "Chapter 5 - Down In A Hole", null },
		{ "TheSpoils", true, "Chapter 6 - Nobody Left Behind", null },
		{ "TheWatcher", true, "Chapter 7 - The Spoils", null },
		{ "AllConsumingPast", true, "Chapter 8 - The Watcher", null },
		{ "EndSplit", true, "Chapter 9 - All-Consuming Past", null }
	};
	vars.Uhara.Settings.Create(_settings);
}

init
{
	vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
	vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");

	// if (vars.Utils.GEngine != IntPtr.Zero) vars.Uhara.Log("GEngine found at " + vars.Utils.GEngine.ToString("X"));
	// if (vars.Utils.GWorld != IntPtr.Zero) vars.Uhara.Log("GWorld found at " + vars.Utils.GWorld.ToString("X")); 
	// if (vars.Utils.FNames != IntPtr.Zero) vars.Uhara.Log("FNames found at " + vars.Utils.FNames.ToString("X"));

	vars.Resolver.Watch<uint>("GWorldName", vars.Utils.GWorld, 0x18);
	vars.Resolver.Watch<bool>("TransitionType", vars.Utils.GEngine, 0xBBB);
	vars.Resolver.Watch<bool>("CinematicDisableMovement", vars.Utils.GWorld, 0x160, 0x605);
	vars.Resolver.Watch<uint>("TelemtryCurrentChapterName", vars.Utils.GWorld, 0x160, 0x488);
	vars.Resolver.Watch<float>("CameraDepth", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x3AC);

	vars.Events.FunctionFlag("DeathHandler", "DeathHandler_*", "DeathHandler_*", "OnDeathHandlingStarted");
	vars.Events.FunctionFlag("BoatSpawn", "BP_PlayersMontageOverride_C", "BP_PlayersMontageOverride_C", "HIP_Girl Play Montage");
	vars.Events.FunctionFlag("FadeFromBlack", "BP_IngameGameMode_C", "BP_IngameGameMode_C", "K2_OnRestartPlayer");
	vars.Events.FunctionFlag("RabbitEndSplit", "SEQ_AmbushStart_01_DirectorBP_C", "SEQ_AmbushStart_01_DirectorBP_C", "SequenceEvent__ENTRYPOINTSEQ_AmbushStart_01_DirectorBP");

	vars.Loading = false;
	current.World = "";
	current.ChapterName = "";
	vars.LastUpdatedWorld = "";
}

start
{
	return current.CameraDepth < old.CameraDepth && old.CameraDepth > 1f &&
		current.World == "MLVL_EverholmWorld" && (vars.LastUpdatedWorld == "LVL_MainMenu" || vars.LastUpdatedWorld == "");
}

onStart
{
	vars.CompletedSplits.Clear();
	vars.LastUpdatedWorld = "X";
}

update
{
	vars.Uhara.Update();

	var world = vars.Utils.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;

	var chaptername = vars.Utils.FNameToString(current.TelemtryCurrentChapterName);
	if (!string.IsNullOrEmpty(chaptername)) current.ChapterName = chaptername;

	if (vars.Resolver.CheckFlag("BoatSpawn")) vars.Loading = false;
	if (vars.Resolver.CheckFlag("FadeFromBlack")) vars.Loading = false;
	if (vars.Resolver.CheckFlag("DeathHandler")) vars.Loading = true;
}

split
{
	if (old.ChapterName != current.ChapterName && !string.IsNullOrEmpty(current.ChapterName))
    {
        if (settings.ContainsKey(current.ChapterName) && settings[current.ChapterName] && !vars.CompletedSplits.Contains(current.ChapterName))
        {
            vars.CompletedSplits.Add(current.ChapterName);
            vars.Uhara.Log("Split on chapter: " + current.ChapterName);
            return true;
        }
    }

	if (vars.Resolver.CheckFlag("RabbitEndSplit"))
    {
        if (settings["EndSplit"] && !vars.CompletedSplits.Contains("EndSplit"))
        {
            vars.CompletedSplits.Add("EndSplit");
            return true;
        }
    }

}

isLoading
{
	return current.TransitionType || vars.Loading;
}

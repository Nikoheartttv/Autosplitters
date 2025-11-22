state("Amanda The Adventurer 3"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    Assembly.Load(File.ReadAllBytes("Components/uhara9")).CreateInstance("Main");
	vars.Helper.GameName = "Amanda The Adventurer 3";
	vars.Helper.LoadSceneManager = true;
	vars.Helper.AlertLoadless();
	// vars.Uhara.EnableDebug();

	dynamic[,] _settings =
	{
		{ "EndingSplits", true, "Ending Splits", null, "The timer will automatically pause and resume between endings\nif it's set to Game Time regardless of this setting."},
			{ "FalseEnding", true, "False Ending", "EndingSplits", null },
			{ "TrueEnding", true, "True Ending", "EndingSplits", null },
		{ "TapesSplits", false, "Tapes Splits", null, "The splits will occur once you've started the new tape" },
			{ "1", true, "Tape 1 - Candy Shop", "TapesSplits", null },
			{ "2", true, "Tape 2 - Amusement Park WIP", "TapesSplits", null },
			{ "M1", false, "Memory Tape 1- Rollercoaster Ride", "TapesSplits", null },
			{ "3", true, "Tape 3 - Healthy Food Helps Us Grow", "TapesSplits", null },
			{ "4", true, "Tape 4 - A Day At The Beach", "TapesSplits", null },
			{ "M2", false, "Memory Tape 2 - Best Beach Friends", "TapesSplits", null },
			{ "5", true, "Tape 5 - Scavenger Hunt", "TapesSplits", null },
			{ "6", false, "Tape 6 - When I'm Grown Up", "TapesSplits", null },
			{ "7", true, "Tape 7 - Let's Have a Party!", "TapesSplits", null },
			{ "M3", false, "Memory Tape 3 - 7th Birthday", "TapesSplits", null },
			{ "s1", true, "Secret Tape 1 - Sam's Rescure Attempt", "TapesSplits", null },
			{ "s2", true, "Secret Tape 2 - News Report", "TapesSplits", null },
			{ "s3", true, "Secret Tape 3 - Marcus' Employment Interview", "TapesSplits", null },
			{ "s4", true, "Secret Tape 4 - Hameln Press Conerence", "TapesSplits", null },
	};
	vars.Helper.Settings.Create(_settings);
}

init
{
	vars.PlayedEnding = false;
	vars.PlayedTapes = new List<string>();
	// Ending Lever
	var Instance = vars.Uhara.CreateTool("Unity", "DotNet", "Instance");
	Instance.Watch<bool>("EndingCheck", "PartyPuzzle", "endingLever", "clickableColliders", "0x20", "0x10", "0x6D");
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
		vars.Helper["Paused"] = mono.Make<bool>("MenuManager", 1, "_instance", "GameIsPaused");
		vars.Helper["LoadingText"] = mono.Make<bool>("SceneLoadManager", 1, "_instance", 0x18, 0x57D);
		vars.Helper["MovementEnabled"] = mono.Make<bool>("PlayerInputController", 1, "_instance", "_movementEnabled");
		vars.Helper["CreditsVisible"] = mono.Make<bool>("CreditsMenu", 1, "_instance", 0x10, 0x39);
		vars.Helper["VideoID"] = mono.MakeString("TV", "_instance", "CurrentTape", "id");

		// Save Game Data
		vars.Helper["TVCanClick"] = mono.Make<bool>("TV", "_instance", "InteractClickable", "CanClick");
		vars.Helper["interactionInitalized"] = mono.Make<bool>("TV", "_instance", "CurrentTape", "interactionInitalized");
		vars.Helper["VideoCheck"] = mono.Make<int>("TV", "_instance", "CurrentTape");

		return true;
	});

	current.EndingCheck = true;
	current.CurrentPuzzle = 0;
	current.MovementEnabled = false;
	vars.InGameScene = (Func<bool>)(() => vars.Helper.Scenes.Active.Index >= 2);
}

start
{
	return vars.InGameScene() && !old.MovementEnabled && current.MovementEnabled;
}

onStart
{
	vars.PlayedTapes.Clear();
}

split
{
	// Tapes Splitting
	if (current.VideoCheck != old.VideoCheck && old.VideoCheck == 0 && settings[current.VideoID.ToString()] && !vars.PlayedTapes.Contains(current.VideoID.ToString()) && settings["TapesSplits"])
    {
        vars.PlayedTapes.Add(current.VideoID.ToString());
        return true;
    } 
	else if (vars.PlayedTapes.Count == 0 && old.TVCanClick == true && current.TVCanClick == false && settings[current.VideoID.ToString()] && settings["TapesSplits"])
	{
        vars.PlayedTapes.Add(current.VideoID.ToString());
        return true;
    } 

	// Ending Split
    if (vars.Helper.Scenes.Active.Index == 3 && !current.EndingCheck && !vars.PlayedEnding)
    {
		vars.PlayedEnding = true;
        return true;
    }
	else if (vars.Helper.Scenes.Active.Index != 3 && vars.PlayedEnding)
	{
		vars.PlayedEnding = false;
	}
}

isLoading
{
	return vars.Helper.Scenes.Active.Index == 0 || current.LoadingText || current.CreditsVisible;
}

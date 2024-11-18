state("Amanda The Adventurer 2"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Amanda The Adventurer 2";
	vars.Helper.LoadSceneManager = true;
	vars.Helper.AlertLoadless();

	dynamic[,] _settings =
	{
		{ "EndingSplits", true, "Ending Splits", null, "The timer will automatically pause and resume between endings\nif it's set to Game Time regardless of this setting."},
			{ "FalseEnding", true, "False Ending", "EndingSplits", null },
			{ "TrueEnding", true, "True Ending", "EndingSplits", null },
		{ "TapesSplits", false, "Tapes Splits", null, "The splits will occur once you've started the new tape" },
			{ "1", true, "Tape 1 - Let's Plan a Trip", "TapesSplits", null },
			{ "2", true, "Tape 2 - Goodnight!", "TapesSplits", null },
			{ "3", true, "Tape 3 - Let's Practice Patience!", "TapesSplits", null },
			{ "4", true, "Tape 4 - Let's Hunt For Treasure!", "TapesSplits", null },
			{ "5", true, "Tape 5 - Let's Start the Day!", "TapesSplits", null },
			{ "6", true, "Tape 6 - When You're Feeling Bad", "TapesSplits", null },
			{ "7", true, "Tape 7 - We Can Fix It!", "TapesSplits", null },
			{ "8", true, "Tape 8 - Do You Feel Safe?", "TapesSplits", null },
			{ "s1", true, "Secret Tape 1 - Secret Meetings", "TapesSplits", null },
			{ "s2", true, "Secret Tape 2 - Sam's Message to Sam", "TapesSplits", null },
			{ "s3", true, "Secret Tape 3 - Sam Reads at the Library", "TapesSplits", null },
			{ "s4", true, "Secret Tape 4 - Hospital Filming", "TapesSplits", null },
		{ "PuzzleSplits", false, "Puzzle Splits", null, null },
			{ "Piggy Bank", true, "Piggy Bank (Tape 1)", "PuzzleSplits", null },
			{ "Activity Block", true, "Activity Block (Tape 2)", "PuzzleSplits", null },
			{ "Wise Monkeys", true, "Wise Monkeys (Tape 3)", "PuzzleSplits", null },
			{ "Train Set", true, "Train Set (Before Tape 5)", "PuzzleSplits", null },
			{ "PopUp Book", true, "Pop-up Book (Tape 6)", "PuzzleSplits", null },
			{ "TreasureHunt", true, "Treasure Hunt (Tape 4 After Fake Death)", "PuzzleSplits", null },
			{ "Frog", true, "Dissect the Frog (Tape 7)", "PuzzleSplits", null },
			{ "Microfiche", true, "Microfiche (Tape 8?)", "PuzzleSplits", null },
	};
	vars.Helper.Settings.Create(_settings);
}

init
{
	vars.PlayedTapes = new List<string>();
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
		vars.Helper["Paused"] = mono.Make<bool>("MenuManager", 1, "_instance", "GameIsPaused");
		vars.Helper["LoadingText"] = mono.Make<bool>("SceneLoadManager", 1, "_instance", 0x18, 0x57D);
		vars.Helper["MovementEnabled"] = mono.Make<bool>("PlayerInputController", 1, "_instance", "_movementEnabled");
		vars.Helper["TapeVisible"] = mono.Make<bool>("GameManager", 1, "_instance", "officeDesk", "cassettePlayer", "displayTape", 0x10, 0x57);
		vars.Helper["CreditsVisible"] = mono.Make<bool>("CreditsMenu", 1, "_instance", 0x10, 0x39);
		vars.Helper["MonsterMandaVisible"] = mono.Make<bool>("GameManager", 1, "_instance", "officeDesk", "monstermanda", 0x10, 0x57);
		vars.Helper["VideoID"] = mono.MakeString("TV", "_instance", "CurrentTape", "id");
		// Save Game Data
		vars.Helper["SolvedPuzzles"] = mono.MakeList<IntPtr>("SaveManager", 1, "_instance", "Data", "SolvedPuzzles");
		vars.Helper["CurrentPuzzle"] = mono.MakeString("SaveManager", 1, "_instance", "Data", "CurrentPuzzle");
		vars.Helper["CurrentPuzzleSolved"] = mono.Make<bool>("SaveManager", 1, "_instance", "Data", "CurrentPuzzleSolved");
		vars.Helper["TVCanClick"] = mono.Make<bool>("TV", "_instance", "InteractClickable", "CanClick");

		return true;
	});

	current.activeScene = "";
	current.CurrentPuzzle = "";
	current.MovementEnabled = false;
}

start
{
	return vars.Helper.Scenes.Active.Index == 1 && string.IsNullOrEmpty(current.CurrentPuzzle) && !old.MovementEnabled && current.MovementEnabled;
}

onStart
{
	vars.PlayedTapes.Clear();
}

update
{
	if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Active.Name))	current.activeScene = vars.Helper.Scenes.Active.Name;
	if(current.activeScene != old.activeScene) vars.Log("active: Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");

	// Used as a fix for Main Menu load removal?
	if (current.activeScene == "Title" && old.LoadingText == true && current.LoadingText == false)
	{
		current.activeScene = "Game";
		vars.GameActive++;
	}

	if (vars.Helper["SolvedPuzzles"].Current.Count > vars.Helper["SolvedPuzzles"].Old.Count)
	{
		string s = vars.Helper.ReadString(false, vars.Helper["SolvedPuzzles"].Current[vars.Helper["SolvedPuzzles"].Current.Count - 1]);
		vars.Log("Puzzle Solved: " + s);
	}

	// Fake Ending Tapes List Reset
	if (current.CurrentPuzzle == "" && vars.PlayedTapes.Contains("4") && !vars.PlayedTapes.Contains("8"))
    {
        vars.PlayedTapes.Clear();
    }
}

split
{
	// Puzzle Solved Splitting
	if (vars.Helper["SolvedPuzzles"].Current.Count > vars.Helper["SolvedPuzzles"].Old.Count && settings["PuzzleSplits"])
	{
		string name = vars.Helper.ReadString(false, vars.Helper["SolvedPuzzles"].Current[vars.Helper["SolvedPuzzles"].Current.Count - 1]);
		if (settings[name]) return true;
	}

	// Tapes Splitting
	if (current.VideoID != old.VideoID && settings[current.VideoID.ToString()] && !vars.PlayedTapes.Contains(current.VideoID.ToString()) && settings["TapesSplits"])
    {
        vars.PlayedTapes.Add(current.VideoID.ToString());
        return true;
    } 
	else if (vars.PlayedTapes.Count == 0 && old.TVCanClick == true && current.TVCanClick == false && settings[current.VideoID.ToString()] && settings["TapesSplits"])
	{
        vars.PlayedTapes.Add(current.VideoID.ToString());
        return true;
    } 

	// Ending Splits
	// False Ending
    if (current.MonsterMandaVisible != old.MonsterMandaVisible && current.CurrentPuzzle == "Microfiche" && current.MonsterMandaVisible && settings["EndingSplits"])
    {
        return true;
    }

	// True Ending
	if (current.TapeVisible != old.TapeVisible && current.CurrentPuzzle == "Microfiche" && current.TapeVisible && settings["EndingSplits"])
    {
        return true;
    }
}

isLoading
{
	return current.activeScene == "Title" || current.LoadingText || current.CreditsVisible;
}

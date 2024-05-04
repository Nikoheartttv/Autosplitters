// Thanks to PixelSplit for adding in some custom Autosplitting Data into their game!
// Autosplitter by Nikoheart

state("REVEIL"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "REVEIL";
	vars.Helper.LoadSceneManager = true;
	vars.Helper.AlertGameTime();

	dynamic[,] _settings =
	{
		{ "Levels", true, "Levels", null },
			{ "Chapter 1", true, "Chapter 1", "Levels" },
				{ "1", true, "Chapter 1 - House", "Chapter 1" },
                { "2", true, "Chapter 1 - Dorie's Room", "Chapter 1" },
				{ "3", true, "Chapter 1 - The Circus", "Chapter 1" },
				{ "4", true, "Chapter 1 - Funhouse", "Chapter 1" },
				{ "5", true, "Chapter 1 - Strange Apartment", "Chapter 1" },
			{ "Chapter 2", true, "Chapter 2", "Levels" },
				{ "6", true, "Chapter 2 - Home Together", "Chapter 2" },
                { "7", true, "Chapter 2 - The Studio", "Chapter 2" },
                { "8", true, "Chapter 2 - Another Dream", "Chapter 2" },
                { "9", true, "Chapter 2 - The Garage", "Chapter 2" },
				{ "10", true, "Chapter 2 - Circus Train", "Chapter 2" },
			{ "Chapter 3", true, "Chapter 3", "Levels" },
				{ "11", true, "Chapter 3  - A Phone Booth", "Chapter 3" },
				{ "12", true, "Chapter 3 - Fortune Teller", "Chapter 3" },
                { "13", true, "Chapter 3 - Sideshow", "Chapter 3" },
                { "14", true, "Chapter 3 - The Big Top", "Chapter 3" },
			{ "Chapter 4", true, "Chapter 4", "Levels" },
				{ "15", true, "Chapter 4 - The Forest of Memories", "Chapter 4" },
				{ "16", true, "Chapter 4 - Ghost Train", "Chapter 4" },
			{ "Chapter 5", true, "Chapter 5", "Levels" },
				{ "17", true, "Chapter 5 - The House", "Chapter 5" },
				{ "18", true, "Chapter 5 - Facility", "Chapter 5" },
				{ "19", true, "Chapter 5 - The Apartment Again", "Chapter 5" },
				{ "20", true, "Chapter 5 - The Machine", "Chapter 5" },
	};

	vars.Helper.Settings.Create(_settings);
	vars.VisitedLevel = new List<string>();
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
		var lv = mono["LiveSplit", "ReveilAutoSplitData"];

		vars.Helper["GameHasStarted"] = lv.Make<int>("GameHasStarted");
        vars.Helper["GameIsLoading"] = lv.Make<int>("GameIsLoading");
		vars.Helper["GameIsFinished"] = lv.Make<int>("GameIsFinished");
        vars.Helper["OverallChapterNum"] = lv.Make<int>("OverallChapterNum");
        vars.Helper["Act"] = lv.Make<int>("Act");

		return true;
	});

	current.activeScene = "";
}

start
{
    return old.GameHasStarted == 0 && current.GameHasStarted == 1;
}

onStart
{
	timer.IsGameTimePaused = true;
}

update
{
	current.activeScene = vars.Helper.Scenes.Active.Name == null ? current.activeScene : vars.Helper.Scenes.Active.Name;
	if(current.activeScene != old.activeScene) vars.Log("active: Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");
}

split
{
    if (current.OverallChapterNum > old.OverallChapterNum && settings[current.OverallChapterNum.ToString()] && !vars.VisitedLevel.Contains(current.OverallChapterNum.ToString()))
    {
        vars.VisitedLevel.Add(current.OverallChapterNum.ToString());
        return settings[current.OverallChapterNum.ToString()];
    }

    if (current.OverallChapterNum == 2 && !vars.VisitedLevel.Contains("3") && old.activeScene == "Akt 1 - House" && current.activeScene == "Akt 1 - Circus_Day")
	{
		vars.VisitedLevel.Add("3");
        return true;
	}

    if (current.Act == 5 && current.OverallChapterNum == 20 
        && old.GameIsFinished == 0 & current.GameIsFinished == 1)
        {
            return true;
        }
}

isLoading
{
    return current.GameIsLoading == 1;
}

onReset
{
	vars.VisitedLevel.Clear();
}

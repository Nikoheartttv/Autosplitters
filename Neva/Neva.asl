// Neva Autosplitter
// Made by Nikoheart // Game has to start from New Game

state("Neva") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Neva";
	vars.Helper.LoadSceneManager = true;
	vars.Helper.AlertLoadless();

	dynamic[,] _settings =
	{
		{ "Splits", true, "Splits", null },
			{ "Chapter1", true, "Chapter 1 - Summer", "Splits" },
				{ "20", true, "Summer 1A - 1", "Chapter1" },
				{ "50", true, "Summer 1A - 2", "Chapter1" },
				{ "70", true, "Summer 1B - 1", "Chapter1" },
				{ "100", true, "Summer 1B - 2", "Chapter1" },
			{ "Chapter2", true, "Chapter 2 - Fall", "Splits" },
				{ "120", true, "Fall 2A - 1", "Chapter1" },
				{ "150", true, "Fall 2A - 2", "Chapter1" },
				{ "170", true, "Fall 2B - 1", "Chapter1" },
				{ "200", true, "Fall 2B - 2", "Chapter1" },
				{ "210", true, "Fall 2C - 0", "Chapter1" },
				{ "220", true, "Fall 2C - 1", "Chapter1" },
				{ "230", true, "Fall 2C - 2", "Chapter1" },
				{ "250", true, "Fall 2C - 3", "Chapter1" },
			{ "Chapter3", true, "Chapter 3 - Winter", "Splits" },
				{ "270", true, "Winter 3A - 1", "Chapter1" },
				{ "290", true, "Winter 3A - 2", "Chapter1" },
				{ "300", true, "Winter 3A - 3", "Chapter1" },
				{ "320", true, "Winter 3B - 1", "Chapter1" },
				{ "350", true, "Winter 3B - 2", "Chapter1" },
			{ "Chapter4", true, "Chapter 4 - Spring", "Splits" },
				{ "Credits", true, "Spring 1A - 1 (End)", "Chapter1" },
	};
	vars.Helper.Settings.Create(_settings);
	vars.CompletedSplits = new List<string>();
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono => 
	{
		var mm = mono["Home.MainManager"];
		var cm = mono["Home.ChapterManager"];
		var pm = mono["Home.ProgressionManager"];

		vars.Helper["IsInGame"] = mm.Make<bool>("_instance", "m_IsInGame");
		vars.Helper["ChapterScenesLoading"] = mm.Make<bool>("_instance", "m_ChapterManager", cm["m_ChapterScenesLoading"]);
		vars.Helper["LastChapterUnlocked"] = mm.Make<int>("_instance", "m_ProgressionManager", pm["LastChapterUnlocked"]);

		return true;
	});

	current.loadingScene = "";
}

onStart
{
	vars.CompletedSplits.Clear();
}

start
{
	return current.loadingScene == "Chapter_1A_Gameplay" && old.IsInGame == false && current.IsInGame == true;
}

update
{
	if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Loaded[0].Name))	current.loadingScene = vars.Helper.Scenes.Loaded[0].Name;
	if(current.loadingScene != old.loadingScene) vars.Log("loading: Old: \"" + old.loadingScene + "\", Current: \"" + current.loadingScene + "\"");

	if(old.LastChapterUnlocked != current.LastChapterUnlocked) vars.Log("LastChapterUnlocked: " + current.LastChapterUnlocked);
}

split
{
	if (old.LastChapterUnlocked != current.LastChapterUnlocked && settings[current.LastChapterUnlocked.ToString()] && !vars.CompletedSplits.Contains(current.LastChapterUnlocked.ToString()))
	{
		vars.CompletedSplits.Contains(current.LastChapterUnlocked.ToString());
		return true;
	}
	if (old.loadingScene != "Credits" && current.loadingScene == "Credits" && settings["Credits"] && !vars.CompletedSplits.Contains("Credits"))
	{
		vars.CompletedSplits.Contains(current.LastChapterUnlocked.ToString());
		return true;
	}
		
}

isLoading
{
	return current.ChapterScenesLoading == true || current.IsInGame == false;
}
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
				{ "20", true, "Summer Part 1", "Chapter1" },
				{ "50", true, "Summer Part 2", "Chapter1" },
				{ "70", true, "Summer Part 3", "Chapter1" },
				{ "100", true, "Summer Part 4", "Chapter1" },
			{ "Chapter2", true, "Chapter 2 - Fall", "Splits" },
				{ "120", true, "Fall Part 1", "Chapter2" },
				{ "150", true, "Fall Part 2", "Chapter2" },
				{ "170", true, "Fall Part 3", "Chapter2" },
				{ "210", true, "Fall Part 4", "Chapter2" },
				{ "220", true, "Fall Part 5", "Chapter2" },
				{ "250", true, "Fall Part 6", "Chapter2" },
			{ "Chapter3", true, "Chapter 3 - Winter", "Splits" },
				{ "270", true, "Winter Part 1", "Chapter3" },
				{ "290", true, "Winter Part 2", "Chapter3" },
				{ "300", true, "Winter Part 3", "Chapter3" },
				{ "320", true, "Winter Part 4", "Chapter3" },
				{ "350", true, "Winter Part 5", "Chapter3" },
			{ "Chapter4", true, "Chapter 4 - Spring", "Splits" },
				{ "Ending", true, "Spring Part 1 (End)", "Chapter4" },
	};
	vars.Helper.Settings.Create(_settings);
	vars.CompletedSplits = new List<string>();
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono => 
	{
		// var mm = mono["Home.MainManager"];
		// var cm = mono["Home.ChapterManager"];
		// var pm = mono["Home.ProgressionManager"];
		// var guic = mono["Home.GUICamera"];
		// var cim = mono["Home.CustomInputManager"];

		// vars.Helper["IsInGame"] = mm.Make<bool>("_instance", "m_IsInGame");
		// vars.Helper["ChapterScenesLoading"] = mm.Make<bool>("_instance", "m_ChapterManager", cm["m_ChapterScenesLoading"]);
		// vars.Helper["LastChapterUnlocked"] = mm.Make<int>("_instance", "m_ProgressionManager", pm["LastChapterUnlocked"]);
		// vars.Helper["SkipVideoIsEnabled"] = mm.Make<bool>("_instance", "m_GUICamera", guic["m_SkipVideoIsEnabled"]);
		// vars.Helper["ForceKeepPreviousParenting"] = mm.Make<bool>("_instance", 0xf8, 0xd8, 0x28, 0x129);

		vars.Helper["IsInGame"] = mono.Make<bool>("Home.MainManager", "Instance", "m_IsInGame");
		vars.Helper["ChapterScenesLoading"] = mono.Make<bool>("Home.MainManager", "Instance", "m_ChapterManager", "m_ChapterScenesLoading");
		vars.Helper["LastChapterUnlocked"] = mono.Make<int>("Home.MainManager", "Instance", "m_ProgressionManager", "LastChapterUnlocked");
		vars.Helper["SkipVideoIsEnabled"] = mono.Make<bool>("Home.MainManager", "Instance", "m_GUICamera", "m_SkipVideoIsEnabled");
		vars.Helper["ForceKeepPreviousParenting"] = mono.Make<bool>("Home.MainManager", "Instance", "m_Player", "Controller", "m_CharacterControllerState", "ForceKeepPreviousParenting");
		


		return true;
	});

	vars.EndingCutscenes = 0;
	current.loadingScene = "";
}

onStart
{
	vars.CompletedSplits.Clear();
    vars.EndingCutscenes = 0;
}

start
{
	return current.LastChapterUnlocked == 10 && old.ForceKeepPreviousParenting == true && current.ForceKeepPreviousParenting == false;
}

update
{
	if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Loaded[0].Name))	current.loadingScene = vars.Helper.Scenes.Loaded[0].Name;
	if(current.loadingScene != old.loadingScene) vars.Log("loading: Old: \"" + old.loadingScene + "\", Current: \"" + current.loadingScene + "\"");

	if(old.LastChapterUnlocked != current.LastChapterUnlocked) vars.Log("LastChapterUnlocked: " + current.LastChapterUnlocked);
	if ((current.LastChapterUnlocked == 350 || current.loadingScene == "Chapter_4_Gameplay") 
        && old.SkipVideoIsEnabled == false && current.SkipVideoIsEnabled)
        {
            vars.EndingCutscenes++;
        } 
	if (old.ForceKeepPreviousParenting != current.ForceKeepPreviousParenting) vars.Log("ForceKeepPreviousParenting: " + current.ForceKeepPreviousParenting);
}

split
{
	if (old.LastChapterUnlocked != current.LastChapterUnlocked && settings[current.LastChapterUnlocked.ToString()] && !vars.CompletedSplits.Contains(current.LastChapterUnlocked.ToString()))
	{
		vars.CompletedSplits.Contains(current.LastChapterUnlocked.ToString());
		return true;
	}
	if ((current.loadingScene != "Chapter_4_Gameplay" || current.LastChapterUnlocked == 350) && vars.EndingCutscenes == 2 && settings["Ending"] && !vars.CompletedSplits.Contains("Ending"))
	{
		vars.CompletedSplits.Contains("Ending");
		return true;
	}	
}

isLoading
{
	return current.loadingScene != "MainMenu" && (current.ChapterScenesLoading == true || current.IsInGame == false);
}
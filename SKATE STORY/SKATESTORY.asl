state("SkateStory") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "SKATE STORY";
	vars.Helper.LoadSceneManager = true;
	vars.Helper.AlertLoadless();
}

init
{
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono => 
	{
		vars.Helper["currentScene"] = mono.MakeString("SkateSingleton", "main", "currentLevelScene", "locationName");
		// vars.Helper["ChapterScenesLoading"] = mono.Make<bool>("Home.MainManager", "Instance", "m_ChapterManager", "m_ChapterScenesLoading");
		// vars.Helper["LastChapterUnlocked"] = mono.Make<int>("Home.MainManager", "Instance", "m_ProgressionManager", "LastChapterUnlocked");
		// vars.Helper["SkipVideoIsEnabled"] = mono.Make<bool>("Home.MainManager", "Instance", "m_GUICamera", "m_SkipVideoIsEnabled");
		// vars.Helper["ForceKeepPreviousParenting"] = mono.Make<bool>("Home.MainManager", "Instance", "m_Player", "Controller", "m_CharacterControllerState", "ForceKeepPreviousParenting");
		return true;
	});
}

update
{
    if (old.currentScene != current.currentScene) vars.Log("Current Scene: " + current.currentScene);
}
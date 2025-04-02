state("BionicBay"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Bionic Bay";
	vars.Helper.LoadSceneManager = true;

	dynamic[,] _settings =
	{
		{ "TotalTime", true, "Total Time Tracker", null },
		{ "LevelTime", false, "Level Time Tracker - For IL Splitting", null},
		{ "Splits", true, "Splits", null },
			{ "Old_tree_Trailer", true, "Inception", "Splits" },
			{ "Swap", true, "Swap", "Splits" },
			{ "Beam", true, "Beam", "Splits" },
			{ "Automate", true, "Automate", "Splits" },
			{ "Incoherence", true, "Incoherence", "Splits" },
			{ "Substance", true, "Substance", "Splits" },
			{ "Surrogate", true, "Surrogate", "Splits" },
			{ "Fling", true, "Fling", "Splits" },
			{ "Delta", true, "Delta", "Splits" },
		{ "Autoreset", false, "Auto-Reset when going into Main Menu -> Options", null },
	};
	vars.Helper.Settings.Create(_settings);
	vars.Helper.AlertGameTime();
	vars.VisitedLevel = new List<string>();
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono => 
	{
		vars.Helper["LevelName"] = mono.MakeString("Psychoflow.GameManager", "s_Instance", "m_GameProgress", "m_SaveCache", "levelName");
		vars.Helper["TotalGameTime"] = mono.Make<float>("Psychoflow.GameManager", "s_Instance", "m_GameProgress", "m_SaveCache", "totalGameTime");
		vars.Helper["SceneName"] = mono.MakeString("Psychoflow.LevelMaker.LMManager", "currentSceneData", "sceneName");
		return true;
	});
	vars.StartOffset = 0f;
}

onStart
{
	timer.IsGameTimePaused = true;
	vars.VisitedLevel.Clear();
}

start
{
	return old.SceneName != "Inception" && current.SceneName == "Inception";
}

onStart
{
	vars.StartOffset = current.TotalGameTime;
}

update
{

}

split
{
	if (current.SceneName != old.SceneName && settings[old.SceneName]) return true;
}

isLoading
{
	return true;
}

gameTime
{
	return TimeSpan.FromSeconds(current.TotalGameTime - vars.StartOffset);
}

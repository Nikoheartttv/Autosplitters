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
			{ "Old_tree_Trailer", true, "Inception", "Splits" }, // main then outside
			{ "Swap", true, "Swap", "Splits" }, // single
			{ "Beam", true, "Beam", "Splits" }, // single
			{ "Automate", true, "Automate", "Splits" }, // single
			{ "Incoherence", true, "Incoherence", "Splits" }, // single
			{ "Huge Hand 2nd time", true, "Substance", "Splits" },
			{ "Surrogate", true, "Surrogate", "Splits" },
			{ "Fling", true, "Fling", "Splits" },
			{ "Delta", true, "Delta", "Splits" },
			{ "Apparatus", true, "Apparatus", "Splits" },
			{ "Turbulence", true, "Turbulence", "Splits" },
			{ "Projectiles", true, "Projectiles", "Splits" },
			{ "Gravitation", true, "Gravitation", "Splits" },
			{ "Nanoplanets", true, "Nanoplanets", "Splits" },
			{ "Liquid", true, "Liquid", "Splits" },
			{ "Vanguard", true, "Vanguard", "Splits" },
			{ "Cryostatic", true, "Cryostatic", "Splits" },
			{ "Rendezvous", true, "Rendezvous", "Splits" },
			{ "Superposition", true, "Superposition", "Splits" },
			{ "Magnetic", true, "Magnetic", "Splits" },
			{ "Polarity", true, "Polarity", "Splits" },
			{ "Vector", true, "Vector", "Splits" },
			{ "Monumental", true, "Vector", "Splits" },
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
		vars.Helper["activeCheckpoint"] = mono.Make<int>("Psychoflow.LevelMaker.LMManager", "currentSceneData", "activeCheckpoint");
		vars.Helper["Letterbox"] = mono.Make<float>("Psychoflow.Game.UI", "LetterboxingUI", "m_AspectRatioFitter", "m_AspectRatio");
		vars.Helper["Credits"] = mono.Make<float>("Psychoflow.Game.UI", "CreditUI", "m_Progress");
		return true;
	});
	vars.StartOffset = 0f;
	current.SceneName = "";
	current.activeCheckpoint = "";
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
	if (old.SceneName != current.SceneName) vars.Log("Scene Name: " + current.SceneName);
	if (old.activeCheckpoint != current.activeCheckpoint) vars.Log("Active Checkpoint: " + current.activeCheckpoint.ToString());
	if (old.Letterbox != current.Letterbox) vars.Log("Letterbox: " + current.Letterbox);
}

split
{
	if (!settings["Monumental"])
	{
		if (current.SceneName != old.SceneName && settings[old.SceneName] && !vars.VisitedLevel.Contains(old.SceneName)) 
		{
			vars.VisitedLevel.Add(old.SceneName);
			return true;
		}
	}
	if (settings["Monumental"] && current.SceneName == "Monumental" && current.activeCheckpoint == 26 && old.Credits == 0 && current.Credits != 0) 
	{
		vars.VisitedLevel.Add("Monumental");
		return true;
	}
}

isLoading
{
	return true;
}

gameTime
{
	return TimeSpan.FromSeconds(current.TotalGameTime - vars.StartOffset);
}

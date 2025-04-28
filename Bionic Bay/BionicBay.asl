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
			{ "End", true, "Vector", "Splits" },
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
		// vars.Helper["TotalGameTime"] = mono.Make<float>("Psychoflow.GameManager", "s_Instance", "m_GameProgress", "m_SaveCache", "totalGameTime");
		// vars.Helper["PlayerTime"] = mono.Make<float>("Psychoflow.GameTime", "PlayerTime");
		vars.Helper["StageInit"] = mono.Make<int>("Psychoflow.GameManager", "s_Stage");
		vars.Helper["SceneName"] = mono.MakeString("Psychoflow.LevelMaker.LMManager", "currentSceneData", "sceneName");
		vars.Helper["activeCheckpoint"] = mono.Make<int>("Psychoflow.LevelMaker.LMManager", "currentSceneData", "activeCheckpoint");
		vars.Helper["Credits"] = mono.Make<float>("Psychoflow.Game.UI", "CreditUI", "m_Progress");
		vars.Helper["CreditsCoroutine"] = mono.Make<int>("Psychoflow.Game.UI", "CreditUI", "m_CreditCoroutine", "m_Coroutine"); // PauseGame
		vars.Helper["IsSwapping"] = mono.Make<bool>("Psychoflow.Game.GameStatus", "IsSwapping"); // PauseGame
		vars.Helper["IsRestarting"] = mono.Make<bool>("Psychoflow.Game.GameStatus", "IsRestarting"); // PauseGame
		vars.Helper["IsInLevelTransition"] = mono.Make<bool>("Psychoflow.Game.GameStatus", "IsInLevelTransition"); // IsTitleSceneOrLoading()
		vars.Helper["VideoShouldPlay"] = mono.Make<bool>("Psychoflow.Game.UI", "VideoUI", "m_VideoShouldPlay"); // PauseGame
		vars.Helper["FadeStateCurrentTime"] = mono.Make<float>("Psychoflow.Game.UI", "FaderUI", "m_StateCurrentTime"); // PauseGame
		vars.Helper["DetailLeaderboard"] = mono.Make<int>("Psychoflow.Game.UI", "OnlineModeUIManager", "m_DetailLeaderBoard", "m_CurrentlyActiveFrom"); // ?????? PauseGame
		vars.Helper["IsOnlineModeStartWaiting"] = mono.Make<bool>("Psychoflow.Game.GameStatus", "IsOnlineModeStartWaiting");
		vars.Helper["IsPaused"] = mono.Make<bool>("Psychoflow.Game.GameStatus", "IsPaused");
		vars.Helper["LetterboxExist"] = mono.Make<bool>("Psychoflow.Game.UI", "LetterboxingUI", "m_AspectRatioFitter", "m_DoesParentExist");
		vars.Helper["LetterboxAspectRatio"] = mono.Make<float>("Psychoflow.Game.UI", "LetterboxingUI", "m_AspectRatioFitter", "m_AspectRatio");
		vars.Helper["CurrentTimeScale"] = mono.Make<float>("Psychoflow.GameManager", "s_Instance", "m_TimeScaleController", "m_CurrentTimeScale");
		vars.Helper["FadeState"] = mono.Make<int>("Psychoflow.Game.UI", "FaderUI", "CurrentState");
		vars.Helper["IsDead"] = mono.Make<bool>("Psychoflow.Game.Characters", "Hero", "m_Status", "DeathState", "IsDead");
		vars.Helper["HasStarted"] = mono.Make<bool>("Psychoflow.Game.Characters", "Hero", "m_Status", "HasStarted");

		return true;
	});
	vars.StartOffset = 0f;
	current.SceneName = "";
	current.activeCheckpoint = 0;
	vars.timeStoppedTicks = 0;
	vars.LevelTransitionToFade = false;
}

onStart
{
	timer.IsGameTimePaused = true;
	// vars.StartOffset = current.PlayerTime;
	vars.VisitedLevel.Clear();
}

start
{
	return old.SceneName != "Inception" && current.SceneName == "Inception";
}

update
{
	if (old.SceneName != current.SceneName) vars.Log("Scene Name: " + current.SceneName);
	if (old.activeCheckpoint != current.activeCheckpoint) vars.Log("Active Checkpoint: " + current.activeCheckpoint);
	if (old.IsPaused != current.IsPaused) vars.Log("IsPaused: " + current.IsPaused);
	if (old.IsSwapping != current.IsSwapping) vars.Log("IsSwapping: " + current.IsSwapping);
	if (old.IsInLevelTransition != current.IsInLevelTransition) vars.Log("IsInLevelTransition: " + current.IsInLevelTransition);
	if (current.IsInLevelTransition) vars.LevelTransitionToFade = true;
	if (vars.LevelTransitionToFade && !current.IsInLevelTransition && old.HasStarted == false && current.HasStarted == true) vars.LevelTransitionToFade = false;


	// if (old.IsDead != current.IsDead) vars.Log("Is Dead: " + current.IsDead);
	// if (old.HasStarted != current.HasStarted) vars.Log("HasStarted: " + current.HasStarted);

	// if (current.PlayerTime == old.PlayerTime) vars.timeStoppedTicks++;
	// else vars.timeStoppedTicks = 0;
}

split
{
	if (current.SceneName != old.SceneName && settings[old.SceneName] && !vars.VisitedLevel.Contains(old.SceneName)) 
	{
		vars.VisitedLevel.Add(old.SceneName);
		return true;
	}
	// if (settings["End"] && current.SceneName == "Monumental" && current.activeCheckpoint == 26 && old.Credits == 0 && current.Credits != 0) 
	// {
	// 	vars.VisitedLevel.Add("End");
	// 	return true;
	// }
	if (settings["End"] && current.SceneName == "Monumental" && current.activeCheckpoint == 26 && current.LetterboxExist && !current.IsPaused && current.CurrentTimeScale < 1.0)
	{
		vars.VisitedLevel.Add("End");
		return true;
	}
}

isLoading
{
	if ((current.SceneName == null || current.SceneName == "_Title_")
		|| current.StageInit != 9 
		|| current.IsPaused
		|| current.IsInLevelTransition
		|| current.CreditsCoroutine != 0
		|| current.IsRestarting
		|| vars.LevelTransitionToFade) return true;
		// || current.IsDead) return true;
	else return false;
	
	// if ((current.SceneName == null || current.SceneName == "_Title_")
	// 	|| current.IsSwapping 
	// 	|| current.IsRestarting 
	// 	|| current.VideoShouldPlay 
	// 	|| current.FadeStateCurrentTime != 0 
	// 	|| current.CreditsCoroutine != 0
	// 	|| current.IsOnlineModeStartWaiting
	// 	|| current.IsPaused
	// 	|| current.IsInLevelTransition
	// 	|| current.DetailLeaderboard != 0
	// 	|| current.CurrentTimeScale != 1.0) return true;
	// else return false;

	// more thoughts
	// if (fadeTime.HasValue)
	// 	LMManager.Instance.SwitchLevelInPlaymode(levelIdentifier, checkpoint, allowWorldTransitionAnimation, fadeTime.Value, onLoadFinish);
	// else
	// 	LMManager.Instance.SwitchLevelInPlaymode(levelIdentifier, checkpoint, allowWorldTransitionAnimation, onLoadFinish: onLoadFinish);??
}

// gameTime
// {
// 	return TimeSpan.FromSeconds(current.PlayerTime - vars.StartOffset);
// }

state("Habilis"){}

startup
{
	vars.Log = (Action<object>)(output => print("[Habilis] " + output));
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Habilis";
	vars.Helper.LoadSceneManager = true;

	dynamic[,] _settings =
	{
		{ "Splits", true, "Splits", null },
			{ "0", true, "Level 1", "Splits" },
			{ "1", true, "Level 2", "Splits" },
			{ "2", true, "Level 3", "Splits" },
			{ "3", true, "Level 4", "Splits" },
			{ "4", true, "Level 5", "Splits" },
			{ "5", true, "Level 6", "Splits" },
			{ "6", true, "Level 7 (End)", "Splits" },
	};

	vars.Helper.Settings.Create(_settings);
	vars.Helper.AlertLoadless();
	vars.VisitedLevel = new List<string>();
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
		var ASD = mono["Assembly-CSharp-firstpass", "AutoSplitData"];
		vars.Helper["gameStarted"] = mono.Make<bool>(ASD, "Instance", "gameStarted");
		vars.Helper["loading"] = mono.Make<bool>(ASD, "Instance", "isLoading");
		vars.Helper["finalText"] = mono.Make<bool>(ASD, "Instance", "finalText");
		vars.Helper["gameEnded"] = mono.Make<bool>(ASD, "Instance", "gameEnded");
		vars.Helper["levelIndex"] = mono.Make<int>(ASD, "Instance", "levelIndex");
		
		return true;
	});

	current.activeScene = "";
	current.loadingScene = "";
	current.levelIndex = -1;
}

start
{
	return current.gameStarted;
}

onStart
{
	vars.VisitedLevel.Clear();
}

update
{
	if(current.levelIndex != old.levelIndex) vars.Log("levelIndex: " + current.levelIndex);
}

split
{
	if (old.levelIndex != current.levelIndex && current.levelIndex == -1 && settings[old.levelIndex.ToString()] && !vars.VisitedLevel.Contains(old.levelIndex.ToString()))
	{
		vars.VisitedLevel.Add(old.levelIndex.ToString());
		return settings[old.levelIndex.ToString()];
	}
	if (current.levelIndex == 6 && current.finalText == true && settings[old.levelIndex.ToString()] && !vars.VisitedLevel.Contains(old.levelIndex.ToString()))
	{
		vars.VisitedLevel.Add(old.levelIndex.ToString());
		return true;
	}
}

isLoading
{
	return current.loading || current.activeScene == "loading";
}

reset
{
	return current.activeScene == "Habilis - Title Screen";
}

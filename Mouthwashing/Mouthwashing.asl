state("Mouthwashing"){}

startup
{
	vars.Log = (Action<object>)(output => print("[Mouthwashing] " + output));
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Mouthwashing";
	vars.Helper.LoadSceneManager = true;

	dynamic[,] _settings =
	{
		{ "Splits", true, "Splits", null },
			{ "Ch2 Scene", true, "Chapter 1", "Splits" },
			{ "Ch4 Scene", true, "Chapter 2", "Splits" },
			{ "Ch5 Scene", true, "Chapter 3", "Splits" },
			{ "Ch6 Scene", true, "Chapter 4", "Splits" },
			{ "Ch7 Scene", true, "Chapter 5", "Splits" },
			{ "Ch9 Scene", true, "Chapter 6", "Splits" },
			{ "Ch3 Scene", true, "Chapter 7", "Splits" },
			{ "Ch8 Scene", true, "Chapter 8", "Splits" },
			{ "Ch11 Scene", true, "Chapter 9", "Splits" },
			{ "Ch12 Scene", true, "Chapter 10", "Splits" },
			{ "Ch13 Scene", true, "Chapter 11", "Splits" },
			{ "Ch14 Scene", true, "Chapter 12", "Splits" },
			{ "Ch16 Scene", true, "Chapter 13", "Splits" },
			{ "Ch18 Scene", true, "Chapter 14", "Splits" },
			{ "Ch19 Scene", true, "Chapter 15", "Splits" },
			{ "Ch20 Scene", true, "Chapter 16", "Splits" },
			{ "Ch21 Scene", true, "Chapter 17", "Splits" },
			{ "BizCh1 Scene", true, "Chapter 18", "Splits" },
			{ "BizCh2 Scene", true, "Chapter 19", "Splits" },
			{ "BizCh3 Scene", true, "Chapter 20", "Splits" },
			{ "Ch22 Scene", true, "Chapter 21", "Splits" },
			{ "Ending", true, "Chapter 22", "Splits" },
	};

	vars.Helper.Settings.Create(_settings);
	vars.Helper.AlertLoadless();
	vars.VisitedLevel = new List<string>();
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
        	var GM = mono["GameManager"];
		var DF = mono["DatamoshFeature"];
		var C = mono["Credits"];
		vars.Helper["inSceneTransition"] = GM.Make<bool>("inSceneTransition");
		vars.Helper["datamoshIsPaused"] = DF.Make<bool>("isPaused");
		vars.Helper["CInstance"] = C.Make<IntPtr>("instance");
		
		return true;
	});

	current.activeScene = "";
	current.loadingScene = "";
	current.CInstancePrint = "0";
}

start
{
	return old.activeScene == "Start Menu Scene" && current.activeScene == "Ch1 Scene";
}

onStart
{
	vars.VisitedLevel.Clear();
}

update
{
	if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Active.Name))	current.activeScene = vars.Helper.Scenes.Active.Name;
	if(current.activeScene != old.activeScene) vars.Log("active: Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");
	if(current.CInstance != old.CInstance) vars.Log("CInstance - active: Old: \"" + old.CInstance + "\", Current: \"" + current.CInstance + "\"");
	if (old.CInstance != current.CInstance)
	{
		current.CInstancePrint = current.CInstance.ToString("X");
	}
}

split
{
	if (old.activeScene != current.activeScene && settings[current.activeScene.ToString()] && !vars.VisitedLevel.Contains(current.activeScene.ToString()))
	{
        	vars.VisitedLevel.Add(current.activeScene.ToString());
        	return settings[current.activeScene.ToString()];
    	}
	if (settings["Ending"] && current.activeScene == "Ch22 Scene" && old.CInstancePrint == "0" && current.CInstancePrint != "0")
	{
		return true;
	}
}

isLoading
{
	return current.inSceneTransition || current.datamoshIsPaused;
}

state("Autopsy Simulator"){}

startup
{
	vars.Log = (Action<object>)(output => print("[Autopsy Simulator] " + output));
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Autopsy Simulator";
	vars.Helper.LoadSceneManager = true;

	dynamic[,] _settings =
	{
		{ "Splits", true, "Splits (MANUAL FINAL SPLIT)", null },
			{ "ch01s01_Jacks_Apartment", true, "Prologue", "Splits" },
            { "ch02s01_Jacks_Apartment", true, "Chapter 1", "Splits" },
			{ "ch03s01_Jacks_Apartment", true, "Chapter 2", "Splits" },
			{ "ch05s02_Autopsy_Complex", true, "Chapter 3", "Splits" },
			{ "ch06s01_Autopsy_Complex", true, "Chapter 4", "Splits" },
	};
	
	vars.Helper.Settings.Create(_settings);
	vars.CompletedSplits = new HashSet<string>();
}

init
{
	current.activeScene = "";
}

update
{
    current.activeScene = vars.Helper.Scenes.Active.Name == null ? current.activeScene : vars.Helper.Scenes.Active.Name;
	if(current.activeScene != old.activeScene) vars.Log("active: Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");
}

onStart
{
	// This makes sure the timer always starts at 0.00
	timer.IsGameTimePaused = true;
	vars.CompletedSplits.Clear();
}
start
{
    return old.activeScene == "Base_Scene_MainMenu" && current.activeScene == "Base_Scene_Loading";
}

split
{
    if ((old.activeScene != current.activeScene) && settings.ContainsKey(current.activeScene) && !vars.CompletedSplits.Contains(current.activeScene))
            {
                vars.CompletedSplits.Add(current.activeScene);
                return true;
            }
}

isLoading
{
    return current.activeScene == "Base_Scene_Loading"
            || current.activeScene == "ch0s02_Autopsy_Complex"
            || current.activeScene == "ch0s03_Autopsy_Nightmare"
			|| current.activeScene == "ch01s01_Jacks_Apartment"
			|| current.activeScene == "ch01s02_Autopsy_Complex"
			|| current.activeScene == "ch01s03_Jacks_Apartment"
			|| current.activeScene == "ch02s01_Jacks_Apartment"
			|| current.activeScene == "ch02s02_Jacks_Apartment"
			|| current.activeScene == "ch02s03_Autopsy_Complex"
			|| current.activeScene == "ch02s04_Jacks_Apartment"
			|| current.activeScene == "ch03s01_Jacks_Apartment"
			|| current.activeScene == "ch03s02_Autopsy_Complex"
			|| current.activeScene == "ch05s02_Autopsy_Complex"
			|| current.activeScene == "ch0s04_Autopsy_Nightmare_2"
			|| current.activeScene == "ch06s01_Autopsy_Complex";
}
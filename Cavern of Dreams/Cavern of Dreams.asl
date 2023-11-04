state("Cavern of Dreams"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Cavern of Dreams";
	vars.Helper.LoadSceneManager = true;
	dynamic[,] _settings =
	{
		{ "Splits", true, "Splits", null },
			{ "SkillAttack", true, "Gain Tail Attack", "Splits" },
			{ "SkillHover", true, "Gain Hover", "Splits" },
			{ "SkillDive", true, "Gain Dive", "Splits" },
			{ "SkillProjectile", true, "Gain Projectile", "Splits" },
			{ "FlyUpLoop", true, "Ending Split - Fly Up Loop", "Splits" },
		{ "SaveQuitSplit", true, "TEMPORARY - Save and Quit Split", null },
	};
	vars.Helper.Settings.Create(_settings);
	vars.Helper.AlertGameTime();
}

init
{
	vars.Helper.TryLoad = (Func<dynamic, bool>)(mono => 
	{
		vars.Helper["cutsceneAnim"] = mono.MakeString("GlobalHub", "Instance", "cutsceneAnim");
        return true;
	});
}

start
{
	return current.activeScene == "Game";
}

update
{
	if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Active.Name))	current.activeScene = vars.Helper.Scenes.Active.Name;
	if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Loaded[0].Name))	current.loadingScene = vars.Helper.Scenes.Loaded[0].Name;

	if(current.activeScene != old.activeScene) vars.Log("active: Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");
	if(current.loadingScene != old.loadingScene) vars.Log("loading: Old: \"" + old.loadingScene + "\", Current: \"" + current.loadingScene + "\"");

	if (old.cutsceneAnim != current.cutsceneAnim) vars.Log("Cutscene change: " + current.cutsceneAnim.ToString());
}

split
{
	if (old.cutsceneAnim != current.cutsceneAnim && 
		(settings["SkillAttack"] && current.cutsceneAnim == "SkillAttack" || 
		settings["SkillHover"] && current.cutsceneAnim == "SkillHover" || 
		settings["SkillDive"] && current.cutsceneAnim == "SkillDive" || 
		settings["SkillProjectile"] && current.cutsceneAnim == "SkillProjectile")) return true;
	
	if (old.cutsceneAnim != current.cutsceneAnim && current.cutsceneAnim == "FlyUpLoop") return true;
	if (settings["SaveQuitSplit"] && old.activeScene == "Game" && current.activeScene == "MainMenu") return true;
}

isLoading
{
	if (current.activeScene == "MainMenu") return true;
	else return false;
}

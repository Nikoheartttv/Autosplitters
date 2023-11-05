state("Dexter Stardust"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "The Stanley Parable: Ultra Deluxe";
	vars.Helper.LoadSceneManager = true;
	vars.Helper.AlertLoadless();

	// Episode End Scene Names
	vars.Splits = new List<string>()
	{
		"Venus Triton End Scene",
		"Cutscene_VanguardAtVrees",
		"Cutscene_VanguardOnMars",
		"Triton Tree End Scene"
	};
	
	if (timer.CurrentTimingMethod == TimingMethod.RealTime)
	{
		var timingMessage = MessageBox.Show(
			"The game is run in RTA w/o Loads as the main timing method.\n"
			+ "LiveSplit is currently set to show Real Time (RTA).\n"
			+ "Would you like to set the timing method to RTA w/o Loads?",
			"LiveSplit | Dexter Stardust: Adventures in Outer Space", 
			MessageBoxButtons.YesNo, MessageBoxIcon.Question);
		if (timingMessage == DialogResult.Yes)
			timer.CurrentTimingMethod = TimingMethod.GameTime;
	}
}

onStart
{
	print("\nNew run started!\n----------------\n");
}

update
{
	if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Active.Name))	current.Scene = vars.Helper.Scenes.Active.Name;
    
	// Logging Scene Changes
	if (old.Scene != current.Scene) vars.Log("Old: \"" + old.Scene + "\", Current: \"" + current.Scene + "\"");
}

start
{
	return (current.Scene == "Cutscene_DexterTheme_Episode0" && old.Scene != "Cutscene_DexterTheme_Episode0");
}

split
{
	return (current.Scene != old.Scene && vars.Splits.Contains(old.Scene));
}

onSplit
{
	print("\nSplit\n-----\n");
}

isLoading
{
	return (current.Scene == "0 - Main Menu");
}

reset
{
	return (!vars.Splits.Contains(old.Scene) && old.Scene != "0 - Main Menu" && current.Scene == "0 - Main Menu");
}

onReset
{
	print("\nRESET\n-----\n");
}
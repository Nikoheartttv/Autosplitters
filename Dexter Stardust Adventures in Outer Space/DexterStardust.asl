state("Dexter Stardust"){}

startup
{
	vars.Log = (Action<object>)(value => print(String.Concat("[Dexter Stardust] ", value)));
	vars.Unity = Assembly.Load(File.ReadAllBytes(@"Components\UnityASL.bin")).CreateInstance("UnityASL.Unity");
	vars.Unity.LoadSceneManager = true;

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

init
{
	vars.Unity.Load(game);
}

update
{
	if (!vars.Unity.Loaded) return false;
	
	vars.Unity.Update();
	
	if (vars.Unity.Scenes.Active.Name != "")
	{
		current.Scene = vars.Unity.Scenes.Active.Name;
	}
    
	// Logging Scene Changes
	if (old.Scene != current.Scene) vars.Log(String.Concat("Scene Change: ", vars.Unity.Scenes.Active.Index.ToString(), ": ", current.Scene));
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

exit
{
    vars.Unity.Reset();
}

shutdown
{
	vars.Unity.Reset();
}

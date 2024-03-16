state("LiveSplit") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/emu-help-v2")).CreateInstance("PS1");

	vars.Helper.Load = (Func<dynamic, bool>)(emu => 
	{
		emu.Make<int>("Start", 0x801ff550);
 		emu.Make<int>("Map", 0x8005a345);
		emu.Make<int>("TournamentWon", 0x8005a31c);
		emu.Make<int>("LevelWin", 0x8005a320);

		return true;
	});
}

init
{
	vars.CarnivalMapLoaded = false;
}

start
{
	return old.Start == 6 && current.Start == 0;
}

update
{
	if (old.Map != current.Map && current.Map == 14)
	{
		vars.CarnivalMapLoaded = true;
	}
}

split
{
	if (current.Map != 14 && old.LevelWin == 0 && current.LevelWin == 1)
	{
		return true;
	}

	if (vars.CarnivalMapLoaded == true && old.TournamentWon == 0 && current.TournamentWon == 1)
	{
		return true;
	}
}

onReset
{
	vars.CarnivalMapLoaded = false;
}
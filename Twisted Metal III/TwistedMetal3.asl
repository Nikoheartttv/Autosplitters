state("LiveSplit") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/emu-help-v2")).CreateInstance("PS1");   
}

init
{
	vars.Helper.Load = (Func<dynamic, bool>)(emu => 
	{
		emu.Make<int>("TargetsLeft", 0x800d3234);
		emu.Make<int>("inGame", 0x800d2d40);
		emu.Make<int>("TournamentWon", 0x800d2d68);
		emu.Make<int>("LevelWin", 0x800d2d6c);
		emu.Make<int>("Map", 0x801fff10);

		return true;
	});
	vars.mapWinCondition = false;
}

start
{
	return old.inGame != current.inGame && current.inGame == 3;
}

update
{
	if(old.LevelWin == 0 && current.LevelWin == 1)
	{
		vars.mapWinCondition = true;
	}
}

split
{
	if (current.Map != 35 && vars.mapWinCondition == true && old.TargetsLeft == 1 && current.TargetsLeft == 0)
	{
		vars.mapWinCondition = false;
		return true;
	}

	if (current.Map == 35 && old.TournamentWon == 0 && current.TournamentWon == 1)
	{
		return true;
	}
}

onReset
{
	vars.mapWinCondition = false;
}
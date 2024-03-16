state("LiveSplit") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/emu-help-v2")).CreateInstance("PS1");
}

init
{
	vars.Helper.Load = (Func<dynamic, bool>)(emu => 
	{
		emu.Make<int>("Start", 0x8018EFD8);
		emu.Make<int>("MapNo", 0x8018ed04);
		emu.Make<int>("Win", 0x80197558);
		
		return true;
	});

	vars.RoofTopCombatWinCount = 0;
}

start
{
	return old.Start == 20 && current.Start == 10;
}

update
{
	if (current.MapNo == 6 && old.Win == 3 && current.Win == 0)
	{
		vars.RoofTopCombatWinCount++;
		print(vars.RoofTopCombatWinCount.ToString());
	}
}

split
{
	// Normal Splits
	if (current.MapNo != 6 && old.Win == 3 && current.Win == 0)
	{
		return true;
	}
	// Rooftop Combat Split
	if (current.MapNo == 6 && vars.RoofTopCombatWinCount == 2 && old.Win == 3 && current.Win == 0)
	{
		return true;
	}
}

onReset
{
	vars.RoofTopCombatWinCount = 0;
}
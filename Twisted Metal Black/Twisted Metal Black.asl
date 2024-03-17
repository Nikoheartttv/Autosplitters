state("LiveSplit") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/emu-help-v2")).CreateInstance("PS2");

	

	settings.Add("FullGame", true, "Run Type");
	settings.Add("IL", false, "Individual Level");
}

init
{
	vars.Helper.Load = (Func<dynamic, bool>)(emu => 
	{
		emu.Make<int>("Start", 0x425E20);
		emu.Make<int>("MenuScreen", 0x4FB144);
		emu.Make<int>("WinScreen", 0x4fbf08);
		emu.Make<int>("Enemies", 0x404360);
		emu.Make<int>("Loading", 0x4061A0);
		emu.Make<int>("MapNo", 0x40b900);
		emu.Make<int>("AfterBossTriggers", 0x504630);

		return true;
	});
	vars.AfterBossTriggersCount = 0;
}

start
{
	return current.MenuScreen != 0 && old.Start == 1 && current.Start == 0;
}

split
{
	if(settings["FullGame"])
	{
		if (current.MapNo != 14 && current.MapNo != 20)
		{
			return old.Loading == 1 && current.Loading == 9;
		}
		else if (current.MapNo == 14 && 
				((old.AfterBossTriggers == 11 || old.AfterBossTriggers == 13 || old.AfterBossTriggers == 18) 
				&& current.AfterBossTriggers == 32769))
			{
				return true;
			}
		else if (current.MapNo == 20 && old.Loading == 1 && current.Loading == 9)
			{
				return true;
			}
	}
	if(settings["IL"])
	{
		if(current.Enemies == 0 && old.WinScreen == 1 && current.WinScreen == 0)
		{
			return true;
		}
	}
}
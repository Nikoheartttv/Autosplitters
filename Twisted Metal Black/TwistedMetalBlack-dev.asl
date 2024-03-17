state("LiveSplit") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/emu-help-v2")).CreateInstance("PS2");

	vars.Helper.Load = (Func<dynamic, bool>)(emu => 
	{
        emu.Make<int>("MachineGunFiring", 0x259d7c);
        emu.Make<int>("Start", 0x425E20);
        // emu.Make<int>("Aftermatch", 0x4039a0);
        emu.Make<int>("WinScreen", 0x4fbf08);
        emu.Make<int>("Enemies", 0x404360);
        emu.Make<int>("Loading", 0x4061A0);
        emu.Make<int>("MapNo", 0x40b900);
        emu.Make<int>("AfterBossTriggers", 0x504630);
        // emu.Make<int>("LevelSelected", 0x40b900);
        // emu.Make<int>("LevelSelected2", 0x4fb29c);

		return true;
	});

    settings.Add("FullGame", true, "Run Type");
    settings.Add("IL", false, "Individual Level");
}

init
{
    vars.AfterBossTriggersCount = 0;
}

start
{
    return old.Start == 1 && current.Start == 0;
}

update
{
    // if (old.MachineGunFiring != current.MachineGunFiring) print(current.MachineGunFiring.ToString());
    // if (old.Aftermatch != current.Aftermatch) print("Aftermatch: " + current.Aftermatch.ToString());
    if (old.WinScreen != current.WinScreen) print("WinScreen: " + current.WinScreen.ToString());
    if (old.Enemies != current.Enemies) print("Enemies: " + current.Enemies.ToString());
    if (old.MapNo != current.MapNo) print("MapNo: " + current.MapNo.ToString());
    // if ((current.MapNo == 14 || current.MapNo == 20) && 
    // ((old.AfterBossTriggers == 11 || old.AfterBossTriggers == 13) & current.AfterBossTriggers == 32769))
    // {
    //     vars.AfterBossTriggersCount++;
    //     print(vars.AfterBossTriggersCount.ToString());
    // }

    // if (old.LevelSelected != current.LevelSelected) print("LevelSelected: " + current.LevelSelected.ToString());
    // if (old.LevelSelected2 != current.LevelSelected2) print("LevelSelected: " + current.LevelSelected2.ToString());
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
                    print("ye i printin dikhead");
                    return true;
                }
        else if (current.MapNo == 20 && old.Loading == 1 && current.Loading == 9)
                {
                    print("ye i printin dikhead twat fuck");
                    return true;
                }
    }
    if(settings["IL"])
    {
        if(current.Enemies == 0 && old.WinScreen == 1 && current.WinScreen == 0)
        {
            print("IL Split");
            return true;
        }
    }
}

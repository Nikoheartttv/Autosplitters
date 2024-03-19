state("LiveSplit") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/emu-help-v2")).CreateInstance("PS1");   
}

init
{
	vars.Helper.Load = (Func<dynamic, bool>)(emu => 
	{
		emu.MakeString("v1.0", 4, 0x80086A77);
		emu.MakeString("v1.1", 4, 0x8008689F);
		// Global
		emu.Make<int>("Map", 0x801FFF10);
		// v1.0
		emu.Make<int>("v1TargetsLeft", 0x800D340C);
		emu.Make<int>("v1inGame", 0x800D2F18);
		emu.Make<int>("v1TournamentWon", 0x800D2F40);
		emu.Make<int>("v1LevelWin", 0x800D2F44);
		emu.Make<int>("v1VehicleSelect", 0x80089C08);
		emu.Make<byte>("v1MenuScreens", 0x80089BE4);
		// v1.1
		emu.Make<int>("v11TargetsLeft", 0x800D3234);
		emu.Make<int>("v11inGame", 0x800D2D40);
		emu.Make<int>("v11TournamentWon", 0x800D2D68);
		emu.Make<int>("v11LevelWin", 0x800D2D6C);
		emu.Make<int>("v11VehicleSelect", 0x80089A30);
		// emu.Make<int>("v11InGameMenuSetting", 0x800D274C);
		emu.Make<byte>("v11MenuScreens", 0x80089A0C);

		return true;
	});
	vars.mapWinCondition = false;
	vars.VehicleSelect = false;
}

start
{
	if (vars.Helper["v1.0"].Current == "Sony" && current.v1MenuScreens == 220 && old.v1inGame != current.v1inGame && current.v1inGame == 3)
	{
		vars.VehicleSelect = false;
		return true;
	}
	else if (vars.Helper["v1.1"].Current == "Sony" && current.v11MenuScreens == 220 && old.v11inGame != current.v11inGame && current.v11inGame == 3)
	{
		vars.VehicleSelect = false;
		return true;
	}
}

update
{
	if (old.v11inGame != current.v11inGame) print("inGame: " + current.v11inGame.ToString());
	if (old.v11MenuScreens != current.v11MenuScreens) print("v11MenuScreens: " + current.v11MenuScreens.ToString());
	if (vars.Helper["v1.0"].Current == "Sony" && old.v1VehicleSelect == 0 && current.v1VehicleSelect == 1)
	{
		vars.VehicleSelect = true;
		print("VehicleSelect: " + vars.VehicleSelect.ToString());
	}
	else if (vars.Helper["v1.1"].Current == "Sony" & old.v11VehicleSelect == 0 && current.v11VehicleSelect == 1)
	{
		vars.VehicleSelect = true;
		print("VehicleSelect: " + vars.VehicleSelect.ToString());
	}

	if (vars.Helper["v1.0"].Current == "Sony")
	{
		if(old.v1LevelWin == 0 && current.v1LevelWin == 1)
		{
			vars.mapWinCondition = true;
		}
	}
	else if (vars.Helper["v1.1"].Current == "Sony")
	{
		if(old.v11LevelWin == 0 && current.v11LevelWin == 1)
		{
			vars.mapWinCondition = true;
		}
	}
}

split
{
	if (vars.Helper["v1.0"].Current == "Sony")
	{
		if (current.Map != 35 && vars.mapWinCondition == true && old.v1TargetsLeft == 1 && current.v1TargetsLeft == 0)
		{
			vars.mapWinCondition = false;
			return true;
		}
	}
	else if (vars.Helper["v1.1"].Current == "Sony")
	{
		if (current.Map != 35 && vars.mapWinCondition == true && old.v11TargetsLeft == 1 && current.v11TargetsLeft == 0)
		{
			vars.mapWinCondition = false;
			return true;
		}
	}

	if (vars.Helper["v1.0"].Current == "Sony")
	{
		if (current.Map == 35 && old.v1TournamentWon == 0 && current.v1TournamentWon == 1)
		{
			return true;
		}
	}
	else if (vars.Helper["v1.1"].Current == "Sony")
	{
		if (current.Map == 35 && old.v11TournamentWon == 0 && current.v11TournamentWon == 1)
		{
			return true;
		}
	}
}

onReset
{
	vars.mapWinCondition = false;
}
state("LiveSplit") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/emu-help-v2")).CreateInstance("PS2");

	vars.Helper.Load = (Func<dynamic, bool>)(emu => 
	{
		emu.Make<byte>("GameState", 0x5A7730);
		emu.Make<byte>("Enemies", 0xBE94B8);
        emu.Make<byte>("WinScreen", 0x2F4574);

		return true;
	});
}

init
{
	vars.EnemiesDefeated = false;
}

start
{
	return old.GameState == 3 && current.GameState == 0;
}

update
{
    if (old.GameState != current.GameState) print("GameState: " + current.GameState.ToString());
    if (old.Enemies != current.Enemies) print("Enemies: " + current.Enemies.ToString());
    if (old.WinScreen != current.WinScreen) print("WinScreen: " + current.WinScreen.ToString());
}

split
{
    if (current.GameState == 1 && old.Enemies != 0 && current.Enemies == 0)
    {
        vars.EnemiesDefeated = true;
    }
    if (current.GameState == 1 && vars.EnemiesDefeated == true && old.WinScreen == 0 && current.WinScreen == 1)
	{
		vars.EnemiesDefeated = false;
		return true;
	}
}

onReset
{
    vars.EnemiesDefeated = false;
}
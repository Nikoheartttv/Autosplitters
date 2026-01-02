state("Partizan"){}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "Partizan";
    vars.MissionComplete = new List<string>();

    dynamic[,] _settings =
	{
		{ "AutoReset", true, "Auto Reset", null },
		{ "FirstLevel", true, "First Level", null },
			{ "FindCalhoun", true, "Find Calhoun", "FirstLevel" },
			{ "SaveCalhoun", true, "Save Calhoun", "FirstLevel" },
	};
	vars.Helper.Settings.Create(_settings);
}

init
{
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
	{
        vars.Helper["missions"] = mono.Make<IntPtr>("World.Mission_System.MissionHandler", "missions");
        vars.Helper["timer"] = mono.Make<IntPtr>("World.Mission_System.GlobalMissionHandler", "data");
        vars.Helper["inGameMenu"] = mono.Make<int>("World.Global", "inGameMenu");
		return true;
	});

    current.time = 0;
    vars.inGame = false;
    current.inGameMenu = 0;
}

update
{
    current.time = vars.Helper.Read<float>(current.timer + 0x38);
    // if (old.time != current.time) vars.Log("time: " + current.time);
    vars.inGame = current.inGameMenu != 0;
}

onStart
{
    vars.MissionComplete.Clear();
}

start
{
    if (vars.inGame && old.time == 0 && current.time > 0 && current.time < 0.5) return true;
}

split
{
    int size = vars.Helper.Read<int>(current.missions + 0x10, 0x20, 0x30, 0x18);
    for (int i = 0; i < size; i++)
    {
        string name = vars.Helper.ReadString(current.missions + 0x10, 0x20, 0x30, 0x10, i * 0x8 + 0x20, 0x10);
        if (!string.IsNullOrEmpty(name) && !vars.MissionComplete.Contains(name))
        {
            vars.MissionComplete.Add(name);
            return true;
        }
    }
}

gameTime
{
    return TimeSpan.FromSeconds(current.time);
}

isLoading
{
    return true;
}

reset
{
    return settings["AutoReset"] && old.time != 0 && current.time == 0;
}
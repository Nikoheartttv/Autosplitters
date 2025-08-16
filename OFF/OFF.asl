state("OFF") { }

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "OFF";
    vars.Helper.AlertGameTime();

    dynamic[,] _settings =
	{
		{ "Splits", true, "Splits", null },
			{ "ZONE0", true, "ZONE0", "Splits" },
			{ "AlphaPartyMember", true, "Alpha - Party Member First Time", "Splits" },
		{ "IL", false, "IL Splitting", null }
	};

	vars.Helper.Settings.Create(_settings);
	vars.CompletedSplits = new List<string>();
}

init
{
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
    {
        vars.Helper["playTimeSeconds"] = mono.Make<float>("FangamerRPG.FPGOverworldMode", "instance", "gameState", "playTimeSeconds");
        vars.Helper["map"] = mono.MakeString("FangamerRPG.FPGOverworldMode", "instance", "gameState", "map");
        vars.Helper["partyMemberStates"] = mono.MakeList<IntPtr>("FangamerRPG.FPGOverworldMode", "instance", "gameState", "partyMemberStates");

        return true;
    });

    current.map = "";
    current.alphaActive = 0;
}

start
{
    return old.map == "menu" && current.map == "009 Introduction";
}

onStart
{
    vars.CompletedSplits.Clear();
}

update
{
    if (old.map != current.map) vars.Log("Map: " + current.map);

    // var partyList = vars.Helper["partyMemberStates"].Current;
    // if (partyList.Count > 2 && partyList[2] != IntPtr.Zero)
    // {
    //     current.alphaActive = vars.Helper.Read<byte>(partyList[2] + 0x6C);
    // }
    // else
    // {
    //     current.alphaActive = -1;
    // }
    // if (old.alphaActive != current.alphaActive) vars.Log("Alpha Active: " + current.alphaActive);
}

gameTime
{
    return TimeSpan.FromSeconds(current.playTimeSeconds);
}

split
{
    // ZONE0
    if (old.map == "008 zone 0 (sortie)" && current.map == "002 world map")
        {
            vars.CompletedSplits.Add("ZONE0");
            return settings["ZONE0"];
        }

    // Alpha
    if (current.map == "017 mine annexe" &&
        vars.Helper["partyMemberStates"].Current.Count > 2 &&
        vars.Helper["partyMemberStates"].Current[2] != IntPtr.Zero)
    {
        current.alphaActive = vars.Helper.Read<byte>(vars.Helper["partyMemberStates"].Current[2] + 0x6C);
        if (old.alphaActive == 0 && current.alphaActive == 1)
        {
            vars.CompletedSplits.Add("AlphaPartyMember");
            vars.Log("AlphaPartyMember Split");
            return settings["AlphaPartyMember"];
        }
    }
    // orrrrrrrrrrrrrrr
    // if (vars.Helper["partyMemberStates"].Current.Count > 2 &&
    //     vars.Helper["partyMemberStates"].Current[2] != IntPtr.Zero)
    // {
    //     current.alphaActive = vars.Helper.Read<byte>(vars.Helper["partyMemberStates"].Current[2] + 0x6C);
    //     if (current.alphaActive == 1 && old.map == "017 mine annexe" && current.map == "015 entrée de la mine")
    //     {
    //         vars.CompletedSplits.Add("AlphaPartyMember");
    //         vars.Log("AlphaPartyMember Split");
    //         return settings["AlphaPartyMember"];
    //     }
    // }


    // if (old.map != current.map && settings[current.map] && !vars.CompletedSplits.Contains(current.map))
    // {
    //         vars.CompletedSplits.Add(current.map);
    //         return true;
    // }
}

onReset
{
    vars.CompletedSplits.Clear();
}
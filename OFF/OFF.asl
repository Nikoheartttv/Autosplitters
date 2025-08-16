state("OFF") { }

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "OFF";
    vars.Helper.AlertGameTime();

    // Splits from NERS's OFF OG autosplitter
    dynamic[,] _settings =
	{
		{ "Splits", true, "Splits", null },
			{ "zone0", true, "Zone 0", "Splits" },
			// { "AlphaPartyMember", true, "Alpha - Party Member First Time", "Splits" }
            { "enter_mines", false, "Enter Mines", "Splits" },
            { "mines", false, "Mines", "Splits" },
            { "barn", false, "Barn", "Splits" },
            { "enter_postal_service", false, "Enter Postal Service", "Splits" },
            { "postal_service", false, "Postal Service", "Splits" },
            { "alma_first_half", false, "Alma First Half", "Splits" },
            { "alma_second_half", false, "Alma Second Half (Enter from the LEFT tile)", "Splits" },
            { "zone1", false, "Zone 1", "Splits" },
            { "card_puzzle", false, "Card Puzzle (exit from the LEFT tile)", "Splits" },
            { "valerie", false, "Valerie", "Splits" },
            { "zacharie_photo", false, "Open Zacharie's Photo", "Splits" },
            { "park", false, "Park", "Splits" },
            { "pure_zone1", false, "Pure Zone 1", "Splits" },
            { "sugar", false, "Sugar", "Splits" },
            { "residential" , false, "Residential", "Splits" },
            { "enter_japhet", false, "Enter Japhet", "Splits" },
            { "zone2", false, "Zone 2", "Splits" },
            { "area1", false, "Area 1", "Splits" },
            { "area2", false, "Area 2", "Splits" },
            { "area3", false, "Area 3", "Splits" },
            { "elsen_fight", false, "Elson Fight", "Splits" },
            { "area4", false, "Area 4", "Splits" },
            { "enoch", false, "Enoch", "Splits" },
            { "chapter5", false, "Chapter 5", "Splits" },
            { "chapter4", false, "Chapter 4", "Splits" },
            { "chapter3", false, "Chapter 3", "Splits" },
            { "exit_the_room", false, "Exit the Room", "Splits" },
            { "pure_zone2", false, "Pure Zone 2", "Splits" },
            { "pure_zone3", false, "Pure Zone 3", "Splits" },
            { "chapter2", false, "Chapter 2", "Splits" },
            { "chapter1", false, "Chapter 1", "Splits" },
            { "ending", false, "Ending", "Splits" }
	};

	vars.Helper.Settings.Create(_settings);
	vars.CompletedSplits = new List<string>();
}

init
{
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
    {
        vars.Helper["playTimeSeconds"] = mono.Make<float>("FangamerRPG.FPGOverworldMode", "instance", "gameState", "playTimeSeconds");
        vars.Helper["partyMemberStates"] = mono.MakeList<IntPtr>("FangamerRPG.FPGOverworldMode", "instance", "gameState", "partyMemberStates");

        vars.Helper["map"] = mono.MakeString("FangamerRPG.FPGOverworldMode", "instance", "gameState", "map");
        vars.Helper["mapID"] = mono.Make<int>("FangamerRPG.FPGOverworldMode", "instance", "m_mapComp", "mapID");
        vars.Helper["eventID"] = mono.Make<int>("FangamerRPG.FPGLogicManager", "instance", "_currentInterpreter", "_state", "owner", "eventID");
        vars.Helper["pageIndex"] = mono.Make<int>("FangamerRPG.FPGLogicManager", "instance", "_currentInterpreter", "_state", "pageIndex");
        vars.Helper["currentLine"] = mono.Make<int>("FangamerRPG.FPGLogicManager", "instance", "_currentInterpreter", "currentLine");
        
        vars.Helper["battleUnit"] = mono.MakeList<IntPtr>("OFFGame.Battle.BATMain", "instance", "_units");
        
        return true;
    });

    current.map = "";
    current.alphaActive = 0;
    vars.tempVar = 0;
    vars.lastUnitNames = new string[16]; // Always 16 slots
}

start
{
    // on map change
    // return old.map == "menu" && current.map == "009 Introduction";

    // Matching from NERS autosplitter from original OFF - starts the timer after name input
    if(current.map == "009 Introduction" && current.eventID == 1 && current.pageIndex == 1 && old.eventLine < 27 && current.eventLine >= 27)
    {
        print("[OFF] Timer automatically started");
        return true;
    }
}

reset
{
    // Revise
    return old.map != current.map && current.map == "preloader";
}

onStart
{
    vars.CompletedSplits.Clear();
}

update
{
    if (old.map != current.map) 
    {
        vars.Log("Map: " + current.map);
        if(old.mapID == 331 && current.mapID == 293 && vars.tempVar == 0) // Finished Chapter 3 (exited the inverted corridor)
            vars.tempVar = 1;
    }
    if (old.mapID != current.mapID) vars.Log("mapID: " + current.mapID);
    if (old.eventID != current.eventID) vars.Log("eventID: " + current.eventID);
    if (old.pageIndex != current.pageIndex) vars.Log("pageIndex: " + current.pageIndex);
    if (old.currentLine != current.currentLine) vars.Log("currentLine: " + current.currentLine);

    var unitList = vars.Helper["battleUnit"].Current;
    for (int i = 0; i < unitList.Count; i++)
    {
        var unitPtr = unitList[i];
        string unitName = null;

        if (unitPtr != IntPtr.Zero)
        {
            unitName = vars.Helper.ReadString(unitPtr + 0x20);
            if (string.IsNullOrWhiteSpace(unitName))
                unitName = null;
        }

        if (vars.lastUnitNames[i] != unitName)
        {
            if (unitName == null)
                vars.Log("[Battle] Slot " + i + " cleared (" + vars.lastUnitNames[i] + ")");
            else if (vars.lastUnitNames[i] == null)
                vars.Log("[Battle] Slot " + i + " filled with " + unitName);
            else
                vars.Log("[Battle] Slot " + i + ": " + vars.lastUnitNames[i] + " → " + unitName);

            vars.lastUnitNames[i] = unitName;
        }
    }

    // logging to see if Alpha is active in the party

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

// gameTime
// {
//     return TimeSpan.FromSeconds(current.playTimeSeconds);
// }

split
{
    // ZONE0
    if (old.map == "008 zone 0 (sortie)" && current.map == "002 world map")
        {
            vars.CompletedSplits.Add("zone0");
            return settings["zone0"];
        }

    // enter_mines
    if (old.map == "019 boyeau 1" && current.map == "020 boyeau 2")
        {
            vars.CompletedSplits.Add("enter_mines");
            return settings["enter_mines"];
        }

    // Alpha joins the party
    // if (current.map == "017 mine annexe" &&
    //     vars.Helper["partyMemberStates"].Current.Count > 2 &&
    //     vars.Helper["partyMemberStates"].Current[2] != IntPtr.Zero)
    // {
    //     current.alphaActive = vars.Helper.Read<byte>(vars.Helper["partyMemberStates"].Current[2] + 0x6C);
    //     if (old.alphaActive == 0 && current.alphaActive == 1)
    //     {
    //         vars.CompletedSplits.Add("AlphaPartyMember");
    //         vars.Log("AlphaPartyMember Split");
    //         return settings["AlphaPartyMember"];
    //     }
    // }
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
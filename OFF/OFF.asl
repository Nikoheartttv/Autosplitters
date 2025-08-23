state("OFF") {}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.GameName = "OFF";
    vars.Helper.LoadSceneManager = true;
    // vars.Helper.AlertGameTime();

    // Most splits are from NERS's OFF OG autosplitter
    dynamic[,] _settings =
    {
        { "Splits", true, "Splits", null },
            { "zone0", false, "Zone 0", "Splits" },
            { "alpha_party_member", false, "Obtain Add-On Alpha", "Splits" },
            { "enter_mines", false, "Enter Mines", "Splits" },
            { "mines", false, "Mines", "Splits" },
            { "barn", false, "Barn", "Splits" },
            { "enter_postal_service", false, "Enter Postal Service", "Splits" },
            { "postal_service", false, "Postal Service", "Splits" },
            { "alma_first_half", false, "Alma First Half", "Splits" },
            { "alma_second_half", false, "Alma Second Half", "Splits" },
            { "zone1", false, "Zone 1", "Splits" },
            { "card_puzzle", false, "Card Puzzle", "Splits" },
            { "valerie", false, "Valerie", "Splits" },
            { "zacharie_photo", false, "Open The Zacharie Rollercoaster Photo", "Splits" },
            { "park", false, "Park", "Splits" },
            { "pure_zone1", false, "Pure Zone 1", "Splits" },
            { "sugar", false, "Sugar", "Splits" },
            { "residential" , false, "Residential", "Splits" },
            { "enter_japhet", false, "Enter Japhet", "Splits" },
            { "zone2", false, "Zone 2", "Splits" },
            { "area1", false, "Area 1", "Splits" },
            { "area2", false, "Area 2", "Splits" },
            { "area3", false, "Area 3", "Splits" },
            { "elsen_fight", false, "Elsen Fight", "Splits" },
            { "area4", false, "Area 4", "Splits" },
            { "enoch", false, "Enoch", "Splits" },
            { "chapter5", false, "Chapter 5", "Splits" },
            { "chapter4", false, "Chapter 4", "Splits" },
            { "chapter3", false, "Chapter 3", "Splits" },
            { "exit_the_room", false, "Exit The Room", "Splits" },
            { "pure_zone2", false, "Pure Zone 2", "Splits" },
            { "pure_zone3", false, "Pure Zone 3", "Splits" },
            { "chapter2", false, "Chapter 2", "Splits" },
            { "chapter1", false, "Chapter 1", "Splits" },
            { "new_boss1", false, "Source", "Splits" },
            { "new_boss2", false, "Maldicion", "Splits" },
            { "new_boss3", false, "Psalmanazar & Herodotus", "Splits" },
            { "new_boss4", false, "Justus", "Splits" },
            { "new_boss5", false, "Carnival", "Splits" },
            { "new_boss6", false, "Cob", "Splits" },
            { "final_fight", false, "Final Fight (Adversaries purified)", "Splits" },
            { "ending_switch", false, "Batter Ending (Turning the switch off)", "Splits" }
    };
    vars.Helper.Settings.Create(_settings);
    settings.SetToolTip("zacharie_photo", "This autosplit only triggers in the room you got the photo from.");

    vars.splits = new Dictionary<string, Func<dynamic, dynamic, bool>>()
    {
        // org = original (equivalent to old), cur = current (can't use the same names)
        {"zone0",                (org, cur) => cur.mapID == 8 && cur.eventID == 1 && cur.pageIndex == 1 && org.currentLine < 12 && cur.currentLine >= 12},
        {"enter_mines",          (org, cur) => org.mapID == 19 && cur.mapID == 20},
        {"mines",                (org, cur) => org.mapID == 23 && cur.mapID == 25},
        {"alpha_party_member",   (org, cur) => cur.mapID == 17 && cur.eventID == 11 && cur.pageIndex == 1 && org.currentLine < 10 && cur.currentLine >= 10 /* or org.alphaActive <= 0 && cur.alphaActive > 0 */},
        {"barn",                 (org, cur) => org.mapID == 28 && cur.mapID == 27},
        {"enter_postal_service", (org, cur) => cur.mapID == 34 && cur.eventID == 4 && cur.pageIndex == 1 && org.currentLine < 38 && cur.currentLine == 38},
        {"postal_service",       (org, cur) => org.mapID == 46 && cur.mapID == 47},
        {"alma_first_half",      (org, cur) => org.mapID == 56 && cur.mapID == 57},
        {"alma_second_half",     (org, cur) => cur.mapID == 68 && (cur.eventID == 3 || cur.eventID == 4) && cur.pageIndex == 1 && org.currentLine < 4 && cur.currentLine == 4},
        {"zone1",                (org, cur) => org.mapID == 69 && cur.mapID == 70},
        {"card_puzzle",          (org, cur) => org.mapID == 114 && cur.mapID == 112 /* && cur.eventID == 167 && cur.pageIndex == 1 for the left tile only */},
        {"valerie",              (org, cur) => org.mapID == 117 && cur.mapID == 116},
        {"zacharie_photo",       (org, cur) => cur.mapID == 142 && !org.zachariePhoto && cur.zachariePhoto},
        {"park",                 (org, cur) => org.mapID == 136 && cur.mapID == 134},
        {"pure_zone1",           (org, cur) => cur.mapID == 101 && cur.eventID == 1 && cur.pageIndex == 1 && org.currentLine < 10 && cur.currentLine >= 10},
        {"sugar",                (org, cur) => org.mapID == 152 && cur.mapID == 151},
        {"residential",          (org, cur) => org.mapID == 145 && cur.mapID == 115},
        {"enter_japhet",         (org, cur) => cur.mapID == 162 && !org.inBattle && cur.inBattle},
        {"zone2",                (org, cur) => org.mapID == 162 && cur.mapID == 70},
        {"area1",                (org, cur) => cur.mapID == 205 && (cur.eventID == 5 || cur.eventID == 6) && cur.pageIndex == 1 && org.currentLine < 3 && cur.currentLine == 3},
        {"area2",                (org, cur) => cur.mapID == 212 && (cur.eventID == 5 || cur.eventID == 6) && cur.pageIndex == 1 && org.currentLine < 13 && cur.currentLine == 13},
        {"area3",                (org, cur) => cur.mapID == 214 && (cur.eventID == 3 || cur.eventID == 5) && cur.pageIndex == 4 && org.currentLine < 4 && cur.currentLine == 4},
        {"elsen_fight",          (org, cur) => org.mapID == 234 && cur.mapID == 213},
        {"area4",                (org, cur) => org.mapID == 235 && cur.mapID == 213},
        {"enoch",                (org, cur) => org.mapID == 213 && cur.mapID == 2},
        {"chapter5",             (org, cur) => cur.mapID == 293 && cur.eventID == 6 && cur.pageIndex == 3 && org.currentLine < 1 && cur.currentLine >= 1},
        {"chapter4",             (org, cur) => cur.mapID == 293 && cur.eventID == 6 && org.pageIndex != 5 && cur.pageIndex == 5},
        {"chapter3",             (org, cur) => cur.mapID == 293 && cur.eventID == 6 && cur.pageIndex == 7 && org.currentLine < 1 && cur.currentLine >= 1},
        {"exit_the_room",        (org, cur) => cur.mapID == 293 && cur.eventID == 1 && cur.pageIndex == 1 && org.currentLine < 10 && cur.currentLine >= 10},
        {"pure_zone2",           (org, cur) => cur.mapID == 197 && cur.eventID == 1 && cur.pageIndex == 1 && org.currentLine < 10 && cur.currentLine >= 10},
        {"pure_zone3",           (org, cur) => cur.mapID == 292 && cur.eventID == 1 && cur.pageIndex == 1 && org.currentLine < 10 && cur.currentLine >= 10},
        {"chapter2",             (org, cur) => cur.mapID == 293 && cur.eventID == 6 && cur.pageIndex == 9 && org.currentLine < 6 && cur.currentLine >= 6},
        {"chapter1",             (org, cur) => cur.mapID == 340 && cur.eventID == 1 && cur.pageIndex == 1 && org.currentLine != 0 && cur.currentLine >= 0},
        {"new_boss1",            (org, cur) => cur.mapID == 356 && cur.scene != "gameover" && org.inBattle && !cur.inBattle},
        {"new_boss2",            (org, cur) => cur.mapID == 361 && cur.scene != "gameover" && org.inBattle && !cur.inBattle},
        {"new_boss3",            (org, cur) => cur.mapID == 357 && cur.scene != "gameover" && org.inBattle && !cur.inBattle},
        {"new_boss4",            (org, cur) => cur.mapID == 355 && cur.scene != "gameover" && org.inBattle && !cur.inBattle},
        {"new_boss5",            (org, cur) => cur.mapID == 359 && cur.scene != "gameover" && org.inBattle && !cur.inBattle},
        {"new_boss6",            (org, cur) => cur.mapID == 360 && cur.scene != "gameover" && org.inBattle && !cur.inBattle},
        {"final_fight",          (org, cur) => cur.mapID == 347 && vars.lastUnitNames[0] == null && !org.battleEnded && cur.battleEnded},
        {"ending_switch",        (org, cur) => cur.mapID == 347 && cur.eventID == 1 && cur.pageIndex == 1 && org.currentLine < 6 && cur.currentLine >= 6}
    };
    vars.CompletedSplits = new List<string>();
}

init
{
    vars.BATMainInit = false; // OFFGame.Battle.BATMain is not initialized until you start a battle

    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
    {
        vars.Mono = mono;
        vars.AsmCs = mono.Images["Assembly-CSharp"];

        // vars.Helper["playTimeSeconds"] = mono.Make<float>("FangamerRPG.FPGOverworldMode", "instance", "gameState", "playTimeSeconds");
        // vars.Helper["partyMemberStates"] = mono.MakeList<IntPtr>("FangamerRPG.FPGOverworldMode", "instance", "gameState", "partyMemberStates");

        // vars.Helper["map"] = mono.MakeString("FangamerRPG.FPGOverworldMode", "instance", "gameState", "map");
        vars.Helper["mapID"] = mono.Make<int>("FangamerRPG.FPGOverworldMode", "instance", "m_mapComp", "mapID");
        vars.Helper["eventID"] = mono.Make<int>("FangamerRPG.FPGLogicManager", "instance", "_currentInterpreter", "_state", "owner", "eventID");
        vars.Helper["pageIndex"] = mono.Make<int>("FangamerRPG.FPGLogicManager", "instance", "_currentInterpreter", "_state", "pageIndex");
        vars.Helper["currentLine"] = mono.Make<int>("FangamerRPG.FPGLogicManager", "instance", "_currentInterpreter", "currentLine");

        vars.Helper["inBattle"] = mono.Make<bool>("FangamerRPG.FPGOverworldMode", "instance", "battleManager", "inBattle");
        vars.Helper["zachariePhoto"] = mono.Make<bool>("FangamerRPG.FPGOverworldMode", "instance", "gameState", "switches", 0x18, 0x66C);
        return true;
    });

    // current.alphaActive = 0;
    vars.lastUnitNames = new string[16]; // Always 16 slots
}

start
{
    // Matching from NERS's autosplitter for the original OFF - starts the timer after name input
    if (current.mapID == 9 && current.eventID == 1 && current.pageIndex == 1 && old.currentLine < 28 && current.currentLine >= 28)
    {
        vars.Log("Timer automatically started");
        return true;
    }
}

reset
{
    if (current.mapID == 9 && current.eventID == 1 && current.pageIndex == 1 && old.currentLine < 3 && current.currentLine >= 3)
    {
        vars.Log("Timer automatically reset");
        return true;
    }
}

onStart
{
    vars.CompletedSplits.Clear();
}

onReset
{
    vars.CompletedSplits.Clear();
}

update
{
    current.scene = vars.Helper.Scenes.Active.Name ?? old.scene;
    if (old.scene != current.scene) vars.Log("scene: " + old.scene + " -> " + current.scene);

    // if (old.map != current.map) vars.Log("map: " + old.map + " -> " + current.map);
    if (old.mapID != current.mapID) vars.Log("mapID: " + old.mapID + " -> " + current.mapID);
    if (old.eventID != current.eventID) vars.Log("eventID: " + old.eventID + " -> " + current.eventID);
    if (old.pageIndex != current.pageIndex) vars.Log("pageIndex: " + old.pageIndex + " -> " + current.pageIndex);
    if (old.currentLine != current.currentLine) vars.Log("currentLine: " + old.currentLine + " -> " + current.currentLine);

    /*
    // Logging to see if Alpha is active in the party
    var partyList = vars.Helper["partyMemberStates"].Current;
    if (partyList.Count > 2 && partyList[2] != IntPtr.Zero)
    {
        current.alphaActive = vars.Helper.Read<byte>(partyList[2] + 0x6C);
    }
    else
    {
        current.alphaActive = -1;
    }
    if (old.alphaActive != current.alphaActive) vars.Log("alphaActive: " + old.alphaActive + " -> " + current.alphaActive);
    */

    if (current.inBattle)
    {
        if (!vars.BATMainInit)
        {
            vars.AsmCs.Clear();
            if (vars.AsmCs["OFFGame.Battle.BATMain"].Static != IntPtr.Zero)
            {
                vars.BATMainInit = true;
                vars.Helper["battleUnit"] = vars.Mono.MakeList<IntPtr>("OFFGame.Battle.BATMain", "instance", "_units");
                vars.Helper["battleEnded"] = vars.Mono.Make<bool>("OFFGame.Battle.BATMain", "instance", "youWon", 0x10, 0x47); // ADVERSARIES PURIFIED / PURIFICATION FAILED
            }
        }
        else
        {
            for (int i = 0; i < current.battleUnit.Count; i++)
            {
                var unitPtr = current.battleUnit[i];
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
                        vars.Log("[Battle] Slot " + i + ": " + vars.lastUnitNames[i] + " -> " + unitName);
       
                    vars.lastUnitNames[i] = unitName;
                }
            }
        }
    }
}

split
{
    foreach (var split in vars.splits)
    {
        if (!settings[split.Key] || 
           vars.CompletedSplits.Contains(split.Key) ||
           !split.Value(old, current)) continue;

        vars.CompletedSplits.Add(split.Key);
        vars.Log("Split triggered (" + split.Key + ")");
        return true;
    }
}

/*
gameTime
{
    return TimeSpan.FromSeconds(current.playTimeSeconds);
}
*/
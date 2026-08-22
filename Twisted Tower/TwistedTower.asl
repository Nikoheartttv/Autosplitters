state("Twisted Tower") {}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main");
    vars.Uhara.AlertLoadless();

    dynamic[,] _settings =
    {
        { "Enter-Floor0", true, "Enter Lobby", null },
        { "Enter-Floor1b", true, "Enter Hotel", null },
        { "HotelDone", true, "Return to Lobby after getting Hotel Twisted Token", null },
        { "Enter-Floor-1", true, "Enter Mermaid Palace", null },
        { "MermaidPalaceDone", true, "Return to Lobby after getting Mermaid Palace Twisted Token", null },
        { "Enter-Floor3b", true, "Enter Clown Casino", null },
        { "CasinoDone", true, "Return to Lobby after getting Clown Casino Twisted Token", null },
        { "Enter-Exterior2", false, "Enter Fairground Forest (from normal Courtyard)", null },
        { "FairgroundForestDone", true, "Leave Fairground Forest into Courtyard with Twisted Token", null },
        { "Enter-Floor5b-New", true, "Enter Lightspeed Land", null },
        { "Enter-Floor7", true, "Enter Charlotte's Castle", null },
        { "Enter-Floor8", true, "Enter Tower Top", null },
        { "BossEnd", true, "Mr. Twister Final Balloon Destroyed (End)", null },
    };

    vars.Uhara.Settings.Create(_settings);
    vars.CompletedSplits = new HashSet<string>();
    vars.HeldKeys = new HashSet<string>();
}

init
{
    vars.Utils = vars.Uhara.CreateTool("Unity", "Utils");
    vars.Instance = vars.Uhara.CreateTool("Unity", "IL2CPP", "Instance");

    // GameManager.PlayerStatistics.playerOptions[struct] (0x320)
    var playerStatsInv = vars.Instance.Get("com.atmosgames.atmosengine:AtmosEngine.Managers:GameManager", "PlayerStatistics", "0x320");
    vars.Resolver.Watch<IntPtr>("KeysArrayPtr", playerStatsInv.Base, playerStatsInv.Offsets);

    // BossController
    vars.Instance.Watch<int>("bossBalloonsDestroyed", "com.atmosgames.atmosengine::BossController", "balloonsDestroyed");
    vars.Instance.Watch<bool>("bossDead", "com.atmosgames.atmosengine::BossController", "dead");

    // Load Removal
    vars.Instance.Watch<bool>("awaitingSceneLoad", "com.atmosgames.atmosengine:AtmosEngine.Managers:GameManager", "instance", "awaitingSceneLoad");

    current.ActiveScene = "";
    current.LoadingScene = "";
    current.BlackOverlayAlpha = 0.0f;
    current.SceneName = "";
    vars.LastHeldKeysCount = 0;
}

onStart
{
    vars.HeldKeys.Clear();
    vars.CompletedSplits.Clear();
    timer.IsGameTimePaused = true;
}

start
{
    return old.ActiveScene != "Exterior" && current.ActiveScene == "Exterior";
}

update
{
    vars.Uhara.Update();

    if (!String.IsNullOrWhiteSpace(vars.Utils.GetActiveSceneName())) current.ActiveScene = vars.Utils.GetActiveSceneName();
    if (!String.IsNullOrWhiteSpace(vars.Utils.GetLoadingSceneName())) current.LoadingScene = vars.Utils.GetLoadingSceneName();
    if (old.ActiveScene != current.ActiveScene) vars.Uhara.Log("Active Scene: " + old.ActiveScene + " -> " + current.ActiveScene);

    IntPtr arrPtr = current.KeysArrayPtr;
    if (arrPtr != IntPtr.Zero && current.ActiveScene != "Menu")
    {
        int count = vars.Resolver.Read<int>(arrPtr + 0x18);
        for (int i = 0; i < count; i++)
        {
            IntPtr strPtr = vars.Resolver.Read<IntPtr>(arrPtr + (0x20 + (i * 0x8)));
            if (strPtr == IntPtr.Zero) continue;
            string s = vars.Resolver.ReadString(strPtr + 0x14);
            if (!String.IsNullOrWhiteSpace(s))
            {
                vars.HeldKeys.Add(s);
            }
        }
    }

    if (vars.HeldKeys.Count > vars.LastHeldKeysCount)
    {
        string addedItems = String.Join(", ", vars.HeldKeys);
        // vars.Uhara.Log("Held Keys (" + vars.HeldKeys.Count + "): " + addedItems);
        vars.LastHeldKeysCount = vars.HeldKeys.Count;
    }
}

split
{
    if (vars.HeldKeys.Contains("Medallion 1") && old.ActiveScene == "Floor1" && current.ActiveScene == "Floor0" && 
        settings["HotelDone"] && !vars.CompletedSplits.Contains("HotelDone"))
    {
        vars.CompletedSplits.Add("HotelDone");
        return true;
    }

    if (vars.HeldKeys.Contains("Medallion 2") && old.ActiveScene == "Floor-2" && current.ActiveScene == "Floor0" &&
        settings["MermaidPalaceDone"] && !vars.CompletedSplits.Contains("MermaidPalaceDone"))
    {
        vars.CompletedSplits.Add("MermaidPalaceDone");
        return true;
    }

    if (vars.HeldKeys.Contains("Medallion 3") && old.ActiveScene == "Floor3" && current.ActiveScene == "Floor0" &&
        settings["CasinoDone"] && !vars.CompletedSplits.Contains("CasinoDone"))
    {
        vars.CompletedSplits.Add("CasinoDone");
        return true;
    }

    if (vars.HeldKeys.Contains("Medallion 4") && old.ActiveScene == "Exterior3" && current.ActiveScene == "Exterior" &&
        settings["FairgroundForestDone"] && !vars.CompletedSplits.Contains("FairgroundForestDone"))
    {
        vars.CompletedSplits.Add("FairgroundForestDone");
        return true;
    }

    if (current.ActiveScene == "Floor8" && current.bossBalloonsDestroyed == 12 && current.bossDead && 
        settings["BossEnd"] && !vars.CompletedSplits.Contains("BossEnd"))
    {
        vars.CompletedSplits.Add("BossEnd");
        return true;
    }

    if (old.ActiveScene != current.ActiveScene && settings.ContainsKey("Enter-" + current.ActiveScene) && settings["Enter-" + current.ActiveScene] && !vars.CompletedSplits.Contains(current.ActiveScene))
    {
        vars.CompletedSplits.Add(current.ActiveScene);
        return true;
    }
}

isLoading
{
    return current.awaitingSceneLoad || current.ActiveScene == "Warning" || current.ActiveScene == "Splash Screen";
}

onReset
{
    vars.HeldKeys.Clear();
    vars.CompletedSplits.Clear();
}

exit
{
    timer.IsGameTimePaused = true;
}
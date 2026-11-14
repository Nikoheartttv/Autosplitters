state("Carpenter") {}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main");
    vars.Uhara.AlertGameTime();

    vars.CompletedSplits = new HashSet<string>();
    vars.PendingSplits = new List<string>();
    vars.ItemNames = new List<string>();
    vars.ItemCounts = new List<int>();
    vars.PrevStashEntries = new List<IntPtr>();
    vars.SheriffSeen = false;
    vars.TotalTime = 0.0f;
    vars.LastPlaytime = 0.0f;

    // Used for boss-scene detection and deriving the current boss split key.
    vars.BossScenes = new Dictionary<string, string>
    {
        { "Sheriff_Lobby", "Boss_Sheriff" },
        { "Apartment_Boss", "Boss_Apartment" },
        { "Nightmare_Church_Chapel", "Boss_Church" },
        { "Park_Townhall_Assembly_Hall", "Boss_Pursuer" },
        { "Downtown_Market_St_Alley_Sewer", "Boss_Fogshambler" },
        { "Studio_Stage", "Boss_Pursuer2" },
        { "Nightmare_Studio_Logic", "Boss_Madam" }
    };

    dynamic[,] _settings =
    {
        { "AutoReset", false, "Auto Reset when entering Main Menu", null },
        { "Splits", true, "Splits", null },
            { "Key_Outskirts_Checkin", true, "Crimson Bear Motel Check-in Key", "Splits" },
            { "Misc_Fuses_40A_1", true, "Electrical Fuse (40A) 1", "Splits" },
            { "Key_Motel_Alley", false, "Poolside Key", "Splits" },
            { "Key_Card_Grizzly_Suite", true, "Grizzly Suite Keycard", "Splits" },
            { "Misc_Motel_Door_Knob_Grime", true, "Grime Covered Object (Doorknob)", "Splits" },
            { "RabbitHoleCutscene", true, "Rabbit Hole Cutscene", "Splits" },
            { "Boss_Mantis", true, "Defeat Tunnel Boss", "Splits" },
            { "Key_Downtown_Alley", true, "Riverside Bridge Key", "Splits" },
            { "Key_Riverside_Path", false, "Riverside Junkyard Gate Key", "Splits" },
            { "Tool_Flashlight", true, "Flashlight", "Splits" },
            { "Melee_Crowbar", true, "Crowbar", "Splits" },
            { "Boss_Sheriff", true, "Defeat Deputy Roberts", "Splits" },
            { "Misc_Station_Bell_A", true, "Cable Station Bell (A)", "Splits" },
            { "Misc_Apartment_Stairwell_Key", false, "Union Level 3 Key", "Splits" },
            { "misc_terpentine", false, "Paint Solvent", "Splits" },
            { "Misc_Elevator_Button", true, "Elevator 4A Button", "Splits" },
            { "Key_Apartment_4B", true, "Apartment 4B Key", "Splits" },
            { "Boss_Apartment", true, "Defeat the Union Apartment Boss", "Splits" },
            { "Misc_Station_Bell_D", true, "Cable Station Bell (D)", "Splits" },
            { "Artifact_FasterSprint_Compass", true, "Damaged Compass Memento", "Splits" },
            { "Key_Church_Flower", true, "Flower Shop Key", "Splits" },
            { "Key_Church_Hill_Crematorium", true, "Funeral Home Key", "Splits" },
            { "Key_Church_Cemetary", false, "Cemetery Key", "Splits" },
            { "Misc_Parish_Cube_1", true, "Metal Cube 1", "Splits" },
            { "Melee_Sledgehammer", true, "Sledgehammer", "Splits" },
            { "Misc_Church_Lever", true, "Crank Handle", "Splits" },
            { "Misc_Parish_Cube_2", true, "Metal Cube 2", "Splits" },
            { "Misc_Parish_Cube_3", true, "Metal Cube 3", "Splits" },
            { "Boss_Church", true, "Defeat the Church Boss", "Splits" },
            { "Misc_Station_Bell_B", true, "Cable Station Bell (B)", "Splits" },
            { "Misc_Park_Tong", true, "Fireplace Tongs", "Splits" },
            { "Key_Park_Townhall_Office", false, "Townhall Office Key", "Splits" },
            { "Misc_Park_Mold", true, "Mask Mold", "Splits" },
            { "Misc_Park_Mask2", true, "Blissful Mask", "Splits" },
            { "Misc_Plaster", false, "Unmixed Clay", "Splits" },
            { "Misc_Manhole_Cover_Key", true, "Manhole Cover Key", "Splits" },
            { "Misc_Park_Mask1", true, "Weeping Mask", "Splits" },
            { "Misc_Park_Mask4", true, "Malformed Mask", "Splits" },
            { "Boss_Pursuer", true, "Defeat the Town Hall Boss", "Splits" },
            { "Misc_Station_Bell_F", true, "Cable Station Bell (F)", "Splits" },
            { "Misc_Cog_Medium", true, "Heavy Mechanical Cog", "Splits" },
            { "Sewer_Flow_A", true, "Sluice Gate Flow A", "Splits" },
            { "Sewer_Flow_B", true, "Sluice Gate Flow B", "Splits" },
            { "Sewer_Flow_C", true, "Sluice Gate Flow C", "Splits" },
            { "Boss_Fogshambler", true, "Defeat the Sewers Boss", "Splits" },
            { "Misc_Station_Bell_E", true, "Cable Station Bell (E)", "Splits" },
            { "CableCar_Mountain", true, "Cable Car Arrived On Mountain", "Splits" },
            { "Misc_Fuses_40A_2", true, "Electrical Fuse (40A) 2", "Splits" },
            { "Misc_Fuses_40A_3", true, "Electrical Fuse (40A) 3", "Splits" },
            { "Key_Studio_Backdoor", true, "Backdoor Key", "Splits" },
            { "Misc_Studio_Lens_Cyan", true, "Cyan Lens", "Splits" },
            { "Key_Studio_Staff", false, "Stage 1 Key", "Splits" },
            { "Misc_Studio_Lens_Magenta", true, "Magenta Lens", "Splits" },
            { "Key_Studio_Tower", true, "Tower Key", "Splits" },
            { "Misc_Studio_Lens_Yellow", true, "Yellow Lens", "Splits" },
            { "Misc_Studio_Red_Tape", true, "Cassette Tape", "Splits" },
            { "Misc_Nightmare_Studio_Spike_1", true, "Spike 1", "Splits" },
            { "Misc_Wire_Cutter", true, "Wire Cutter", "Splits" },
            { "Misc_Nightmare_Studio_Spike_2", true, "Spike 2", "Splits" },
            { "Misc_Studio_Dial", true, "Rotary Dial", "Splits" },
            { "Misc_Nightmare_Studio_Spike_3", true, "Spike 3", "Splits" },
            { "Boss_Pursuer2", true, "Defeat the Thelend Broadcasting Boss", "Splits" },
            { "Boss_Madam", true, "Defeat Strange Tree Boss", "Splits" },
            { "EndingsSplits", true, "Endings", "Splits" },
                { "Choice_Leave", true, "Leave", "EndingsSplits" },
                    { "Shoot_Eddie", true, "Shoot Eddie", "Choice_Leave" },
                    { "Ending_Leave", true, "Leave", "Choice_Leave" },
    };

    vars.Uhara.Settings.Create(_settings);
}

init
{
    vars.Utils = vars.Uhara.CreateTool("Unity", "Utils");
    vars.Instance = vars.Uhara.CreateTool("Unity", "IL2CPP", "Instance");

    // In-game timer and Game Active instances
    vars.Instance.Watch<float>("Playtime", "CarpenterScripts::GlobalReferences", "m_instance", "DataStore", "m_data", "m_playtime");
    vars.Instance.Watch<int>("GameActive", "CarpenterScripts::GlobalReferences", "m_instance", "GameState", "m_activeState");

    // Inventory, memento, progression, UI and enemy-set instances
    vars.Instance.Watch<IntPtr>("InventoryItems", "CarpenterScripts::GlobalReferences", "m_instance", "DataStore", "m_characterInventory", "m_items");
    vars.Instance.Watch<IntPtr>("SpecialItems", "CarpenterScripts::GlobalReferences", "m_instance", "DataStore", "m_characterInventory", "m_specialItems");
    vars.Instance.Watch<IntPtr>("Mementos", "CarpenterScripts::GlobalReferences", "m_instance", "DataStore", "m_characterInventory", "m_artifactItems");
    vars.Instance.Watch<IntPtr>("StashItems", "CarpenterScripts::GlobalReferences", "m_instance", "StashInventory", "m_items");
    vars.Instance.Watch<bool>("SewerFlowAOpen", "CarpenterScripts::GlobalReferences", "m_instance", "Variables", "Progression", "PV_Sewer_Flow_A_Open", "m_value");
    vars.Instance.Watch<bool>("SewerFlowBOpen", "CarpenterScripts::GlobalReferences", "m_instance", "Variables", "Progression", "PV_Sewer_Flow_B_Open", "m_value");
    vars.Instance.Watch<bool>("SewerFlowCOpen", "CarpenterScripts::GlobalReferences", "m_instance", "Variables", "Progression", "PV_Sewer_Flow_C_Open", "m_value");    
    vars.Instance.Watch<bool>("TunnelBossDefeated", "CarpenterScripts::GlobalReferences", "m_instance", "Variables", "Progression", "PV_Outskirts_Tunnel_Boss_Defeated", "m_value");
    vars.Instance.Watch<bool>("TunnelBossActive", "CarpenterScripts::GlobalReferences", "m_instance", "Variables", "Progression", "PV_Outskirts_Tunnel_Boss_Active", "m_value");
    vars.Instance.Watch<IntPtr>("ExaminableAnchor", "CarpenterScripts::GlobalReferences", "m_instance", "Anchors", "Generic", "ExaminableAnchor");
    vars.Instance.Watch<IntPtr>("NearbyInteractableAnchor", "CarpenterScripts::GlobalReferences", "m_instance", "Anchors", "Generic", "NearbyInteractableAnchor");
    vars.Instance.Watch<int>("EndingState", "CarpenterScripts::GameCompletionSummary", "m_gameEndingState");
    vars.Instance.Watch<bool>("cutsceneActive", "CarpenterScripts::GameCutsceneManager", "m_cutsceneActive");
    vars.Instance.Watch<IntPtr>("Enemies", "CarpenterScripts::GlobalReferences", "m_instance", "Sets", "Generic", "EnemyPresenceSet", "m_items");
    vars.Instance.Watch<IntPtr>("EnemiesAlt", "CarpenterScripts::EnemyPresenceSet", "m_items");

    // Initalize the relevant current instances
    current.ActiveScene = "";
    current.cutsceneActive = false;
    current.Enemies = IntPtr.Zero;
    current.EnemiesAlt = IntPtr.Zero;
    current.Mementos = IntPtr.Zero;
    current.EddieExam = IntPtr.Zero;
    current.EddieNear = IntPtr.Zero;
    current.EddieClosedAt = DateTime.MinValue;
    vars.TotalTime = 0.0f;
    vars.LastPlaytime = 0.0f;
    vars.SheriffSeen = false;
    current.InvSize = -1;
    current.SpecialSize = -1;
    current.MementoSize = -1;
    current.StashSize = -1;
}

start
{
    vars.TotalTime = 0.0f;
    return old.ActiveScene != "Outskirts_Diner_Interior" && current.ActiveScene == "Outskirts_Diner_Interior";
}

onStart
{
    vars.CompletedSplits.Clear();
    vars.PendingSplits.Clear();
    vars.ItemNames.Clear();
    vars.ItemCounts.Clear();
    vars.TotalTime = 0.0f;
    vars.LastPlaytime = 0.0f;
    current.EddieExam = IntPtr.Zero;
    current.EddieNear = IntPtr.Zero;
    current.EddieClosedAt = DateTime.MinValue;
    current.InvSize = -1;
    current.SpecialSize = -1;
    current.MementoSize = -1;
    current.StashSize = -1;
    vars.PrevStashEntries.Clear();
    vars.SheriffSeen = false;
}

update
{
    vars.Uhara.Update();

    string scene = vars.Utils.GetActiveSceneName2();
    if (String.IsNullOrWhiteSpace(scene)) scene = vars.Utils.GetActiveSceneName();
    if (!String.IsNullOrWhiteSpace(scene) && scene != "UserPreferencesManager") current.ActiveScene = scene;

    if (current.GameActive != 0)
    {
        bool newGame = old.ActiveScene != "Outskirts_Diner_Interior" && current.ActiveScene == "Outskirts_Diner_Interior";
        bool playtimeReset = current.Playtime < vars.LastPlaytime && current.Playtime < 5.0f && vars.LastPlaytime > 60.0f;

        if (newGame || playtimeReset)
        {
            vars.CompletedSplits.Clear();
            vars.PendingSplits.Clear();
            vars.ItemNames.Clear();
            vars.ItemCounts.Clear();
            vars.TotalTime = 0.0f;
            current.EddieExam = IntPtr.Zero;
            current.EddieNear = IntPtr.Zero;
            current.EddieClosedAt = DateTime.MinValue;
            current.InvSize = -1;
            current.SpecialSize = -1;
            current.MementoSize = -1;
            current.StashSize = -1;
            vars.PrevStashEntries.Clear();
            vars.SheriffSeen = false;
        }
        else if (current.Playtime < vars.LastPlaytime)
        {
            vars.TotalTime += vars.LastPlaytime - current.Playtime;
        }

        vars.LastPlaytime = current.Playtime;

        // Item box/stash guard: taking an item out of the box increases the
        // player inventory size and looks like a pickup; skip stash transfers.
        IntPtr stash = current.StashItems;
        int stashSize = stash != IntPtr.Zero ? vars.Resolver.Read<int>(stash + 0x18) : 0;
        current.StashSize = stashSize;
        bool stashMovedOut = old.StashSize >= 0 && stashSize < old.StashSize;

        var currentStashEntries = new List<IntPtr>();
        if (stash != IntPtr.Zero)
        {
            IntPtr stashArray = vars.Resolver.Read<IntPtr>(stash + 0x10);
            if (stashArray != IntPtr.Zero && stashSize >= 0 && stashSize <= 128)
                for (int s = 0; s < stashSize; s++)
                    currentStashEntries.Add(vars.Resolver.Read<IntPtr>(stashArray + 0x20 + s * 8));
        }

        // Inventory Items
        if (current.InventoryItems != IntPtr.Zero)
        {
            IntPtr inv = current.InventoryItems;
            IntPtr array = vars.Resolver.Read<IntPtr>(inv + 0x10);
            int size = vars.Resolver.Read<int>(inv + 0x18);
            current.InvSize = size;

            if (old.InvSize >= 0 && size > old.InvSize && size > 0 && size <= 128 && array != IntPtr.Zero)
            {
                int newCount = size - old.InvSize;

                for (int i = size - newCount; i < size; i++)
                {
                    IntPtr entry = vars.Resolver.Read<IntPtr>(array + 0x20 + i * 8);
                    if (entry == IntPtr.Zero) break;
                    if (stashMovedOut || vars.PrevStashEntries.Contains(entry)) continue;

                    IntPtr def = vars.Resolver.Read<IntPtr>(entry + 0x18);
                    IntPtr cached = def != IntPtr.Zero ? vars.Resolver.Read<IntPtr>(def + 0x10) : IntPtr.Zero;
                    IntPtr nameField = cached != IntPtr.Zero ? cached + 0x38 : IntPtr.Zero;
                    IntPtr namePtr = nameField != IntPtr.Zero ? vars.Resolver.Read<IntPtr>(nameField) : IntPtr.Zero;

                    string name = namePtr != IntPtr.Zero ? vars.Resolver.ReadString(256, ReadStringType.UTF8, namePtr) : null;
                    if (nameField != IntPtr.Zero && (String.IsNullOrWhiteSpace(name) || name.Length > 96))
                        name = vars.Resolver.ReadString(256, ReadStringType.UTF8, nameField);

                    if (String.IsNullOrWhiteSpace(name) || name.Length > 96) continue;

                    vars.Uhara.Log("Item added: inventory " + name);

                    string key = name;
                    if (settings.ContainsKey(name + "_1"))
                    {
                        int count = 0;
                        bool found = false;

                        for (int item = 0; item < vars.ItemNames.Count; item++)
                        {
                            if (vars.ItemNames[item] == name)
                            {
                                count = vars.ItemCounts[item];
                                vars.ItemCounts[item] = count + 1;
                                found = true;
                                break;
                            }
                        }

                        if (!found)
                        {
                            vars.ItemNames.Add(name);
                            vars.ItemCounts.Add(1);
                        }

                        key = name + "_" + (count + 1);
                    }

                    if (settings.ContainsKey(key) && settings[key] && !vars.CompletedSplits.Contains(key))
                    {
                        vars.CompletedSplits.Add(key);
                        vars.PendingSplits.Add(key);
                    }
                }
            }
        }

        // Special Items Tracking
        if (current.SpecialItems != IntPtr.Zero)
        {
            IntPtr inv = current.SpecialItems;
            IntPtr array = vars.Resolver.Read<IntPtr>(inv + 0x10);
            int size = vars.Resolver.Read<int>(inv + 0x18);
            current.SpecialSize = size;

            if (old.SpecialSize >= 0 && size > old.SpecialSize && size > 0 && size <= 128 && array != IntPtr.Zero)
            {
                int newCount = size - old.SpecialSize;

                for (int i = size - newCount; i < size; i++)
                {
                    IntPtr entry = vars.Resolver.Read<IntPtr>(array + 0x20 + i * 8);
                    if (entry == IntPtr.Zero) break;

                    IntPtr def = vars.Resolver.Read<IntPtr>(entry + 0x18);
                    IntPtr cached = def != IntPtr.Zero ? vars.Resolver.Read<IntPtr>(def + 0x10) : IntPtr.Zero;
                    IntPtr nameField = cached != IntPtr.Zero ? cached + 0x38 : IntPtr.Zero;
                    IntPtr namePtr = nameField != IntPtr.Zero ? vars.Resolver.Read<IntPtr>(nameField) : IntPtr.Zero;

                    string name = namePtr != IntPtr.Zero ? vars.Resolver.ReadString(256, ReadStringType.UTF8, namePtr) : null;
                    if (nameField != IntPtr.Zero && (String.IsNullOrWhiteSpace(name) || name.Length > 96))
                        name = vars.Resolver.ReadString(256, ReadStringType.UTF8, nameField);

                    if (String.IsNullOrWhiteSpace(name) || name.Length > 96) continue;

                    vars.Uhara.Log("Item added: special " + name);

                    string key = name;
                    if (settings.ContainsKey(name + "_1"))
                    {
                        int count = 0;
                        bool found = false;

                        for (int item = 0; item < vars.ItemNames.Count; item++)
                        {
                            if (vars.ItemNames[item] == name)
                            {
                                count = vars.ItemCounts[item];
                                vars.ItemCounts[item] = count + 1;
                                found = true;
                                break;
                            }
                        }

                        if (!found)
                        {
                            vars.ItemNames.Add(name);
                            vars.ItemCounts.Add(1);
                        }

                        key = name + "_" + (count + 1);
                    }

                    if (settings.ContainsKey(key) && settings[key] && !vars.CompletedSplits.Contains(key))
                    {
                        vars.CompletedSplits.Add(key);
                        vars.PendingSplits.Add(key);
                    }
                }
            }
        }

        // Mementos (artifacts) Tracking
        if (current.Mementos != IntPtr.Zero)
        {
            IntPtr inv = current.Mementos;
            IntPtr array = vars.Resolver.Read<IntPtr>(inv + 0x10);
            int size = vars.Resolver.Read<int>(inv + 0x18);
            current.MementoSize = size;

            if (old.MementoSize >= 0 && size > old.MementoSize && size > 0 && size <= 128 && array != IntPtr.Zero)
            {
                int newCount = size - old.MementoSize;

                for (int i = size - newCount; i < size; i++)
                {
                    IntPtr entry = vars.Resolver.Read<IntPtr>(array + 0x20 + i * 8);
                    if (entry == IntPtr.Zero) break;

                    IntPtr def = vars.Resolver.Read<IntPtr>(entry + 0x18);
                    IntPtr cached = def != IntPtr.Zero ? vars.Resolver.Read<IntPtr>(def + 0x10) : IntPtr.Zero;
                    IntPtr nameField = cached != IntPtr.Zero ? cached + 0x38 : IntPtr.Zero;
                    IntPtr namePtr = nameField != IntPtr.Zero ? vars.Resolver.Read<IntPtr>(nameField) : IntPtr.Zero;

                    string name = namePtr != IntPtr.Zero ? vars.Resolver.ReadString(256, ReadStringType.UTF8, namePtr) : null;
                    if (nameField != IntPtr.Zero && (String.IsNullOrWhiteSpace(name) || name.Length > 96))
                        name = vars.Resolver.ReadString(256, ReadStringType.UTF8, nameField);

                    if (String.IsNullOrWhiteSpace(name) || name.Length > 96) continue;
                    if (!name.StartsWith("Artifact_")) continue;

                    vars.Uhara.Log("Item added: memento " + name);

                    string key = name;
                    if (settings.ContainsKey(name + "_1"))
                    {
                        int count = 0;
                        bool found = false;

                        for (int item = 0; item < vars.ItemNames.Count; item++)
                        {
                            if (vars.ItemNames[item] == name)
                            {
                                count = vars.ItemCounts[item];
                                vars.ItemCounts[item] = count + 1;
                                found = true;
                                break;
                            }
                        }

                        if (!found)
                        {
                            vars.ItemNames.Add(name);
                            vars.ItemCounts.Add(1);
                        }

                        key = name + "_" + (count + 1);
                    }

                    if (settings.ContainsKey(key) && settings[key] && !vars.CompletedSplits.Contains(key))
                    {
                        vars.CompletedSplits.Add(key);
                        vars.PendingSplits.Add(key);
                    }
                }
            }
        }

        vars.PrevStashEntries.Clear();
        for (int s = 0; s < currentStashEntries.Count; s++) vars.PrevStashEntries.Add(currentStashEntries[s]);
    }
    else
    {
        current.InvSize = -1;
        current.SpecialSize = -1;
        current.MementoSize = -1;
        current.StashSize = -1;
        vars.PrevStashEntries.Clear();
        vars.PendingSplits.Clear();
    }
}

split
{
    if (settings["Splits"] && current.GameActive != 0)
    {
        // Pending item split detected in update
        if (vars.PendingSplits.Count > 0)
        {
            string key = vars.PendingSplits[0];
            vars.PendingSplits.RemoveAt(0);
            vars.Uhara.Log("Split fired: " + key);
            return true;
        }

        // Eddie finale. Kill: the examine prompt closes and the shoot target clears ~500ms later.
        // Leave: both clear in the same frame, so use the time gap
        if (current.ActiveScene == "Nightmare_Studio_Alice_Exterior")
        {
            IntPtr exam = current.ExaminableAnchor != IntPtr.Zero ? vars.Resolver.Read<IntPtr>(current.ExaminableAnchor + 0x18) : IntPtr.Zero;
            IntPtr near = current.NearbyInteractableAnchor != IntPtr.Zero ? vars.Resolver.Read<IntPtr>(current.NearbyInteractableAnchor + 0x18) : IntPtr.Zero;

            if (exam != IntPtr.Zero && old.EddieExam == IntPtr.Zero) current.EddieClosedAt = DateTime.MinValue;
            if (exam == IntPtr.Zero && old.EddieExam != IntPtr.Zero) current.EddieClosedAt = DateTime.UtcNow;

            if (near == IntPtr.Zero && old.EddieNear != IntPtr.Zero && current.EddieClosedAt != DateTime.MinValue 
                && (DateTime.UtcNow - current.EddieClosedAt).TotalMilliseconds >= 500 && !vars.CompletedSplits.Contains("Shoot_Eddie"))
            {
                vars.CompletedSplits.Add("Shoot_Eddie");
                if (settings.ContainsKey("Shoot_Eddie") && settings["Shoot_Eddie"] && settings["Choice_Leave"] 
                    && settings["EndingsSplits"]) 
                { 
                    vars.Uhara.Log("Split fired: Shoot_Eddie"); 
                    return true;
                }
            }

            current.EddieExam = exam;
            current.EddieNear = near;
        }
        else
        {
            current.EddieExam = IntPtr.Zero;
            current.EddieNear = IntPtr.Zero;
            current.EddieClosedAt = DateTime.MinValue;
        }

        // Enemy tracking via GlobalReferences -> Sets.Generic.EnemyPresenceSet.m_items
        // Boss rule: a presence with m_type == Boss(3) wins, otherwise the presence with
        // the highest CharacterHealth max is the boss (the Sheriff boss is type 0)
        IntPtr enemiesRoot = current.Enemies;
        if (enemiesRoot == IntPtr.Zero) enemiesRoot = current.EnemiesAlt;

        bool sheriffScene = current.ActiveScene.StartsWith("Sheriff_Lobby");
        bool bossScene = false;
        string bossKey = "";

        foreach (string bossSceneName in vars.BossScenes.Keys)
            if (current.ActiveScene.StartsWith(bossSceneName))
            {
                bossScene = true;
                bossKey = vars.BossScenes[bossSceneName];
                break;
            }

        if (!sheriffScene) vars.SheriffSeen = false;

        if (enemiesRoot != IntPtr.Zero)
        {
            int enemySize = vars.Resolver.Read<int>(enemiesRoot + 0x18);

            if (enemySize > 0 && enemySize <= 64)
            {
                IntPtr array = vars.Resolver.Read<IntPtr>(enemiesRoot + 0x10);

                if (array != IntPtr.Zero)
                {
                    IntPtr boss = IntPtr.Zero;
                    int bossType = -1, bossMax = 0, bossHp = 0, alive = 0;
                    bool valid = true;

                    for (int i = 0; i < enemySize; i++)
                    {
                        IntPtr enemy = vars.Resolver.Read<IntPtr>(array + 0x20 + i * 8);
                        if (enemy == IntPtr.Zero) { valid = false; break; }

                        IntPtr healthPtr = vars.Resolver.Read<IntPtr>(enemy + 0x40);
                        if (healthPtr == IntPtr.Zero) continue; // presence marker, not a character

                        int type = vars.Resolver.Read<int>(enemy + 0x38);
                        int max = vars.Resolver.Read<int>(healthPtr + 0x20);
                        int hp = vars.Resolver.Read<int>(healthPtr + 0xAC);

                        if (hp > 0) alive++;

                        if (boss == IntPtr.Zero || (type == 3 && bossType != 3) || (type != 3 && bossType != 3 && max > bossMax))
                        {
                            boss = enemy;
                            bossType = type;
                            bossMax = max;
                            bossHp = hp;
                        }
                    }

                    if (valid && vars.Resolver.Read<IntPtr>(enemiesRoot + 0x10) == array && vars.Resolver.Read<int>(enemiesRoot + 0x18) == enemySize)
                    {
                        // Only treat a presence as a boss in a known boss scene, or if it has EnemyPresenceType.Boss
                        // Everything else is a normal enemy.
                        if (!bossScene && bossType != 3) boss = IntPtr.Zero;

                        // Church chapel: the 35 HP boss codename "Faceless" is a decoy 
                        // The real boss is the 100 HP form that appears after the wave/enemy section
                        if (current.ActiveScene.StartsWith("Nightmare_Church_Chapel") && bossMax < 100) boss = IntPtr.Zero;

                        // Alley sewer: the Boss codename is "Fogshambler" and has 380 HP;
                        // the 60 HP Shadow that lingers in the set must not be mistaken for the boss.
                        if (current.ActiveScene.StartsWith("Downtown_Market_St_Alley_Sewer") && bossMax < 300) boss = IntPtr.Zero;

                        // General Boss Split
                        if (boss != IntPtr.Zero)
                        {
                            // The Sheriff encounter is only considered started once boss entry has HP
                            if (sheriffScene && bossMax > 0) vars.SheriffSeen = true;

                            // Boss died: boss reached zero HP.
                            if (!sheriffScene && bossKey != "" && bossHp <= 0 && bossHp < bossMax && !vars.CompletedSplits.Contains(bossKey))
                            {
                                vars.CompletedSplits.Add(bossKey);

                                if (settings.ContainsKey(bossKey) && settings[bossKey]) 
                                {
                                    vars.Uhara.Log("Split fired: " + bossKey);
                                    return true;
                                }
                            }
                        }

                        // Sheriff: split only once the boss has been seen AND no enemy is alive
                        if (sheriffScene && vars.SheriffSeen && alive == 0 && !vars.CompletedSplits.Contains("Boss_Sheriff"))
                        {
                            vars.CompletedSplits.Add("Boss_Sheriff");

                            if (settings.ContainsKey("Boss_Sheriff") && settings["Boss_Sheriff"]) 
                            {
                                vars.Uhara.Log("Split fired: Boss_Sheriff"); 
                                return true;
                            }
                        }
                    }
                }
            }
        }

        // Tunnel boss
        if (current.ActiveScene.StartsWith("Outskirts_Tunnel") && old.TunnelBossActive && !old.TunnelBossDefeated 
            && current.TunnelBossDefeated && !vars.CompletedSplits.Contains("Boss_Mantis"))
        {
            vars.CompletedSplits.Add("Boss_Mantis");
            if (settings.ContainsKey("Boss_Mantis") && settings["Boss_Mantis"]) 
            {
                vars.Uhara.Log("Split fired: Boss_Mantis");
                return true;
            }
        }

        // Rabbit Hole cutscene
        if (current.ActiveScene == "Motel_Interior_Shop_Basement" && current.cutsceneActive && !vars.CompletedSplits.Contains("RabbitHoleCutscene"))
        {
            vars.CompletedSplits.Add("RabbitHoleCutscene");

            if (settings.ContainsKey("RabbitHoleCutscene") && settings["RabbitHoleCutscene"]) 
            { 
                vars.Uhara.Log("Split fired: RabbitHoleCutscene"); 
                return true; 
            }
        }

        // Cable car arrival on the mountain
        if (old.ActiveScene == "Downtown_Peak_Gondola" && current.ActiveScene == "Peak_Cable_Station_Main" && !vars.CompletedSplits.Contains("CableCar_Mountain"))
        {
            vars.CompletedSplits.Add("CableCar_Mountain");

            if (settings.ContainsKey("CableCar_Mountain") && settings["CableCar_Mountain"]) 
            {
                vars.Uhara.Log("Split fired: CableCar_Mountain");
                return true; 
            }
        }

        // Leave ending
        if (current.EndingState == 1 && !vars.CompletedSplits.Contains("Ending_Leave"))
        {
            vars.CompletedSplits.Add("Ending_Leave");

            if (settings.ContainsKey("Ending_Leave") && settings["Ending_Leave"] && settings["Choice_Leave"] && settings["EndingsSplits"]) 
            {
                vars.Uhara.Log("Split fired: Ending_Leave");
                return true; 
            }
        }

        // Sluice gate flows
        if (current.SewerFlowAOpen && settings.ContainsKey("Sewer_Flow_A") && settings["Sewer_Flow_A"] && !vars.CompletedSplits.Contains("Sewer_Flow_A")) { vars.CompletedSplits.Add("Sewer_Flow_A"); vars.Uhara.Log("Split fired: Sewer_Flow_A"); return true; }
        if (current.SewerFlowBOpen && settings.ContainsKey("Sewer_Flow_B") && settings["Sewer_Flow_B"] && !vars.CompletedSplits.Contains("Sewer_Flow_B")) { vars.CompletedSplits.Add("Sewer_Flow_B"); vars.Uhara.Log("Split fired: Sewer_Flow_B"); return true; }
        if (current.SewerFlowCOpen && settings.ContainsKey("Sewer_Flow_C") && settings["Sewer_Flow_C"] && !vars.CompletedSplits.Contains("Sewer_Flow_C")) { vars.CompletedSplits.Add("Sewer_Flow_C"); vars.Uhara.Log("Split fired: Sewer_Flow_C"); return true; }
    }
}

isLoading
{
    return true;
}

gameTime
{
    return TimeSpan.FromSeconds(vars.LastPlaytime + vars.TotalTime);
}

onReset
{
    vars.TotalTime = 0.0f;
    vars.LastPlaytime = 0.0f;
}
state("PBZ") {}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/uhara10-PBZ")).CreateInstance("Main");
    string __componentDir = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "Components");
    string __culture = System.Globalization.CultureInfo.CurrentCulture.Name;
    string __settingsPath = Path.Combine(__componentDir, "PhantomBladeZero.Splits." + __culture + ".xml");
    if (!File.Exists(__settingsPath))
    {
        string __language = __culture.Split('-')[0];
        __settingsPath = Path.Combine(__componentDir, "PhantomBladeZero.Splits." + __language + ".xml");
    }
    if (!File.Exists(__settingsPath))
        __settingsPath = Path.Combine(__componentDir, "PhantomBladeZero.Splits.xml");
    try
    {
        vars.Uhara.Settings.CreateFromXml(__settingsPath);
    }
    catch
    {
        vars.Uhara.Settings.CreateFromXml(Path.Combine(__componentDir, "PhantomBladeZero.Splits.xml"));
    }
    vars.Uhara.AlertLoadless();

    vars.CompletedSplits = new HashSet<string>();
    vars.IsLaunched = false;
}

init
{
    int moduleSize = modules.First().ModuleMemorySize;

    if (moduleSize < 2000000)
    {
        vars.IsLaunched = true;
        timer.IsGameTimePaused = true;
        vars.Uhara.Reject(moduleSize);
        return;
    }

    vars.IsLaunched = false;

    // Game version from exe resources (no memory read needed)
    string fullVersion = modules.First().FileVersionInfo.ProductVersion;
    string[] versionParts = fullVersion.Split('_');
    vars.Changelist = versionParts[0]; // "CL-302256"
    vars.BuildNumber = versionParts.Length > 1 ? versionParts[1] : ""; // "JKS-17280"
    vars.Uhara.Log("Game version: " + vars.Changelist + " Build: " + vars.BuildNumber);

    vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
    vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");

    if (vars.Utils.GWorld == IntPtr.Zero || vars.Utils.GEngine == IntPtr.Zero || vars.Utils.FNames == IntPtr.Zero)
        throw new Exception("GWorld, GEngine or FNamePool not found");

    vars.Resolver.Watch<ulong>("GWorldName", vars.Utils.GWorld, 0x18);
    vars.Resolver.Watch<bool>("IsLoadingLevel", vars.Utils.GEngine, 0x12E0, 0x7A2);
    vars.Resolver.Watch<IntPtr>("BeHatredList", vars.Utils.GEngine, 0x12E0, 0x38, 0x0, 0x30, 0x358, 0xE90, 0xD8);
    vars.Resolver.Watch<int>("BeHatredListSize", vars.Utils.GEngine, 0x12E0, 0x38, 0x0, 0x30, 0x358, 0xE90, 0xE0);
    vars.Resolver.Watch<bool>("DeathWidgetActive", vars.Utils.GEngine, 0x12E0, 0x38, 0x0, 0x30, 0x358, 0x1010, 0x3D0);

    vars.Events.FunctionFlag("StartLoadingScreen", null, null, "StartPBZLoadingScreen");
    vars.Events.FunctionFlag("EndLoadingScreen", null, null, "EndPBZLoadingScreen");
    vars.Events.FunctionFlag("TempLoadingStart", "WB_TempLoadingScreen_C", null, "BP_OnActivated");
    vars.Events.FunctionFlag("TempLoadingEnd", "WB_TempLoadingScreen_C", null, "OnDisappeared");
    vars.Events.FunctionFlag("BlackScreenActivated", "WB_BlackScreen*", null, "BP_OnActivated");
    vars.Events.FunctionFlag("BlackScreenDeactivated", "WB_BlackScreen*", null, "BP_OnDeactivated");

    // PBZGameSystem instance capture (per-world WorldSubsystem).
    // Slot is the address Uhara writes the matched object pointer into.
    vars.GameSystemSlot = vars.Events.InstancePtr("PBZGameSystem", null);
    vars.GameSystemLast = IntPtr.Zero;
    if (vars.GameSystemSlot != IntPtr.Zero)
    {
        vars.Resolver.Watch<IntPtr>("GameSystemPtr", vars.GameSystemSlot);
        vars.Resolver.Watch<int>("CycleCount", vars.GameSystemSlot, 0x238);
        vars.Resolver.Watch<bool>("IsFinishGame", vars.GameSystemSlot, 0x2D0);
    }
    else
    {
        vars.Uhara.Log("InstanceCreation PBZGameSystem | registration FAILED (slot=0)");
    }

    vars.Events.FunctionParentPtr<IntPtr>("SeqNode_Capture", "PlayLevelSequence*", null, null);
    vars.Events.FunctionParentPtr<IntPtr>("QTEBase", "W_QTE*", null, null);

    current.World = "";
    current.IsLoadingLevel = false;
    current.LoadingScreen = false;
    current.BlackScreen = false;
    current.DeathWidgetActive = false;
    current.SeqNode_Capture = IntPtr.Zero;
    current.SequenceNode = IntPtr.Zero;
    current.SequenceStatus = false;
    current.CutscenePlaying = false;
    current.SequenceFName = 0UL;
    current.SequenceName = "";
    current.QTEBase = IntPtr.Zero;
    current.QTEClass = "";
    current.QTEExited = -1;
    current.QTECountdown = -1;
    current.QTERepeatedPress = -1;
    current.QTELongPress = -1;
    current.QTEActive = false;
    current.IsFinishGame = false;
    vars.BossFightName = "";
    vars.BossFightClass = "";
    vars.BossFightNode = IntPtr.Zero;
    vars.EnemyDeathName = "";
    vars.EnemyDeathSplit = false;
    vars.WaitForNewBossFight = false;
    vars.IsDuoFight = false;
    vars.ExpectingVisage = false;
    vars.BossArmed = false;
    vars.BossDeathTriggered = false;
    vars.BossLastMaxHp = 0f;
    vars.BossLastHp = 0f;
    vars.BossEmptyFrames = 0;
    vars.DuoEmptyFrames = 0;
    vars.DuoMembers = new string[0];
    vars.DuoRequiresReentry = false;
    vars.DuoReentrySeen = false;
    vars.NGPlusStartArmed = false;
}

start
{
    if (vars.IsLaunched) return false;
    if (settings.ContainsKey("NGPlus") && settings["NGPlus"])
    {
        if (old.CycleCount < current.CycleCount)
        {
            vars.NGPlusStartArmed = true;
        }

        if (vars.NGPlusStartArmed && current.World == "PBZ_Xigu_WP")
        {
            vars.NGPlusStartArmed = false;
            return true;
        }
    }

    return old.World == "PBZ_StartMenu_CE_WP" && (current.World == "PBZ_WP_ZhuLinGuWu" || current.World == "PBZ_Xigu_WP");
}

onStart
{
    timer.IsGameTimePaused = true;
    vars.CompletedSplits.Clear();

    vars.BossFightName = "";
    vars.BossFightClass = "";
    vars.BossFightNode = IntPtr.Zero;
    vars.EnemyDeathName = "";
    vars.EnemyDeathSplit = false;
    vars.WaitForNewBossFight = false;
    vars.IsDuoFight = false;
    vars.ExpectingVisage = false;
    vars.BossArmed = false;
    vars.BossDeathTriggered = false;
    vars.BossLastMaxHp = 0f;
    vars.BossLastHp = 0f;
    vars.BossEmptyFrames = 0;
    vars.DuoEmptyFrames = 0;
    vars.DuoMembers = new string[0];
    vars.DuoRequiresReentry = false;
    vars.DuoReentrySeen = false;
}

update
{
    if (vars.IsLaunched)
    {
        timer.IsGameTimePaused = true;
        return;
    }

    vars.Uhara.Update();

    // World
    if (old.GWorldName != current.GWorldName || string.IsNullOrEmpty(current.World))
    {
        string world = vars.Utils.FNameToString(current.GWorldName);
        if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
    }

    if (!string.IsNullOrEmpty(old.World) && old.World != current.World && !string.IsNullOrEmpty(current.World))
    {
        string slotNow = "n/a";
        if (vars.GameSystemSlot != IntPtr.Zero)
            slotNow = vars.Resolver.Read<IntPtr>(vars.GameSystemSlot).ToString();
        vars.Uhara.Log("World changed -> " + current.World + " | gameSystemSlot=" + slotNow);
    }

    // PBZGameSystem instance capture (per-world WorldSubsystem).
    // The slot is a pointer slot: Read(slot, off) dereferences it first.
    if (vars.GameSystemSlot != IntPtr.Zero) {
        IntPtr gs = vars.Resolver.Read<IntPtr>(vars.GameSystemSlot);
        if (gs != vars.GameSystemLast) {
            vars.GameSystemLast = gs;
            if (gs == IntPtr.Zero) {
                vars.Uhara.Log("InstanceCreation PBZGameSystem -> 0x0 world=" + current.World);
            } else {
                ulong gsName = vars.Resolver.Read<ulong>(vars.GameSystemSlot, 0x18);
                vars.Uhara.Log("InstanceCreation PBZGameSystem -> " + gs.ToString()
                    + " name=" + vars.Utils.FNameToString(gsName)
                    + " world=" + current.World);
            }
        }
    }

    // Loading screens
    if (vars.Resolver.CheckFlag("StartLoadingScreen")) current.LoadingScreen = true;
    if (vars.Resolver.CheckFlag("TempLoadingStart")) current.LoadingScreen = true;
    if (vars.Resolver.CheckFlag("EndLoadingScreen")) current.LoadingScreen = false;
    if (vars.Resolver.CheckFlag("TempLoadingEnd")) current.LoadingScreen = false;
    if (vars.Resolver.CheckFlag("BlackScreenActivated")) current.BlackScreen = true;
    if (vars.Resolver.CheckFlag("BlackScreenDeactivated")) current.BlackScreen = false;

    // Sequence capture
    bool captureAccepted = false;

    if (current.SeqNode_Capture != IntPtr.Zero)
    {
        IntPtr ls = vars.Resolver.Read<IntPtr>(current.SeqNode_Capture + 0x1B8);
        if (ls != IntPtr.Zero)
        {
            ulong fn = vars.Resolver.Read<ulong>(ls + 0x18);
            string sn = vars.Utils.FNameToString(fn);

            if (!string.IsNullOrEmpty(sn) && sn != "None")
            {
                current.SequenceNode = current.SeqNode_Capture;
                current.SequenceFName = fn;
                current.SequenceName = sn;
                captureAccepted = true;
            }
        }

        current.SeqNode_Capture = IntPtr.Zero;
    }

    if (!captureAccepted && current.SequenceNode != IntPtr.Zero)
    {
        IntPtr ls = vars.Resolver.Read<IntPtr>(current.SequenceNode + 0x1B8);

        if (ls == IntPtr.Zero) current.SequenceNode = IntPtr.Zero;
        else
        {
            string sn = vars.Utils.FNameToString(vars.Resolver.Read<ulong>(ls + 0x18));
            if (string.IsNullOrEmpty(sn) || sn == "None") current.SequenceNode = IntPtr.Zero;
        }
    }

    current.SequenceStatus = current.SequenceNode != IntPtr.Zero && vars.Resolver.Read<byte>(current.SequenceNode + 0x1F0, 0x290) == 1;
    current.CutscenePlaying = current.SequenceNode != IntPtr.Zero;

    if (current.SequenceFName != old.SequenceFName)  current.SequenceName = vars.Utils.FNameToString(current.SequenceFName);
    if (string.IsNullOrEmpty(current.SequenceName) || current.SequenceName == "None") current.SequenceName = "";
    if (current.SequenceName.Contains("VisageTree") && !old.SequenceName.Contains("VisageTree")) vars.ExpectingVisage = true;

    // QTE: only read the known layout on supported widget classes.
    // QTE: only read the known layout while a sequence/cutscene is active.
    if (!current.CutscenePlaying || current.QTEBase == IntPtr.Zero)
    {
        current.QTEClass = "";
        current.QTEExited = -1;
        current.QTECountdown = -1;
        current.QTERepeatedPress = -1;
        current.QTELongPress = -1;
        current.QTEActive = false;
    }
    else
    {
        if (current.QTEBase != old.QTEBase || string.IsNullOrEmpty(current.QTEClass))
        {
            current.QTEClass = "";
            IntPtr classPtr = vars.Resolver.Read<IntPtr>(current.QTEBase + 0x10);

            if (classPtr != IntPtr.Zero) current.QTEClass = vars.Utils.FNameToString(vars.Resolver.Read<ulong>(classPtr + 0x18));
        }

        if (current.QTEBase != old.QTEBase || current.QTEClass != old.QTEClass) current.QTEActive = false;

        if (current.QTEClass == "W_QTEBase_C" || current.QTEClass == "W_QTERepatedPressed_C")
        {
            current.QTEExited = vars.Resolver.Read<byte>(current.QTEBase + 0x490);
            current.QTECountdown = vars.Resolver.Read<byte>(current.QTEBase + 0x491);
            current.QTERepeatedPress = vars.Resolver.Read<byte>(current.QTEBase + 0x492);
            current.QTELongPress = vars.Resolver.Read<byte>(current.QTEBase + 0x493);

            // Exit takes priority. Otherwise preserve the existing active latch.
            if (current.QTEExited != 0) current.QTEActive = false;
            else if (current.QTECountdown == 1 || current.QTERepeatedPress == 1 || current.QTELongPress == 1) current.QTEActive = true;
            else if (current.QTECountdown != 0 || current.QTERepeatedPress != 0 || current.QTELongPress != 0) current.QTEActive = false;
        }
        else
        {
            current.QTEExited = -1;
            current.QTECountdown = -1;
            current.QTERepeatedPress = -1;
            current.QTELongPress = -1;
            current.QTEActive = false;
        }
    }

    // Player death
    if (current.DeathWidgetActive && !old.DeathWidgetActive)
    {
        vars.WaitForNewBossFight = true;
        vars.DuoRequiresReentry = vars.IsDuoFight;
        vars.DuoReentrySeen = false;

        if (vars.IsDuoFight)
        {
            vars.BossFightName = "";
            vars.BossFightClass = "";
            vars.BossFightNode = IntPtr.Zero;
            vars.IsDuoFight = false;
            vars.DuoMembers = new string[0];
            vars.DuoEmptyFrames = 0;
        }
        else
        {
            vars.BossFightNode = IntPtr.Zero;
            vars.BossFightName = "";
            vars.BossFightClass = "";
            vars.BossArmed = false;
            vars.BossDeathTriggered = false;
            vars.BossLastMaxHp = 0f;
            vars.BossLastHp = 0f;
            vars.BossEmptyFrames = 0;
        }
    }

    // Save reload / level transition
    if (current.IsLoadingLevel && !old.IsLoadingLevel)
    {
        vars.WaitForNewBossFight = true;
        vars.DuoRequiresReentry = true;
        vars.DuoReentrySeen = false;

        if (vars.IsDuoFight)
        {
            vars.BossFightName = "";
            vars.BossFightClass = "";
            vars.BossFightNode = IntPtr.Zero;
            vars.IsDuoFight = false;
            vars.DuoMembers = new string[0];
            vars.DuoEmptyFrames = 0;
        }
        else
        {
            vars.BossFightNode = IntPtr.Zero;
            vars.BossFightName = "";
            vars.BossFightClass = "";
            vars.BossArmed = false;
            vars.BossDeathTriggered = false;
            vars.BossLastMaxHp = 0f;
            vars.BossLastHp = 0f;
            vars.BossEmptyFrames = 0;
        }
    }

    // Collect present classes and the first enabled individual boss.
    string firstMatchedClass = "";
    IntPtr firstMatchedNode = IntPtr.Zero;
    var presentClasses = new HashSet<string>();
    var presentNodes = new Dictionary<string, IntPtr>();

    if (settings["BossSplits"] && current.BeHatredList != IntPtr.Zero && current.BeHatredListSize > 0 && current.BeHatredListSize <= 128)
    {
        for (int i = 0; i < current.BeHatredListSize; i++)
        {
            IntPtr actor = vars.Resolver.Read<IntPtr>(current.BeHatredList + i * IntPtr.Size);
            if (actor == IntPtr.Zero) continue;

            IntPtr classPtr = vars.Resolver.Read<IntPtr>(actor + 0x10);
            string className = classPtr == IntPtr.Zero ? "" : vars.Utils.FNameToString(vars.Resolver.Read<ulong>(classPtr + 0x18));

            if (string.IsNullOrEmpty(className) || className == "None") continue;
            if (presentClasses.Add(className)) presentNodes[className] = actor;
            if (firstMatchedNode != IntPtr.Zero) continue;

            string settingName = "Boss_" + className;
            if (!settings.ContainsKey(settingName) || !settings[settingName]) continue;

            firstMatchedClass = className;
            firstMatchedNode = actor;
        }
    }

    // Duo detection: test both setting-ID orders without individual member settings.
    string detectedDuoKey = "";
    string[] detectedDuoMembers = new string[0];

    if (settings["BossSplits"] && current.BeHatredList != IntPtr.Zero && current.BeHatredListSize > 1 && presentClasses.Count >= 2)
    {
        var classList = presentClasses.ToList();

        for (int i = 0; i < classList.Count && string.IsNullOrEmpty(detectedDuoKey); i++)
        {
            for (int j = i + 1; j < classList.Count; j++)
            {
                string keyA = "BossDuo_" + classList[i] + "+" + classList[j];
                string keyB = "BossDuo_" + classList[j] + "+" + classList[i];

                if (settings.ContainsKey(keyA) && settings[keyA]) detectedDuoKey = keyA;
                else if (settings.ContainsKey(keyB) && settings[keyB]) detectedDuoKey = keyB;

                if (string.IsNullOrEmpty(detectedDuoKey)) continue;

                detectedDuoMembers = new string[] { classList[i], classList[j] };
                break;
            }
        }
    }

    if (vars.WaitForNewBossFight && vars.DuoRequiresReentry && string.IsNullOrEmpty(detectedDuoKey)) vars.DuoReentrySeen = true;

    // Duo takes priority over individual detection.
    if (!string.IsNullOrEmpty(detectedDuoKey) && vars.BossFightName != detectedDuoKey)
    {
        if (!vars.WaitForNewBossFight || (vars.DuoRequiresReentry && vars.DuoReentrySeen))
        {
            vars.BossFightName = detectedDuoKey;
            vars.BossFightClass = "";
            vars.BossFightNode = IntPtr.Zero;
            vars.IsDuoFight = true;
            vars.DuoMembers = detectedDuoMembers;
            vars.DuoEmptyFrames = 0;
            vars.WaitForNewBossFight = false;
            vars.DuoRequiresReentry = false;
            vars.DuoReentrySeen = false;
            vars.EnemyDeathName = "";
            vars.EnemyDeathSplit = false;
        }
    }
    else if (!vars.IsDuoFight && firstMatchedNode != IntPtr.Zero && string.IsNullOrEmpty(vars.BossFightName))
    {
        string fightName = "Boss_" + firstMatchedClass;

        if (vars.ExpectingVisage)
        {
            string visageName = fightName + "_Visage";
            if (settings.ContainsKey(visageName) && settings[visageName]) fightName = visageName;

            vars.ExpectingVisage = false;
        }

        vars.BossFightName = fightName;
        vars.BossFightClass = firstMatchedClass;
        vars.BossFightNode = firstMatchedNode;
        vars.IsDuoFight = false;
        vars.EnemyDeathName = "";
        vars.EnemyDeathSplit = false;
        vars.BossArmed = false;
        vars.BossDeathTriggered = false;
        vars.BossLastMaxHp = 0f;
        vars.BossLastHp = 0f;
        vars.BossEmptyFrames = 0;
    }

    // Duo completion: both tracked classes absent for five consecutive updates.
    if (vars.IsDuoFight && !string.IsNullOrEmpty(vars.BossFightName) && vars.DuoMembers.Length == 2)
    {
        if (presentClasses.Contains(vars.DuoMembers[0]) || presentClasses.Contains(vars.DuoMembers[1])) vars.DuoEmptyFrames = 0;
        else vars.DuoEmptyFrames++;

        if (vars.DuoEmptyFrames >= 5)
        {
            if (!vars.WaitForNewBossFight && !vars.BossDeathTriggered)
            {
                vars.BossDeathTriggered = true;

                if (settings.ContainsKey(vars.BossFightName) && settings[vars.BossFightName])
                {
                    vars.EnemyDeathName = vars.BossFightName;
                    vars.EnemyDeathSplit = true;
                }
            }

            vars.BossFightName = "";
            vars.BossFightClass = "";
            vars.BossFightNode = IntPtr.Zero;
            vars.IsDuoFight = false;
            vars.DuoMembers = new string[0];
            vars.DuoEmptyFrames = 0;
        }
    }

    // Single-boss removal: retain the existing near-zero HP requirement.
    if (!vars.IsDuoFight && vars.BossFightNode != IntPtr.Zero && !string.IsNullOrEmpty(vars.BossFightName))
    {
        bool trackedBossPresent = !string.IsNullOrEmpty(vars.BossFightClass)
            && presentNodes.ContainsKey(vars.BossFightClass) && presentNodes[vars.BossFightClass] == vars.BossFightNode;

        if (trackedBossPresent) vars.BossEmptyFrames = 0;
        else vars.BossEmptyFrames++;

        if (vars.BossEmptyFrames >= 5)
        {
            if (vars.BossArmed && !vars.WaitForNewBossFight && !vars.BossDeathTriggered
                && vars.BossLastMaxHp > 0.001f && vars.BossLastHp <= 0.001f * vars.BossLastMaxHp + 0.001f)
            {
                vars.BossDeathTriggered = true;

                if (settings.ContainsKey(vars.BossFightName) && settings[vars.BossFightName])
                {
                    vars.EnemyDeathName = vars.BossFightName;
                    vars.EnemyDeathSplit = true;
                }
            }

            vars.BossFightNode = IntPtr.Zero;
            vars.BossFightName = "";
            vars.BossFightClass = "";
            vars.BossArmed = false;
            vars.BossDeathTriggered = false;
            vars.BossLastMaxHp = 0f;
            vars.BossLastHp = 0f;
            vars.BossEmptyFrames = 0;
        }
    }

    // Single-boss HP / gameplay-tag monitoring.
    if (!vars.IsDuoFight && vars.BossFightNode != IntPtr.Zero && !string.IsNullOrEmpty(vars.BossFightName))
    {
        IntPtr boss = vars.BossFightNode;
        IntPtr classPtr = vars.Resolver.Read<IntPtr>(boss + 0x10);
        string bossClass = classPtr == IntPtr.Zero ? "" : vars.Utils.FNameToString(vars.Resolver.Read<ulong>(classPtr + 0x18));

        if (!string.IsNullOrEmpty(bossClass) && bossClass != "None")
        {
            string expectedSetting = "Boss_" + bossClass;

            if (vars.BossFightName != expectedSetting && settings.ContainsKey(expectedSetting) && settings[expectedSetting])
            {
                vars.BossFightName = expectedSetting;
                vars.BossFightClass = bossClass;
                vars.BossArmed = false;
                vars.BossDeathTriggered = false;
                vars.BossLastMaxHp = 0f;
                vars.BossLastHp = 0f;
            }
        }

        long attrSet = vars.Resolver.Read<long>(boss + 0x758);
        float bossHp = attrSet == 0 ? 0f : vars.Resolver.Read<float>((IntPtr)attrSet + 0x64);
        float bossMaxHp = attrSet == 0 ? 0f : vars.Resolver.Read<float>((IntPtr)attrSet + 0x74);

        if (attrSet != 0 && bossMaxHp > 0.001f) vars.BossLastMaxHp = bossMaxHp;
        if (bossHp > 0.001f) vars.BossArmed = true;
        if (bossHp > 0.001f && vars.WaitForNewBossFight) vars.WaitForNewBossFight = false;
        vars.BossLastHp = bossHp;

        IntPtr asc = vars.Resolver.Read<IntPtr>(boss + 0x750);

        // A missing ASC does not clear the retained fight.
        if (asc != IntPtr.Zero && vars.BossArmed && !vars.BossDeathTriggered)
        {
            IntPtr tags = vars.Resolver.Read<IntPtr>(asc + 0xF48);
            int tagCount = vars.Resolver.Read<int>(asc + 0xF50);
            bool deadTag = false;

            if (tagCount > 0 && tagCount <= 32 && tags != IntPtr.Zero)
            {
                for (int t = 0; t < tagCount; t++)
                {
                    if ((vars.Resolver.Read<ulong>(tags + t * 0x14) & 0xFFFFFFFFUL) == 0x538D8UL // CharacterState.Dead tag
                        && vars.Resolver.Read<int>(tags + t * 0x14 + 0x08) > 0)
                    {
                        deadTag = true;
                        break;
                    }
                }
            }

            if (!vars.WaitForNewBossFight && (deadTag || (bossMaxHp > 0.001f && bossHp <= 0.001f)))
            {
                vars.BossDeathTriggered = true;

                if (settings.ContainsKey(vars.BossFightName) && settings[vars.BossFightName])
                {
                    vars.EnemyDeathName = vars.BossFightName;
                    vars.EnemyDeathSplit = true;
                }
            }
        }
    }
}

split
{
    if (vars.IsLaunched) return false;

    string sequence = "";

    if (current.SequenceStatus && (!old.SequenceStatus || current.SequenceName != old.SequenceName)
        && !string.IsNullOrEmpty(current.SequenceName) && settings.ContainsKey(current.SequenceName)
        && settings[current.SequenceName] && !vars.CompletedSplits.Contains(current.SequenceName))
        sequence = current.SequenceName;

    if (string.IsNullOrEmpty(sequence) && vars.EnemyDeathSplit)
    {
        vars.EnemyDeathSplit = false;
        string deathName = vars.EnemyDeathName;
        vars.EnemyDeathName = "";

        if (!string.IsNullOrEmpty(deathName) && settings.ContainsKey(deathName)
            && settings[deathName] && !vars.CompletedSplits.Contains(deathName))
        {
            vars.CompletedSplits.Add(deathName);
            vars.Uhara.Log("Split: Enemy died - " + deathName);

            if (vars.IsDuoFight)
            {
                vars.BossFightName = "";
                vars.BossFightClass = "";
                vars.BossFightNode = IntPtr.Zero;
                vars.IsDuoFight = false;
                vars.DuoMembers = new string[0];
                vars.DuoEmptyFrames = 0;
            }
            else
            {
                vars.BossFightNode = IntPtr.Zero;
                vars.BossFightName = "";
                vars.BossFightClass = "";
                vars.BossArmed = false;
                vars.BossDeathTriggered = false;
                vars.BossLastMaxHp = 0f;
                vars.BossLastHp = 0f;
                vars.BossEmptyFrames = 0;
            }

            return true;
        }
    }

    if (!string.IsNullOrEmpty(sequence))
    {
        vars.CompletedSplits.Add(sequence);
        vars.Uhara.Log("Split: " + sequence);
        return true;
    }

    // Game completion split (bIsFinishGame on PBZGameSystem)
    if (current.IsFinishGame && !old.IsFinishGame)
    {
        if (settings.ContainsKey("FinishGame") && settings["FinishGame"] && !vars.CompletedSplits.Contains("FinishGame"))
        {
            vars.CompletedSplits.Add("FinishGame");
            vars.Uhara.Log("Split: Game Finished");
            return true;
        }
    }
}

isLoading
{
    if (vars.IsLaunched) return true;

    return current.IsLoadingLevel || current.LoadingScreen || current.BlackScreen
        || current.World == "ServerCheck" || current.World == "PBZ_StartMenu_CE_WP"
        || (current.CutscenePlaying && !current.QTEActive);
}

onReset
{
    vars.CompletedSplits.Clear();

    vars.BossFightName = "";
    vars.BossFightClass = "";
    vars.BossFightNode = IntPtr.Zero;
    vars.EnemyDeathName = "";
    vars.EnemyDeathSplit = false;
    vars.WaitForNewBossFight = false;
    vars.IsDuoFight = false;
    vars.ExpectingVisage = false;
    vars.BossArmed = false;
    vars.BossDeathTriggered = false;
    vars.BossLastMaxHp = 0f;
    vars.BossLastHp = 0f;
    vars.BossEmptyFrames = 0;
    vars.DuoEmptyFrames = 0;
    vars.DuoMembers = new string[0];
    vars.DuoRequiresReentry = false;
    vars.DuoReentrySeen = false;
}


exit
{
    timer.IsGameTimePaused = true;
}
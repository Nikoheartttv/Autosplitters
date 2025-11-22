state("GlitchSpank-Win64-Shipping") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/uhara9")).CreateInstance("Main");
	vars.Uhara.AlertLoadless();
	vars.Uhara.EnableDebug();

	dynamic[,] _settings =
	{
		{ "Splits", true, "Splits", null },
			{ "SPANKR_HQ", true, "Enter SPANKR_HQ", "Splits" },
			{ "PathTutorialLevels", true, "Path Tutorial", "Splits" },
				{ "PathTutorialSplits", true, "Path Tutorial - Splits", "PathTutorialLevels" },
					{ "Program_Start", true, "Program_Start", "PathTutorialSplits" },
					{ "Program_Identify", true, "Program_Identify", "PathTutorialSplits" },
					{ "Find_Target", true, "Find_Target", "PathTutorialSplits" },
					{ "Machine_Learning", true, "Machine_Learning", "PathTutorialSplits" },
					{ "Break_Through", true, "Break_Through", "PathTutorialSplits" },
					{ "Free_Cammin", true, "Free_Cammin", "PathTutorialSplits" },
					{ "Friend_Or_Foe", true, "Friend_Or_Foe", "PathTutorialSplits" }, // Decision Point
				{ "PathGLevels", true, "Path G - Top Row", "PathTutorialLevels" },
					{ "PathGSplits", true, "Path G - Splits", "PathGLevels" },
						{ "Excitement", true, "Excitement", "PathGSplits" },
						{ "DontSpank", true, "DontSpank", "PathGSplits" },
						{ "Small", true, "Small", "PathGSplits" },
						{ "Old_Friends", true, "Old_Friends", "PathGSplits" },
						{ "Apologies", true, "Apologies", "PathGSplits" },
						{ "Clubbing", true, "Clubbing", "PathGSplits" },
						{ "Pet_Care", true, "Pet_Care", "PathGSplits" },
						{ "Restraint_2", true, "Restraint_2", "PathGSplits" }, // Decision Point
					{ "PathPLevels", true, "Path P - Top Row", "PathGLevels" },
						{ "PathPSplits", true, "Path P - Splits", "PathPLevels" },
							{ "Lights_Out", true, "Lights_Out", "PathPSplits" },
							{ "Party_Time", true, "Party_Time", "PathPSplits" },
							{ "Whoopsie", true, "Whoopsie", "PathPSplits" },
							{ "Drugs_Are_Bad", true, "Drugs_Are_Bad", "PathPSplits" },
							{ "A_New_Perspective", true, "A_New_Perspective", "PathPSplits" },
							{ "Retro", true, "Retro", "PathPSplits" },
							{ "Pizza_Party", true, "Pizza_Party", "PathPSplits" },
							{ "Music_Man", true, "Music_Man", "PathPSplits" },
							{ "A_Loaded_Question", true, "A_Loaded_Question", "PathPSplits"}, // Decision Point
						{ "PathHLoversLevels", true, "Path H Lovers - Top Row", "PathPLevels" },
							{ "PathHLoversSplits", true, "Path H Lovers - Splits", "PathHLoversLevels" },
								{ "Movie_Night", true, "Movie_Night", "PathHLoversSplits" },
								{ "Dinner_Cooking", true, "Dinner_Cooking", "PathHLoversSplits" },
								{ "Dinner_Eating", true, "Dinner_Eating", "PathHLoversSplits" },
								{ "Wedding", true, "Wedding", "PathHLoversSplits" },
								{ "Something_Ever_After", true, "Something_Ever_After", "PathHLoversSplits" }, // Ending
						{ "PathCLonelyLevels", true, "Path C Lonely - Bottom Row", "PathPLevels" },
							{ "PathCLonelySplits", true, "Path C Lonely - Splits", "PathCLonelyLevels" },
								{ "Silence", true, "Silence", "PathCLonelySplits" },
								{ "Distance", true, "Distance", "PathCLonelySplits" },
								{ "Wangman", true, "Wangman", "PathCLonelySplits" },
								{ "Clean_Up", true, "Clean_Up", "PathCLonelySplits" },
								{ "Family_Man", true, "Family_Man", "PathCLonelySplits" }, // Ending
					{ "PathLLevels", true, "Path L - Bottom Row", "PathGLevels" },
						{ "PathLSplits", true, "Path L - Splits", "PathLLevels" },
							{ "Smoochies", true, "Smoochies", "PathLSplits" },
							{ "Caged", true, "Caged", "PathLSplits" },
							{ "Kissem_Or_Missem", true, "Kissem_Or_Missem", "PathLSplits" },
							{ "Test_Your_SPUNK", true, "Test_Your_SPUNK", "PathLSplits" },
							{ "Dunk_The_Spunk", true, "Dunk_The_Spunk", "PathLSplits" },
							{ "Prize_Counter", true, "Prize_Counter", "PathLSplits" },
							{ "Kissem", true, "Kissem", "PathLSplits" }, // Ending
				{ "PathBLevels", true, "Path B - Bottom Row", "PathTutorialLevels" },
					{ "PathBSplits", true, "Path B - Splits", "PathBLevels" },
						{ "BuckleUp", true, "BuckleUp", "PathBSplits" },
						{ "Self_Defense", true, "Self_Defense", "PathBSplits" },
						{ "Hoodwinked", true, "Hoodwinked", "PathBSplits" },
						{ "Payback", true, "Payback", "PathBSplits" },
						{ "Breaking_Point", true, "Breaking_Point", "PathBSplits" },
						{ "Black_Magic", true, "Black_Magic", "PathBSplits" },
						{ "Somewhere", true, "Somewhere", "PathBSplits"}, 
						{ "Booty_Defense", true, "Booty_Defense", "PathBSplits" },
						{ "Moral_Dilemma", true, "Moral_Dilemma", "PathBSplits"	}, // Decision Point
					{ "PathSSpareLevels", true, "Path S Spare - Top Row", "PathBLevels" },
						{ "PathSSpareSplits", true, "Path S Spare - Splits", "PathSSpareLevels" },
							{ "Too_Slow", true, "Too_Slow", "PathSSpareSplits" },
							{ "Reverse_Psychology", true, "Reverse_Psychology", "PathSSpareSplits" },
							{ "World_News", true, "World_News", "PathSSpareSplits" },
							{ "Something_Amiss", true, "Something_Amiss", "PathSSpareSplits" },
							{ "I_Heart_Something", true, "I_Heart_Something", "PathSSpareSplits" },
							{ "New_key", true, "New_key", "PathSSpareSplits" },
							{ "Reversed", true, "Reversed", "PathSSpareSplits" },
							{ "The_Gauntlet", true, "The_Gauntlet", "PathSSpareSplits" },
							{ "Statistically_Improbable", true, "Statistically_Improbable", "PathSSpareSplits" },
							{ "Bilingual", true, "Bilingual", "PathSSpareSplits" }, // Decision Point
						{ "PathNNemesisLevels", true, "Path N Nemesis - Top Row", "PathSSpareLevels" },
							{ "PathNNemesisSplits", true, "Path N Nemesis - Splits", "PathNNemesisLevels" },
								{ "Tag_Along", true, "Tag_Along", "PathNNemesisSplits" },
								{ "Jiggle", true, "Jiggle", "PathNNemesisSplits" },
								{ "Its_YOU", true, "Its_YOU", "PathNNemesisSplits" },
								{ "Spy_Movie", true, "Spy_Movie", "PathNNemesisSplits" },
								{ "Smash_And_Grab", true, "Smash_And_Grab", "PathNNemesisSplits" },
								{ "Ownership", true, "Ownership", "PathNNemesisSplits" },
								{ "Revenge", true, "Revenge", "PathNNemesisSplits" }, // Ending
						{ "PathMMagicLevels", true, "Path M Magic - Bottom Row", "PathSSpareLevels" },
							{ "PathMMagicSplits", true, "Path M Magic - Splits", "PathMMagicLevels" },
								{ "Magic", true, "Magic", "PathMMagicSplits" },
								{ "Busted", true, "Busted", "PathMMagicSplits" },
								{ "Escort", true, "Escort", "PathMMagicSplits" },
								{ "Dark_Maze", true, "Dark_Maze", "PathMMagicSplits" },
								{ "Refunds", true, "Refunds", "PathMMagicSplits" }, // Ending
					{ "PathDLevels", true, "Path D - Bottom Row", "PathBLevels" },
						{ "PathDSplits", true, "Path D - Splits", "PathDLevels" },
							{ "BossFight", true, "BossFight", "PathDSplits" },
							{ "Unimaginable", true, "Unimaginable", "PathDSplits" },
							{ "Time_Consuming", true, "Time_Consuming", "PathDSplits" },
							{ "Thend", true, "Thend", "PathDSplits" },
							{ "Waiting", true, "Waiting", "PathDSplits" },
							{ "Blackmail", true, "Blackmail", "PathDSplits" },
							{ "SpunkBall", true, "SpunkBall", "PathDSplits" },
							{ "Recycler", true, "Recycler", "PathDSplits" },
							{ "TattleTale", true, "TattleTale", "PathDSplits" }, // Decision Point
						{ "PathJMomLevels", true, "Path J Mom - Top Row", "PathDLevels" },
							{ "PathJMomSplits", true, "Path J Mom - Splits", "PathJMomLevels" },
								{ "Paddlin", true, "Paddlin", "PathJMomSplits" },
								{ "Doppleganger", true, "Doppleganger", "PathJMomSplits" },
								{ "Spernk", true, "Spernk", "PathJMomSplits" },
								{ "Main_Quest", true, "Main_Quest", "PathJMomSplits" },
								{ "End_Of_Pain", true, "End_Of_Pain", "PathJMomSplits" }, // Ending
						{ "PathRFrenemyLevels", true, "Path R Frenemy - Bottom Row", "PathDLevels" },
							{ "PathRFrenemySplits", true, "Path R Frenemy - Splits", "PathRFrenemyLevels" },
								{ "Hide_And_Seek", true, "Hide_And_Seek", "PathRFrenemySplits" },
								{ "Spaceman", true, "Spaceman", "PathRFrenemySplits" },
								{ "Surprise", true, "Surprise", "PathRFrenemySplits" },
								{ "Browser_History", true, "Browser_History", "PathRFrenemySplits" },
								{ "Death", true, "Death", "PathRFrenemySplits" },
								{ "Bombastic", true, "Bombastic", "PathRFrenemySplits" }, // Ending
			{ "FinalHub", true, "FinalHub", "Splits" },
				{ "Calm_Before_The_Storm", true, "Calm_Before_The_Storm", "FinalHub" },
				{ "Desp_1", true, "Desp_1", "FinalHub" },
				{ "Desp_2", true, "Desp_2", "FinalHub" },
				{ "Desp_3", true, "Desp_3", "FinalHub" },
				{ "Desp_4", true, "Desp_4", "FinalHub" },
				{ "Desp_5", true, "Desp_5", "FinalHub" },
				{ "Desp_7", true, "Desp_7", "FinalHub" },
				{ "Desp_8", true, "Desp_8", "FinalHub" },
				{ "The_Decision", true, "The_Decision", "FinalHub" },
			{ "BadEnding", true, "Bad Ending", "Splits" },
				{ "Its_MY_Game", true, "Its_MY_Game", "BadEnding" },
				{ "Big_Booty_Slapper_6", true, "Big_Booty_Slapper_6 (Credits Bad)", "BadEnding" },
			{ "GoodEnding", true, "Good Ending", "Splits" },
				{ "Youre_Worth_It", true, "Youre_Worth_It (Credits Good)", "GoodEnding"},
	};
						
	vars.Uhara.Settings.Create(_settings);
	vars.BeatenLevelsList = new List<string>();
}

init
{
	vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
	vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");
	var GSync = vars.Utils.GSync;
	if (vars.Utils.GEngine != IntPtr.Zero) vars.Uhara.Log("GEngine: " + vars.Utils.GEngine.ToString("X"));
	if (vars.Utils.GWorld != IntPtr.Zero) vars.Uhara.Log("GWorld: " + vars.Utils.GWorld.ToString("X"));
	if (vars.Utils.FNames != IntPtr.Zero) vars.Uhara.Log("FNames: " + vars.Utils.FNames.ToString("X"));

	vars.Resolver.Watch<uint>("GWorldName", vars.Utils.GWorld, 0x18);
	vars.Resolver.Watch<int>("CurrentLevelIndex", vars.Utils.GEngine, 0x10A8, 0x1E0);
	vars.Resolver.Watch<int>("CurrentBranch", vars.Utils.GEngine, 0x10A8, 0x1E4);
	vars.Resolver.Watch<IntPtr>("BeatenLevels", vars.Utils.GEngine, 0x10A8, 0x1D8, 0xB0);
	vars.Resolver.Watch<int>("BeatenLevelsSize", vars.Utils.GEngine, 0x10A8, 0x1D8, 0xB8);
	vars.Resolver.Watch<int>("GSync", vars.Utils.GSync);
	// vars.Resolver.WatchString("LevelTitle", vars.Utils.GEngine, 0x10A8, 0x38, 0x0, 0x30, 0x8B8, 0x3D8, 0x1A0, 0x28, 0x0);

	current.World = "";
	current.Test = "";
	current.BeatenLevels = 0;
	current.LevelTitle = "";
	current.BeatenLevelsSize = 0;
	current.GSync = 0;
	current.PrevBeatenLevelsSize = 0;
}

onStart
{
	vars.BeatenLevelsList.Clear();
}

start
{
	return (old.World == "PrologueIntro" || old.World == "ShaderCompile") && current.World == "MainMenuBedroom";
}

update
{
	vars.Uhara.Update();

	var world = vars.Utils.FNameToString(current.GWorldName);
	if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
	if (old.World != current.World) vars.Uhara.Log("World: " + current.World);

	if (old.GSync != current.GSync)	vars.Uhara.Log("GSync changed: " + current.GSync);
}

split
{
    // for (var i = 0; i < current.BeatenLevelsSize; i++)
    // {
    //     string levelName = vars.Resolver.ReadString(256, ReadStringType.UTF16, current.BeatenLevels + (i * 0x10), 0x0);

    //     // Only act if level is valid, not already split, and exists/enabled in settings
    //     if (!string.IsNullOrEmpty(levelName) &&
    //         !vars.BeatenLevelsList.Contains(levelName) &&
    //         settings.ContainsKey(levelName) &&
    //         settings[levelName])
    //     {
    //         vars.BeatenLevelsList.Add(levelName);
    //         vars.Uhara.Log("Split triggered for '" + levelName + "'");
    //         return true;
    //     }
    // }
	if (current.BeatenLevelsSize > current.PrevBeatenLevelsSize)
    {
        for (var i = current.PrevBeatenLevelsSize; i < current.BeatenLevelsSize; i++)
        {
            string levelName = vars.Resolver.ReadString(256, ReadStringType.UTF16, current.BeatenLevels + (i * 0x10), 0x0);

            if (!string.IsNullOrEmpty(levelName) && !vars.BeatenLevelsList.Contains(levelName) &&
                settings.ContainsKey(levelName) && settings[levelName])
            {
                vars.BeatenLevelsList.Add(levelName);
                vars.Uhara.Log("Split triggered for '" + levelName + "'");
                current.PrevBeatenLevelsSize = current.BeatenLevelsSize;
                return true;
            }
        }

        current.PrevBeatenLevelsSize = current.BeatenLevelsSize;
    }

    if (old.World != current.World && settings["SPANKR_HQ"] && 
		current.World == "SPANKR_HQ" && !vars.BeatenLevelsList.Contains("SPANKR_HQ"))
    {
        vars.BeatenLevelsList.Add("SPANKR_HQ"); vars.Uhara.Log("SPANKR_HQ split triggered"); return true;
    }
}

isLoading
{
	return current.GSync > 0;
}
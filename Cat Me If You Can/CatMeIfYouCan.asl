state("CatMeIfYouCan-Win64-Shipping") {}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main");
    vars.Uhara.AlertLoadless();

    dynamic[,] _settings =
	{
		{ "Demo", true, "Tabbyshire - Demo", null },
            { "Hamlet_BaseCats", true, "Base Cats", "Demo" },
                { "Hamlet_Lily", true, "Lily", "Hamlet_BaseCats" },
                { "Hamlet_Felix", true, "Felix", "Hamlet_BaseCats" },
                { "Hamlet_Mittens", true, "Mittens", "Hamlet_BaseCats" },
                { "Hamlet_Chloe", true, "Chloe", "Hamlet_BaseCats" },
                { "Hamlet_Sam", true, "Sam", "Hamlet_BaseCats" },
                { "Hamlet_Oscar", true, "Oscar", "Hamlet_BaseCats" },
                { "Hamlet_Kiki", true, "Kiki", "Hamlet_BaseCats" },
                { "Hamlet_Luna", true, "Luna", "Hamlet_BaseCats" },
                { "Hamlet_Max", true, "Max", "Hamlet_BaseCats" },
                { "Hamlet_Bella", true, "Bella", "Hamlet_BaseCats" },
                { "Hamlet_Peppa", true, "Peppa", "Hamlet_BaseCats" },
                { "Hamlet_Shadow", true, "Shadow", "Hamlet_BaseCats" },
                { "Hamlet_Nala", true, "Nala", "Hamlet_BaseCats" },
                { "Hamlet_Bailey", true, "Bailey", "Hamlet_BaseCats" },
                { "Hamlet_Coco", true, "Coco", "Hamlet_BaseCats" },
                { "Hamlet_Charlie", true, "Charlie", "Hamlet_BaseCats" },
                { "Hamlet_Simba", true, "Simba", "Hamlet_BaseCats" },
                { "Hamlet_Doodle", true, "Doodle", "Hamlet_BaseCats" },
                { "Hamlet_Misty", true, "Misty", "Hamlet_BaseCats" },
                { "Hamlet_Remy", true, "Remy", "Hamlet_BaseCats" },
                { "Hamlet_Biscuit", true, "Biscuit", "Hamlet_BaseCats" },
                { "Hamlet_Pip", true, "Pip", "Hamlet_BaseCats" },
                { "Hamlet_Maple", true, "Maple", "Hamlet_BaseCats" },
                { "Hamlet_Ash", true, "Ash", "Hamlet_BaseCats" },
                { "Hamlet_Benny", true, "Benny", "Hamlet_BaseCats" },
                { "Hamlet_Sparkles", true, "Sparkles", "Hamlet_BaseCats" },
                { "Hamlet_Murphy", true, "Murphy", "Hamlet_BaseCats" },
                { "Hamlet_Cupcake", true, "Cupcake", "Hamlet_BaseCats" },
                { "Hamlet_Toby", true, "Toby", "Hamlet_BaseCats" },
                { "Hamlet_Muffin", true, "Muffin", "Hamlet_BaseCats" },
                { "Hamlet_Cookie", true, "Cookie", "Hamlet_BaseCats" },
                { "Hamlet_Tilly", true, "Tilly", "Hamlet_BaseCats" },
            { "Hamlet_GoldCats", true, "Gold Cats", "Demo" },
                { "Hamlet_Sir Catches-a-Lot", true, "Sir Catches-a-Lot", "Hamlet_GoldCats" },
                { "Hamlet_Whisker Ramsey", true, "Whisker Ramsey", "Hamlet_GoldCats" },
                { "Hamlet_Mr. & Mrs. Smith", true, "Mr. & Mrs. Smith", "Hamlet_GoldCats" },
            { "Hamlet_CosmicCat", true, "Cosmic Cat", "Demo"},
                { "Hamlet_Knight of the Order of Derp", true, "Knight of the Order of Derp", "Hamlet_CosmicCat" },
	};

    vars.CatsCollected = new List<string>();
    vars.Uhara.Settings.Create(_settings);
}

init
{
    vars.Utils = vars.Uhara.CreateTool("UnrealEngine", "Utils");
    vars.Events = vars.Uhara.CreateTool("UnrealEngine", "Events");

    if (vars.Utils.GEngine != IntPtr.Zero) vars.Uhara.Log("GEngine found at " + vars.Utils.GEngine.ToString("X"));
    if (vars.Utils.GWorld != IntPtr.Zero) vars.Uhara.Log("GWorld found at " + vars.Utils.GWorld.ToString("X"));
    if (vars.Utils.FNames != IntPtr.Zero) vars.Uhara.Log("FNames found at " + vars.Utils.FNames.ToString("X"));

    vars.Resolver.Watch<uint>("GWorldName", vars.Utils.GWorld, 0x18);
    vars.Resolver.Watch<bool>("bIsCatFound", vars.Utils.GEngine, 0x1080, 0x38, 0x0, 0x30, 0x2E8, 0x7A8);
    vars.Resolver.WatchString("CatName", vars.Utils.GEngine, 0x1080, 0x38, 0x0, 0x30, 0x2E8, 0x7B0, 0x28, 0x0);

    vars.Events.FunctionFlag("LoadingStart", "EnhancedInputComponent", "PC_InputComponent*", "OnInputOwnerEndPlayed");
    vars.Events.FunctionFlag("LoadingEnd", "BP_Player_C", "BP_Player_C", "ActorLoaded");
    vars.Events.FunctionFlag("LoadingBackInMainMenu", "WBP_LevelCard_Demo_C", "WBP_LevelCard_Demo", "ExecuteUbergraph_WBP_LevelCard_Demo");

    current.World = "";
    vars.Loading = false;
}

update
{
    vars.Uhara.Update();

    var world = vars.Utils.FNameToString(current.GWorldName);
    if (!string.IsNullOrEmpty(world) && world != "None") current.World = world;
    if (old.World != current.World) vars.Uhara.Log("World: " + current.World);

    if (old.CatName != current.CatName) vars.Uhara.Log("Cat: " + current.CatName);
    if (vars.Resolver.CheckFlag("LoadingStart")) vars.Loading = true;
    if (vars.Resolver.CheckFlag("LoadingEnd")) vars.Loading = false;
    if (vars.Resolver.CheckFlag("LoadingBackInMainMenu")) vars.Loading = false;
}

start
{
    return old.World == "MainMenu" && current.World != "MainMenu";
}

split
{
    if (old.CatName != current.CatName && settings[current.World + "_" + current.CatName] 
        && !vars.CatsCollected.Contains(current.World + "_" + current.CatName))
    {
        vars.CatsCollected.Add(current.World + "_" + current.CatName);
        vars.Uhara.Log("--- SPLIT: " + current.CatName);
        return true;
    }
}

isLoading
{
    return vars.Loading || current.World == "MainMenu";
}
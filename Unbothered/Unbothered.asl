state("Unbothered"){}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.GameName = "Unbothered";
    vars.Helper.LoadSceneManager = true;
    vars.Helper.AlertLoadless();

    dynamic[,] _settings =
    {
        { "Day2_Outside", true, "Day 1", null },
        { "Day3_Outside", true, "Day 2", null },
        { "Day4_Outside1", true, "Day 3", null },
        { "Day4_Outside2", true, "Day 4", null },
    };

    vars.Helper.Settings.Create(_settings);
    vars.Helper.AlertLoadless();
    vars.VisitedLevel = new List<string>();
}

init
{
    vars.Helper.TryLoad = (Func<dynamic, bool>)(mono =>
    {
        vars.Helper["playCutscenes"] = mono.Make<bool>("CutsceneManager", "Instance", "playCutscenes");
        vars.Helper["playerCanMove"] = mono.Make<bool>("CutsceneManager", "Instance", "playerController", "playerCanMove");
        vars.Helper["cameraCanMove"] = mono.Make<bool>("CutsceneManager", "Instance", "playerController", "cameraCanMove");
        return true;
    });
    current.Scene = "";
    vars.Day4Multiple = 0;
}

start
{
    return current.activeScene == "Day1_Outside" && old.cameraCanMove == false && current.cameraCanMove == true;
}

onStart
{
    vars.Day4Multiple = 0;
}

update
{
    current.activeScene = vars.Helper.Scenes.Active.Name == null ? current.activeScene : vars.Helper.Scenes.Active.Name;
    if(old.activeScene == "Manager" && current.activeScene == "Day4_Outside")
    {
        vars.Day4Multiple++;
        current.Scene = current.activeScene + vars.Day4Multiple;
    } 
    else if (old.activeScene != current.activeScene)
    {
        current.Scene = current.activeScene;
    }
}

split
{
    if (old.Scene != current.Scene && current.Scene != "Manager") return settings[current.Scene.ToString()];
}

isLoading
{
    return current.playerCanMove == false && current.cameraCanMove == false || current.activeScene == "Manager";
}
state("Big Ambitions"){}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/uhara10")).CreateInstance("Main");
    vars.Uhara.AlertLoadless();
}

init
{
    vars.Utils = vars.Uhara.CreateTool("Unity", "Utils");
    vars.Instance = vars.Uhara.CreateTool("Unity", "DotNet", "Instance");

    vars.Instance.Watch<bool>("isLoading", "BigAmbitions:UI.Load:LoadScene", "isLoading");
    vars.Instance.Watch<IntPtr>("loadingScreen", "BigAmbitions:UI.Load:LoadingScreen", "m_CachedPtr");
    vars.Uhara["loadingScreen"].FailAction = MemoryWatcher.ReadFailAction.SetZeroOrNull;
    vars.Instance.Watch<bool>("GamePaused", "BigAmbitions:UI.MiniMenu:MiniMenu", "IsOpen");
    vars.Instance.Watch<bool>("IngameTimePaused", "BigAmbitions:UI:UIs", "gameSpeed", "currentGameSpeed", "paused");

    current.ActiveScene = "";
    current.LoadingScene = "";
}

start
{
    return old.ActiveScene == "Intro" && current.ActiveScene == "MainScene";
}

onStart
{
    timer.IsGameTimePaused = true;
}

update
{
    vars.Uhara.Update();
	
	if (!String.IsNullOrWhiteSpace(vars.Utils.GetActiveSceneName())) current.ActiveScene = vars.Utils.GetActiveSceneName();
    if (old.ActiveScene != current.ActiveScene) vars.Uhara.Log("Active Scene: " + old.ActiveScene + " -> " + current.ActiveScene);
}

isLoading
{
    return current.isLoading || current.loadingScreen != IntPtr.Zero || current.GamePaused || current.IngameTimePaused;
}
state("VampireSurvivors")
{
    bool isGameRunning: "GameAssembly.dll", 0x094CAEE8, 0xB8, 0x0, 0x1E9;
}

startup
{
    Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
    vars.Helper.LoadSceneManager = true;
}

start
{
    return current.activeScene == "Gameplay" && old.isGameRunning == false && current.isGameRunning == true;
}

update
{
    if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Active.Name))	current.activeScene = vars.Helper.Scenes.Active.Name;
	if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Loaded[0].Name))	current.loadingScene = vars.Helper.Scenes.Loaded[0].Name;
}

// init
// {
//     var Instance = vars.Uhara.CreateTool("Unity", "Il2Cpp", "Instance");
//     var GM = Instance.Get("VampireSurvivors.Framework.GM", "Core");
//     vars.Helper["Core"] = vars.Helper.Make<IntPtr>(GM.Base, GM.Offsets);

// }

// update
// {
// 	vars.Helper.Update();
//     vars.Helper.MapPointers();

//     print(current.Core.ToString());
// }

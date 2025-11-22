state("The Holy Gosh Darn"){
	// instance "GameAssembly.dll", 0x35DC9A0, 0xB8, 0xF0, 0;
	// bool pauseIsOpen : "GameAssembly.dll", 0x35DC9A0, 0xB8, 0xF0, 0x140, 0x34;
	bool pauseIsOpen : "GameAssembly.dll", 0x35DC9A0, 0xB8, 0x10A;
	bool isTeleporting : "GameAssembly.dll", 0x35DC9A0, 0xB8, 0x1;
	float currentTime : "GameAssembly.dll", 0x35DC9A0, 0xB8, 0xFC;
	bool apartmentIntroDone : "GameAssembly.dll", 0x35DC9A0, 0xB8, 0xF0, 0xB8, 0x31;
	//IntPtr plotpointDatabase : "GameAssembly.dll", 0x35DC9A0, 0xB8, 0xF0, 0x0a0, 0x0D0, 0x18;
}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/asl-help")).CreateInstance("Unity");
	vars.Helper.GameName = "The Holy Gosh Darn";
	vars.Helper.LoadSceneManager = true;
	vars.Helper.AlertLoadless();
	vars.VisitedLevel = new List<string>();

	current.plotpointDatabase = new List<string>();
}

init
{
}

update
{
	// foreach i+ shit to delve into Plot Points which is main compontentry for game splitting and shit


	if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Active.Name))	current.activeScene = vars.Helper.Scenes.Active.Name;
	// if(!String.IsNullOrWhiteSpace(vars.Helper.Scenes.Loaded[0].Name))	current.loadingScene = vars.Helper.Scenes.Loaded[0].Name;

	if(current.activeScene != old.activeScene) vars.Log("active: Old: \"" + old.activeScene + "\", Current: \"" + current.activeScene + "\"");
	// if(current.loadingScene != old.loadingScene) vars.Log("loading: Old: \"" + old.loadingScene + "\", Current: \"" + current.loadingScene + "\"");

	if (old.pauseIsOpen != current.pauseIsOpen) vars.Log("Paused: " + current.pauseIsOpen);
	// if (old.currentTime != current.currentTime) vars.Log("currentTime: " + current.currentTime);
	if (old.isTeleporting != current.isTeleporting) vars.Log("isTeleporting: " + current.isTeleporting);
	if (old.apartmentIntroDone != current.apartmentIntroDone) vars.Log("apartmentIntroDone: " + current.apartmentIntroDone);

	current.abilities = ((List<IntPtr>)current.abilitiesRaw)
    .Select(address =>
    {
      var length = vars.Helper.Read<int>(address + 0x10);
      return vars.Helper.ReadString(length, ReadStringType.UTF16, address + 0x14);
    })
    .ToList();

}
state("LiveSplit") {}

startup
{
	Assembly.Load(File.ReadAllBytes("Components/emu-help-v2")).CreateInstance("PS1");   
}

init
{
	vars.Helper.Load = (Func<dynamic, bool>)(emu => 
	{
		emu.Make<int>("inGame", 0x80012984);
        emu.Make<byte>("MapNo", 0x80013f2a);
        emu.Make<int>("LevelWin", 0x8018d95c);
        emu.Make<byte>("Enemies", 0x80160fa0);
		return true;
	});
}

start
{
	return old.inGame >= 1 && current.inGame == 0;
}

split
{
    return current.Enemies == 0 && old.LevelWin == 0 && current.LevelWin == 1;
}
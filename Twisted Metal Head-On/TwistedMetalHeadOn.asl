state("Livesplit") { }

startup
{
    Assembly.Load(File.ReadAllBytes("Components/emu-help-v3")).CreateInstance("PSP");

    // Base address for PSP is 0x8000000
    vars.CharacterSelection = vars.Helper.Make<int>(0x8A33698);
    vars.Loading = vars.Helper.Make<int>(0x8b369a4);
    vars.Stage = vars.Helper.MakeString(20, 0x8b369ac);
    vars.Enemies = vars.Helper.Make<int>(0x8b650a0);
    vars.InGame = vars.Helper.Make<int>(0x8b36a60);
    vars.Demo = vars.Helper.Make<int>(0x9dfff94);
    vars.VehicleSelected = vars.Helper.Make<int>(0x9e6cff2);

    vars.EnemiesDefeated = false;
}

start
{

}

onStart
{
    vars.EnemiesDefeated = false;
}

update
{
    if (vars.CharacterSelection.Changed) print("Character Selection: " + vars.CharacterSelection.Current);
    if (vars.Loading.Changed) print("Loading: " + vars.Loading.Current);
    if (vars.Enemies.Changed) print("Enemies: " + vars.Enemies.Current);
    if (vars.Stage.Changed) print("Stage: " + vars.Stage.Current);
    if (vars.InGame.Changed) print("InGame: " + vars.InGame.Current);
    if (vars.Demo.Changed) print("Demo: " + vars.Demo.Current);
    if (vars.VehicleSelected.Changed) print("Vehicle Selected: " + vars.VehicleSelected.Current);
}

// split
// {
//     if (vars.InGame == 1 && vars.Enemies.Old != 0 && vars.Enemies.Current == 0)
//     {
//         vars.EnemiesDefeated = true;
//     }
//     if (vars.InGame == 1 && vars.EnemiesDefeated == true && vars.Stage.Changed)
// 	{
// 		vars.EnemiesDefeated = false;
// 		return true;
// 	}
// }
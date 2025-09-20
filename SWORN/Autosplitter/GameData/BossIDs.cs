using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Livesplit.SWORN
{
    public static partial class GameData
    {
        public static List<string> MiniBossIDs { get; } = new List<string>()
        {
            " Questing Beast Arena ",
            " Bane Of Crows Arena ",
            " Mauler Rat Arena ",
            " Raving Blight Arena ",
            " Abyssal Watcher Arena ",
            " Galvanic Witch Arena ",
            // Kiss Curse Portal 
        };

        public static List<string> BossIDs { get; } = new List<string>()
        {
            " Gawain Arena Final ",
            " Lady Bedivere ",
            " Percival Arena ",
            " Arthur Arena ",
            // " Morgana Boss Arena "
        };
    }
}

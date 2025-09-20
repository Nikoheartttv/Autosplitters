using LiveSplit.Model;
using LiveSplit.UI.Components;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace Livesplit.SWORN.UI.Components
{
    public class SWORNComponentFactory : IComponentFactory
    {
        public string ComponentName => "SWORN Autosplitter";

        public string Description => "Autosplitter Component for SWORN - made by Nikoheart";

        public ComponentCategory Category => ComponentCategory.Control;

        public string UpdateName => ComponentName;

        public string XMLURL => String.Empty;

        public string UpdateURL => String.Empty;

        public Version Version => Assembly.GetExecutingAssembly().GetName().Version;

        public IComponent Create(LiveSplitState state) => new SWORNComponent(state);
    }
}

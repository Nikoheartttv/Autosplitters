using LiveSplit.Options;
using LiveSplit.UI;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Xml;
using System.Xml.Linq;
using static System.Windows.Forms.VisualStyles.VisualStyleElement.TextBox;

namespace Livesplit.SWORN.UI.Components
{
    public partial class SWORNAutosplitterSettings : UserControl
    {
        private readonly Dictionary<string, bool> DefaultSettings = new Dictionary<string, bool>()
        {
            { "Splits", true },
                { "Split_DidWin", true },
                { "Split_BossHP", true },
                    { "Split_BossHP_Questing", true },
                    { "Split_BossHP_Treant", true },
                    { "Split_BossHP_SirGawain", true },
                    { "Split_BossHP_Blight", true },
                    { "Split_BossHP_MaulerRat", true },
                    { "Split_BossHP_SirPercival", true },
                    { "Split_BossHP_AbyssalWatcher", true },
                    { "Split_BossHP_GalvanicWitch", true },
                    { "Split_BossHP_LadyBedivere", true },
                    { "Split_BossHP_KingArthur", true },
                    { "Split_BossHP_KingArthurTyrant", false },
                    { "Split_BossHP_Morgana", true },
                    { "Split_BossHP_Morgana2", false },
                { "Split_Room", false },
                    { "SplitException_HubArea", false },
                    { "SplitException_RestShop", false },
                { "Split_Miniboss", false },
                { "Split_Boss", false },
                { "Split_RoundTable", false },
            { "Reset_Lobby", false },
            { "Reset_MainMenu", false }
        };

        private readonly bool StartDefault = true;
        private readonly bool SplitDefault = true;
        private readonly bool ResetDefault = true;


        public bool Start => cbxStart.Checked;
        public bool Split => cbxSplit.Checked;
        public bool Reset => cbxReset.Checked;

        public bool this[string name]
        {
            get
            {
                foreach (TreeNode tnd in GetAllNodes(tvwSettings))
                {
                    if (tnd.Name == name)
                    {
                        return GetNodeValue(tnd);
                    }
                }
                return default;
            }
        }

        public SWORNAutosplitterSettings()
        {
            InitializeComponent();
            SetDefaultSettings();
        }

        public LayoutMode Mode { get; set; }

        public XmlNode GetSettings(XmlDocument document)
        {
            XmlElement settings = document.CreateElement("Settings");

            settings.AppendChild(GetSetting(document, "Start", cbxStart));
            settings.AppendChild(GetSetting(document, "Split", cbxSplit));
            settings.AppendChild(GetSetting(document, "Reset", cbxReset));

            settings.AppendChild(GetSetting(document, "Settings", tvwSettings));

            return settings;
        }

        public void SetSettings(XmlNode settings)
        {
            SuspendLayout();

            SetSetting(settings.SelectSingleNode(".//Start"), cbxStart);
            SetSetting(settings.SelectSingleNode(".//Split"), cbxSplit);
            SetSetting(settings.SelectSingleNode(".//Reset"), cbxReset);

            SetSetting(settings.SelectSingleNode(".//Settings"), tvwSettings);

            ResumeLayout(true);
        }

        private void SetDefaultSettings()
        {
            cbxStart.Checked = StartDefault;
            cbxSplit.Checked = SplitDefault;
            cbxReset.Checked = ResetDefault;

            foreach (TreeNode node in GetAllNodes(tvwSettings))
            {
                if (DefaultSettings.Keys.Contains(node.Name))
                {
                    node.Checked = DefaultSettings[node.Name];
                }
            }
        }

        private XmlElement GetSetting(XmlDocument document, string name, CheckBox control)
        {
            var element = document.CreateElement(name ?? control.Name);
            element.SetAttribute("Value", control.Checked.ToString());
            return element;
        }

        private XmlElement GetSetting(XmlDocument document, string name, TreeView control)
        {
            var element = document.CreateElement(name ?? control.Name);
            foreach (TreeNode node in GetAllNodes(control))
            {
                element.AppendChild(GetSetting(document, node.Name, node));
            }
            return element;
        }

        private XmlElement GetSetting(XmlDocument document, string name, TreeNode control)
        {
            var element = document.CreateElement(name ?? control.Name);
            element.SetAttribute("Value", control.Checked.ToString());
            return element;
        }

        private void SetSetting(XmlNode setting, CheckBox control)
        {
            control.Checked = false;
            if (!bool.TryParse(setting.Attributes["Value"].Value, out var value)) return;
            control.Checked = value;
        }

        private void SetSetting(XmlNode setting, TreeView control)
        {
            foreach (TreeNode node in GetAllNodes(control))
            {
                SetSetting(setting.SelectSingleNode(".//" + node.Name), node);
            }
        }

        private void SetSetting(XmlNode setting, TreeNode control)
        {
            control.Checked = false;
            if (!bool.TryParse(setting.Attributes["Value"].Value, out var value)) return;
            control.Checked = value;
        }

        private IEnumerable<TreeNode> GetAllNodes(TreeView tvw)
        {
            foreach (TreeNode tnd in tvw.Nodes)
            {
                yield return tnd;
                if (tnd.Nodes != null && tnd.Nodes.Count > 0)
                    foreach (TreeNode child in GetAllNodes(tnd))
                        yield return child;
            }
        }

        private IEnumerable<TreeNode> GetAllNodes(TreeNode parent)
        {
            foreach (TreeNode tnd in parent.Nodes)
            {
                yield return tnd;
                if (tnd.Nodes != null && tnd.Nodes.Count > 0)
                    foreach (TreeNode child in GetAllNodes(tnd))
                        yield return child;
            }
        }

        private bool GetNodeValue(TreeNode tnd)
        {
            bool value = true;

            while (value && tnd != null)
            {
                value = tnd.Checked;
                tnd = tnd.Parent;
            }

            return value;
        }

        private void btnCheckAll_Click(object sender, EventArgs e)
        {
            foreach (TreeNode tnd in GetAllNodes(tvwSettings))
            {
                tnd.Checked = true;
            }
        }

        private void btnUncheckAll_Click(object sender, EventArgs e)
        {
            foreach (TreeNode tnd in GetAllNodes(tvwSettings))
            {
                tnd.Checked = false;
            }
        }

        private void btnResetToDefault_Click(object sender, EventArgs e)
        {
            foreach (TreeNode tnd in GetAllNodes(tvwSettings))
            {
                tnd.Checked = DefaultSettings.TryGetValue(tnd.Name, out var value) ? value : false;
            }
        }
    }
}

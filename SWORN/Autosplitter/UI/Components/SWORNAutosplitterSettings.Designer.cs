namespace Livesplit.SWORN.UI.Components
{
    partial class SWORNAutosplitterSettings
    {
        /// <summary> 
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.Windows.Forms.TreeNode treeNode1 = new System.Windows.Forms.TreeNode("Split on Run Completion");
            System.Windows.Forms.TreeNode treeNode2 = new System.Windows.Forms.TreeNode("The Questing Beast");
            System.Windows.Forms.TreeNode treeNode3 = new System.Windows.Forms.TreeNode("The Treant Scourge");
            System.Windows.Forms.TreeNode treeNode4 = new System.Windows.Forms.TreeNode("Gawain, Butcher of Wirral");
            System.Windows.Forms.TreeNode treeNode5 = new System.Windows.Forms.TreeNode("The Raving Blight");
            System.Windows.Forms.TreeNode treeNode6 = new System.Windows.Forms.TreeNode("Mauler Rats");
            System.Windows.Forms.TreeNode treeNode7 = new System.Windows.Forms.TreeNode("Sir Percival, The Pestilent Overseer");
            System.Windows.Forms.TreeNode treeNode8 = new System.Windows.Forms.TreeNode("The Abyssal Watcher");
            System.Windows.Forms.TreeNode treeNode9 = new System.Windows.Forms.TreeNode("The Galvanic Witch");
            System.Windows.Forms.TreeNode treeNode10 = new System.Windows.Forms.TreeNode("Lady Bedivere");
            System.Windows.Forms.TreeNode treeNode11 = new System.Windows.Forms.TreeNode("King Arthur, Lord of Camelot");
            System.Windows.Forms.TreeNode treeNode12 = new System.Windows.Forms.TreeNode("King Arthur, Grail Corrupted Tyrant");
            System.Windows.Forms.TreeNode treeNode13 = new System.Windows.Forms.TreeNode("Morgana, The Mutinous Fae");
            System.Windows.Forms.TreeNode treeNode14 = new System.Windows.Forms.TreeNode("Morgana, The Source Of Corruption");
            System.Windows.Forms.TreeNode treeNode15 = new System.Windows.Forms.TreeNode("Split After: Boss HP=0", new System.Windows.Forms.TreeNode[] {
            treeNode2,
            treeNode3,
            treeNode4,
            treeNode5,
            treeNode6,
            treeNode7,
            treeNode8,
            treeNode9,
            treeNode10,
            treeNode11,
            treeNode12,
            treeNode13,
            treeNode14});
            System.Windows.Forms.TreeNode treeNode16 = new System.Windows.Forms.TreeNode("Excluding Entering/Leaving Hub Area");
            System.Windows.Forms.TreeNode treeNode17 = new System.Windows.Forms.TreeNode("Excluding Rest & Shop Rooms");
            System.Windows.Forms.TreeNode treeNode18 = new System.Windows.Forms.TreeNode("Split After: Every Room", new System.Windows.Forms.TreeNode[] {
            treeNode16,
            treeNode17});
            System.Windows.Forms.TreeNode treeNode19 = new System.Windows.Forms.TreeNode("Split After: Mini-Boss Arena");
            System.Windows.Forms.TreeNode treeNode20 = new System.Windows.Forms.TreeNode("Split After: Boss Arena");
            System.Windows.Forms.TreeNode treeNode21 = new System.Windows.Forms.TreeNode("Split After: Round Table");
            System.Windows.Forms.TreeNode treeNode22 = new System.Windows.Forms.TreeNode("Split Conditions", new System.Windows.Forms.TreeNode[] {
            treeNode1,
            treeNode15,
            treeNode18,
            treeNode19,
            treeNode20,
            treeNode21});
            System.Windows.Forms.TreeNode treeNode23 = new System.Windows.Forms.TreeNode("Reset on Returning to Lobby");
            System.Windows.Forms.TreeNode treeNode24 = new System.Windows.Forms.TreeNode("Reset on Main Menu");
            this.lblOptions = new System.Windows.Forms.Label();
            this.tableLayoutPanel = new System.Windows.Forms.TableLayoutPanel();
            this.pnlOptions = new System.Windows.Forms.Panel();
            this.cbxReset = new System.Windows.Forms.CheckBox();
            this.cbxSplit = new System.Windows.Forms.CheckBox();
            this.cbxStart = new System.Windows.Forms.CheckBox();
            this.pnlButtons = new System.Windows.Forms.Panel();
            this.btnCheckAll = new System.Windows.Forms.Button();
            this.btnUncheckAll = new System.Windows.Forms.Button();
            this.btnResetToDefault = new System.Windows.Forms.Button();
            this.tvwSettings = new System.Windows.Forms.TreeView();
            this.lblAdvanced = new System.Windows.Forms.Label();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.tableLayoutPanel.SuspendLayout();
            this.pnlOptions.SuspendLayout();
            this.pnlButtons.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            this.SuspendLayout();
            // 
            // lblOptions
            // 
            this.lblOptions.Anchor = System.Windows.Forms.AnchorStyles.Left;
            this.lblOptions.Location = new System.Drawing.Point(3, 177);
            this.lblOptions.Name = "lblOptions";
            this.lblOptions.Size = new System.Drawing.Size(64, 23);
            this.lblOptions.TabIndex = 0;
            this.lblOptions.Text = "Options:";
            // 
            // tableLayoutPanel
            // 
            this.tableLayoutPanel.ColumnCount = 2;
            this.tableLayoutPanel.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Absolute, 70F));
            this.tableLayoutPanel.ColumnStyles.Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel.Controls.Add(this.pnlOptions, 1, 1);
            this.tableLayoutPanel.Controls.Add(this.pnlButtons, 1, 3);
            this.tableLayoutPanel.Controls.Add(this.tvwSettings, 1, 2);
            this.tableLayoutPanel.Controls.Add(this.lblAdvanced, 0, 2);
            this.tableLayoutPanel.Controls.Add(this.pictureBox1, 0, 0);
            this.tableLayoutPanel.Controls.Add(this.lblOptions, 0, 1);
            this.tableLayoutPanel.Dock = System.Windows.Forms.DockStyle.Fill;
            this.tableLayoutPanel.Location = new System.Drawing.Point(0, 0);
            this.tableLayoutPanel.Name = "tableLayoutPanel";
            this.tableLayoutPanel.RowCount = 4;
            this.tableLayoutPanel.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 173F));
            this.tableLayoutPanel.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 31F));
            this.tableLayoutPanel.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Percent, 100F));
            this.tableLayoutPanel.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 50F));
            this.tableLayoutPanel.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel.RowStyles.Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType.Absolute, 20F));
            this.tableLayoutPanel.Size = new System.Drawing.Size(470, 550);
            this.tableLayoutPanel.TabIndex = 1;
            // 
            // pnlOptions
            // 
            this.pnlOptions.Controls.Add(this.cbxReset);
            this.pnlOptions.Controls.Add(this.cbxSplit);
            this.pnlOptions.Controls.Add(this.cbxStart);
            this.pnlOptions.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pnlOptions.Location = new System.Drawing.Point(73, 176);
            this.pnlOptions.Name = "pnlOptions";
            this.pnlOptions.Size = new System.Drawing.Size(394, 25);
            this.pnlOptions.TabIndex = 4;
            // 
            // cbxReset
            // 
            this.cbxReset.AutoSize = true;
            this.cbxReset.Dock = System.Windows.Forms.DockStyle.Left;
            this.cbxReset.Location = new System.Drawing.Point(94, 0);
            this.cbxReset.Name = "cbxReset";
            this.cbxReset.Size = new System.Drawing.Size(54, 25);
            this.cbxReset.TabIndex = 2;
            this.cbxReset.Text = "Reset";
            this.cbxReset.UseVisualStyleBackColor = true;
            // 
            // cbxSplit
            // 
            this.cbxSplit.AutoSize = true;
            this.cbxSplit.Dock = System.Windows.Forms.DockStyle.Left;
            this.cbxSplit.Location = new System.Drawing.Point(48, 0);
            this.cbxSplit.Name = "cbxSplit";
            this.cbxSplit.Size = new System.Drawing.Size(46, 25);
            this.cbxSplit.TabIndex = 1;
            this.cbxSplit.Text = "Split";
            this.cbxSplit.UseVisualStyleBackColor = true;
            // 
            // cbxStart
            // 
            this.cbxStart.AutoSize = true;
            this.cbxStart.Dock = System.Windows.Forms.DockStyle.Left;
            this.cbxStart.Location = new System.Drawing.Point(0, 0);
            this.cbxStart.Name = "cbxStart";
            this.cbxStart.Size = new System.Drawing.Size(48, 25);
            this.cbxStart.TabIndex = 0;
            this.cbxStart.Text = "Start";
            this.cbxStart.UseVisualStyleBackColor = true;
            // 
            // pnlButtons
            // 
            this.pnlButtons.Controls.Add(this.btnCheckAll);
            this.pnlButtons.Controls.Add(this.btnUncheckAll);
            this.pnlButtons.Controls.Add(this.btnResetToDefault);
            this.pnlButtons.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pnlButtons.Location = new System.Drawing.Point(73, 503);
            this.pnlButtons.Name = "pnlButtons";
            this.pnlButtons.Padding = new System.Windows.Forms.Padding(0, 10, 10, 10);
            this.pnlButtons.Size = new System.Drawing.Size(394, 44);
            this.pnlButtons.TabIndex = 5;
            // 
            // btnCheckAll
            // 
            this.btnCheckAll.AutoSize = true;
            this.btnCheckAll.Dock = System.Windows.Forms.DockStyle.Right;
            this.btnCheckAll.Location = new System.Drawing.Point(140, 10);
            this.btnCheckAll.Margin = new System.Windows.Forms.Padding(5, 3, 5, 3);
            this.btnCheckAll.Name = "btnCheckAll";
            this.btnCheckAll.Size = new System.Drawing.Size(75, 24);
            this.btnCheckAll.TabIndex = 2;
            this.btnCheckAll.Text = "Check All";
            this.btnCheckAll.UseVisualStyleBackColor = true;
            this.btnCheckAll.Click += new System.EventHandler(this.btnCheckAll_Click);
            // 
            // btnUncheckAll
            // 
            this.btnUncheckAll.AutoSize = true;
            this.btnUncheckAll.Dock = System.Windows.Forms.DockStyle.Right;
            this.btnUncheckAll.Location = new System.Drawing.Point(215, 10);
            this.btnUncheckAll.Margin = new System.Windows.Forms.Padding(5, 3, 5, 3);
            this.btnUncheckAll.Name = "btnUncheckAll";
            this.btnUncheckAll.Size = new System.Drawing.Size(75, 24);
            this.btnUncheckAll.TabIndex = 1;
            this.btnUncheckAll.Text = "Uncheck All";
            this.btnUncheckAll.UseVisualStyleBackColor = true;
            this.btnUncheckAll.Click += new System.EventHandler(this.btnUncheckAll_Click);
            // 
            // btnResetToDefault
            // 
            this.btnResetToDefault.AutoSize = true;
            this.btnResetToDefault.Dock = System.Windows.Forms.DockStyle.Right;
            this.btnResetToDefault.Location = new System.Drawing.Point(290, 10);
            this.btnResetToDefault.Margin = new System.Windows.Forms.Padding(5, 3, 5, 3);
            this.btnResetToDefault.Name = "btnResetToDefault";
            this.btnResetToDefault.Size = new System.Drawing.Size(94, 24);
            this.btnResetToDefault.TabIndex = 0;
            this.btnResetToDefault.Text = "Reset to Default";
            this.btnResetToDefault.UseVisualStyleBackColor = true;
            this.btnResetToDefault.Click += new System.EventHandler(this.btnResetToDefault_Click);
            // 
            // tvwSettings
            // 
            this.tvwSettings.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)));
            this.tvwSettings.CheckBoxes = true;
            this.tvwSettings.Location = new System.Drawing.Point(73, 209);
            this.tvwSettings.Name = "tvwSettings";
            treeNode1.Name = "Split_DidWin";
            treeNode1.Text = "Split on Run Completion";
            treeNode2.Name = "Split_BossHP_Questing";
            treeNode2.Text = "The Questing Beast";
            treeNode3.Name = "Split_BossHP_Treant";
            treeNode3.Text = "The Treant Scourge";
            treeNode4.Name = "Split_BossHP_SirGawain";
            treeNode4.Text = "Gawain, Butcher of Wirral";
            treeNode5.Name = "Split_BossHP_Blight";
            treeNode5.Text = "The Raving Blight";
            treeNode6.Name = "Split_BossHP_MaulerRat";
            treeNode6.Text = "Mauler Rats";
            treeNode7.Name = "Split_BossHP_SirPercival";
            treeNode7.Text = "Sir Percival, The Pestilent Overseer";
            treeNode8.Name = "Split_BossHP_AbyssalWatcher";
            treeNode8.Text = "The Abyssal Watcher";
            treeNode9.Name = "Split_BossHP_GalvanicWitch";
            treeNode9.Text = "The Galvanic Witch";
            treeNode10.Name = "Split_BossHP_LadyBedivere";
            treeNode10.Text = "Lady Bedivere";
            treeNode11.Name = "Split_BossHP_KingArthur";
            treeNode11.Text = "King Arthur, Lord of Camelot";
            treeNode12.Name = "Split_BossHP_KingArthurTyrant";
            treeNode12.Text = "King Arthur, Grail Corrupted Tyrant";
            treeNode13.Name = "Split_BossHP_Morgana";
            treeNode13.Text = "Morgana, The Mutinous Fae";
            treeNode14.Name = "Split_BossHP_Morgana2";
            treeNode14.Text = "Morgana, The Source Of Corruption";
            treeNode15.Name = "Split_BossHP";
            treeNode15.Text = "Split After: Boss HP=0";
            treeNode16.Name = "SplitException_HubArea";
            treeNode16.Text = "Excluding Entering/Leaving Hub Area";
            treeNode17.Name = "SplitException_RestShop";
            treeNode17.Text = "Excluding Rest & Shop Rooms";
            treeNode18.Name = "Split_Room";
            treeNode18.Text = "Split After: Every Room";
            treeNode19.Name = "Split_Miniboss";
            treeNode19.Text = "Split After: Mini-Boss Arena";
            treeNode20.Name = "Split_Boss";
            treeNode20.Text = "Split After: Boss Arena";
            treeNode21.Name = "Split_RoundTable";
            treeNode21.Text = "Split After: Round Table";
            treeNode22.Name = "Splits";
            treeNode22.Text = "Split Conditions";
            treeNode23.Name = "Reset_Lobby";
            treeNode23.Text = "Reset on Returning to Lobby";
            treeNode24.Name = "Reset_MainMenu";
            treeNode24.Text = "Reset on Main Menu";
            this.tvwSettings.Nodes.AddRange(new System.Windows.Forms.TreeNode[] {
            treeNode22,
            treeNode23,
            treeNode24});
            this.tvwSettings.Size = new System.Drawing.Size(394, 288);
            this.tvwSettings.TabIndex = 3;
            // 
            // lblAdvanced
            // 
            this.lblAdvanced.AutoSize = true;
            this.lblAdvanced.Location = new System.Drawing.Point(3, 209);
            this.lblAdvanced.Margin = new System.Windows.Forms.Padding(3, 5, 3, 0);
            this.lblAdvanced.Name = "lblAdvanced";
            this.lblAdvanced.Size = new System.Drawing.Size(59, 13);
            this.lblAdvanced.TabIndex = 1;
            this.lblAdvanced.Text = "Advanced:";
            // 
            // pictureBox1
            // 
            this.pictureBox1.BackgroundImageLayout = System.Windows.Forms.ImageLayout.None;
            this.tableLayoutPanel.SetColumnSpan(this.pictureBox1, 2);
            this.pictureBox1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.pictureBox1.Image = global::Livesplit.SWORN.Properties.Resources.Autosplitter_Static_Asset00;
            this.pictureBox1.Location = new System.Drawing.Point(3, 3);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(464, 167);
            this.pictureBox1.SizeMode = System.Windows.Forms.PictureBoxSizeMode.CenterImage;
            this.pictureBox1.TabIndex = 6;
            this.pictureBox1.TabStop = false;
            // 
            // SWORNAutosplitterSettings
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoSize = true;
            this.Controls.Add(this.tableLayoutPanel);
            this.Name = "SWORNAutosplitterSettings";
            this.Size = new System.Drawing.Size(470, 550);
            this.tableLayoutPanel.ResumeLayout(false);
            this.tableLayoutPanel.PerformLayout();
            this.pnlOptions.ResumeLayout(false);
            this.pnlOptions.PerformLayout();
            this.pnlButtons.ResumeLayout(false);
            this.pnlButtons.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Label lblOptions;
        private System.Windows.Forms.TableLayoutPanel tableLayoutPanel;
        private System.Windows.Forms.Label lblAdvanced;
        private System.Windows.Forms.TreeView tvwSettings;
        private System.Windows.Forms.Panel pnlOptions;
        private System.Windows.Forms.CheckBox cbxReset;
        private System.Windows.Forms.CheckBox cbxSplit;
        private System.Windows.Forms.CheckBox cbxStart;
        private System.Windows.Forms.Panel pnlButtons;
        private System.Windows.Forms.Button btnCheckAll;
        private System.Windows.Forms.Button btnUncheckAll;
        private System.Windows.Forms.Button btnResetToDefault;
        private System.Windows.Forms.PictureBox pictureBox1;
    }
}

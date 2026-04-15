-- tkn_ui_settings.ms
-- SETTINGS Tab para TEKTON UI

try
(
    global tkn_ui_settings_tab
    
    fn tkn_ui_createSettingsTab parent_panel =
    (
        try
        (
            tkn_ui_settings_tab = dotNetObject "System.Windows.Forms.Panel"
            tkn_ui_settings_tab.Size = dotNetObject "System.Drawing.Size" 580 480
            tkn_ui_settings_tab.Location = dotNetObject "System.Drawing.Point" 10 110
            tkn_ui_settings_tab.BackColor = TKN_C_BG
            
            local lbl = dotNetObject "System.Windows.Forms.Label"
            lbl.Text = "SETTINGS - Work in Progress"
            lbl.Location = dotNetObject "System.Drawing.Point" 20 20
            lbl.Size = dotNetObject "System.Drawing.Size" 540 30
            lbl.ForeColor = TKN_C_TEXT
            lbl.BackColor = (dotNetClass "System.Drawing.Color").Transparent
            lbl.Font = dotNetObject "System.Drawing.Font" "Segoe UI" 14.0
            tkn_ui_settings_tab.controls.add lbl
            
            parent_panel.controls.add tkn_ui_settings_tab
            tkn_logInfo "Module loaded: tkn_ui_settings.ms"
        )
        catch (tkn_logError ("createSettingsTab error: " + (getCurrentException())))
    )
)
catch (tkn_logError ("tkn_ui_settings.ms load error: " + (getCurrentException())))

-- tkn_ui_log.ms
-- LOG Tab para TEKTON UI

try
(
    global tkn_ui_log_tab
    
    fn tkn_ui_createLogTab parent_panel =
    (
        try
        (
            tkn_ui_log_tab = dotNetObject "System.Windows.Forms.Panel"
            tkn_ui_log_tab.Size = dotNetObject "System.Drawing.Size" 580 480
            tkn_ui_log_tab.Location = dotNetObject "System.Drawing.Point" 10 110
            tkn_ui_log_tab.BackColor = TKN_C_BG
            
            local lbl = dotNetObject "System.Windows.Forms.Label"
            lbl.Text = "LOG - Work in Progress"
            lbl.Location = dotNetObject "System.Drawing.Point" 20 20
            lbl.Size = dotNetObject "System.Drawing.Size" 540 30
            lbl.ForeColor = TKN_C_TEXT
            lbl.BackColor = (dotNetClass "System.Drawing.Color").Transparent
            lbl.Font = dotNetObject "System.Drawing.Font" "Segoe UI" 14.0
            tkn_ui_log_tab.controls.add lbl
            
            parent_panel.controls.add tkn_ui_log_tab
            tkn_logInfo "Module loaded: tkn_ui_log.ms"
        )
        catch (tkn_logError ("createLogTab error: " + (getCurrentException())))
    )
)
catch (tkn_logError ("tkn_ui_log.ms load error: " + (getCurrentException())))

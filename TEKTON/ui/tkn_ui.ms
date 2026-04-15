-- tkn_ui.ms
-- Panel principal flotante para TEKTON

try
(
    global tkn_ui_floater
    global tkn_ui_main_panel
    global tkn_ui_current_tab = "SYSTEMS"
    
    global TKN_C_BG
    global TKN_C_BG2
    global TKN_C_BORDER
    global TKN_C_TEXT
    global TKN_C_TEXT2
    global TKN_C_ACCENT
    global TKN_C_BLUE
    global TKN_C_YELLOW
    global TKN_C_GREEN
    global TKN_C_RED
    global TKN_C_WHITE
    
TKN_C_BG = (dotNetClass "System.Drawing.Color").FromArgb 19 27 69
TKN_C_BG2 = (dotNetClass "System.Drawing.Color").FromArgb 27 38 96
TKN_C_BORDER = (dotNetClass "System.Drawing.Color").FromArgb 17 35 79
TKN_C_TEXT = (dotNetClass "System.Drawing.Color").FromArgb 224 224 224
TKN_C_TEXT2 = (dotNetClass "System.Drawing.Color").FromArgb 136 136 136
TKN_C_ACCENT = (dotNetClass "System.Drawing.Color").FromArgb 39 168 242
TKN_C_BLUE = (dotNetClass "System.Drawing.Color").FromArgb 10 127 194
TKN_C_YELLOW = (dotNetClass "System.Drawing.Color").FromArgb 255 184 0
TKN_C_GREEN = (dotNetClass "System.Drawing.Color").FromArgb 61 170 92
TKN_C_RED = (dotNetClass "System.Drawing.Color").FromArgb 204 51 0
TKN_C_WHITE = (dotNetClass "System.Drawing.Color").FromArgb 255 255 255
    
    global tkn_ui_loadTab
    global tkn_ui_tab_buttons = #()
    
    fn tkn_ui_loadTab tab_name =
    (
        try
        (
            tkn_ui_current_tab = tab_name
            
            if tkn_ui_systems_tab != undefined then tkn_ui_systems_tab.Visible = false
            if tkn_ui_levels_tab != undefined then tkn_ui_levels_tab.Visible = false
            if tkn_ui_checker_tab != undefined then tkn_ui_checker_tab.Visible = false
            if tkn_ui_compute_tab != undefined then tkn_ui_compute_tab.Visible = false
            if tkn_ui_log_tab != undefined then tkn_ui_log_tab.Visible = false
            if tkn_ui_settings_tab != undefined then tkn_ui_settings_tab.Visible = false
            
            case tab_name of
            (
                "SYSTEMS": if tkn_ui_systems_tab != undefined then tkn_ui_systems_tab.Visible = true
                "LEVELS": if tkn_ui_levels_tab != undefined then tkn_ui_levels_tab.Visible = true
                "CHECKER": if tkn_ui_checker_tab != undefined then tkn_ui_checker_tab.Visible = true
                "COMPUTE": if tkn_ui_compute_tab != undefined then tkn_ui_compute_tab.Visible = true
                "LOG": if tkn_ui_log_tab != undefined then tkn_ui_log_tab.Visible = true
                "SETTINGS": if tkn_ui_settings_tab != undefined then tkn_ui_settings_tab.Visible = true
            )
        )
        catch (tkn_logError ("loadTab error: " + (getCurrentException())))
    )
    
    fn tkn_ui_handleTabClick s e =
    (
        try
        (
            local clicked_tab = s.Tag as string
            tkn_ui_loadTab clicked_tab
            for b in tkn_ui_tab_buttons do
            (
                b.BackColor = if (b.Tag as string) == clicked_tab then TKN_C_ACCENT else TKN_C_BG2
            )
        )
        catch (tkn_logError ("handleTabClick error: " + (getCurrentException())))
    )
    
    fn tkn_ui_handleFormClosed s e =
    (
        try
        (
            callbacks.removeScripts id:#TKN_UI_sel
            tkn_logInfo "UI closed."
        )
        catch()
    )
    
    fn tkn_showUI =
    (
        try
        (
            if tkn_ui_floater != undefined then
            (
                try (tkn_ui_floater.close()) catch()
            )
            
            tkn_ui_floater = dotNetObject "System.Windows.Forms.Form"
            tkn_ui_floater.Text = "TEKTON BIM"
            tkn_ui_floater.Size = dotNetObject "System.Drawing.Size" 600 650
            tkn_ui_floater.BackColor = TKN_C_BG
            tkn_ui_floater.FormBorderStyle = tkn_ui_floater.FormBorderStyle.Sizable
            tkn_ui_floater.StartPosition = tkn_ui_floater.StartPosition.CenterScreen
            
            dotNet.addEventHandler tkn_ui_floater "FormClosed" tkn_ui_handleFormClosed
            
            tkn_ui_main_panel = dotNetObject "System.Windows.Forms.Panel"
            tkn_ui_main_panel.Size = dotNetObject "System.Drawing.Size" 600 650
            tkn_ui_main_panel.Location = dotNetObject "System.Drawing.Point" 0 0
            tkn_ui_main_panel.BackColor = TKN_C_BG
            
            local header_panel = dotNetObject "System.Windows.Forms.Panel"
            header_panel.Size = dotNetObject "System.Drawing.Size" 600 40
            header_panel.Location = dotNetObject "System.Drawing.Point" 0 0
            header_panel.BackColor = TKN_C_BG
            
            local lbl_title = dotNetObject "System.Windows.Forms.Label"
            lbl_title.Text = "TEKTON v1.0"
            lbl_title.Location = dotNetObject "System.Drawing.Point" 20 10
            lbl_title.Size = dotNetObject "System.Drawing.Size" 150 20
            lbl_title.ForeColor = TKN_C_TEXT
            lbl_title.BackColor = (dotNetClass "System.Drawing.Color").Transparent
            header_panel.controls.add lbl_title
            
            local lbl_project = dotNetObject "System.Windows.Forms.Label"
            lbl_project.Text = TEKTON.project_name
            lbl_project.Location = dotNetObject "System.Drawing.Point" 120 10
            lbl_project.Size = dotNetObject "System.Drawing.Size" 200 20
            lbl_project.ForeColor = TKN_C_TEXT
            lbl_project.BackColor = (dotNetClass "System.Drawing.Color").Transparent
            header_panel.controls.add lbl_project
            
            local lbl_err = dotNetObject "System.Windows.Forms.Label"
            lbl_err.Text = "ERR:" + TEKTON.log_count_error as string
            lbl_err.Location = dotNetObject "System.Drawing.Point" 445 10
            lbl_err.Size = dotNetObject "System.Drawing.Size" 60 20
            lbl_err.ForeColor = TKN_C_RED
            lbl_err.BackColor = (dotNetClass "System.Drawing.Color").Transparent
            header_panel.controls.add lbl_err
            
            local lbl_wrn = dotNetObject "System.Windows.Forms.Label"
            lbl_wrn.Text = "WRN:" + TEKTON.log_count_warn as string
            lbl_wrn.Location = dotNetObject "System.Drawing.Point" 520 10
            lbl_wrn.Size = dotNetObject "System.Drawing.Size" 60 20
            lbl_wrn.ForeColor = TKN_C_YELLOW
            lbl_wrn.BackColor = (dotNetClass "System.Drawing.Color").Transparent
            header_panel.controls.add lbl_wrn
            
            local tab_bar = dotNetObject "System.Windows.Forms.Panel"
            tab_bar.Size = dotNetObject "System.Drawing.Size" 600 30
            tab_bar.Location = dotNetObject "System.Drawing.Point" 0 50
            tab_bar.BackColor = TKN_C_BG
            
            local tabs = #("SYSTEMS", "LEVELS", "CHECKER", "COMPUTE", "LOG", "SETTINGS")
            local tab_width = 90
            local x_pos = 20
            
            tkn_ui_tab_buttons = #()
            
            local footer_panel = dotNetObject "System.Windows.Forms.Panel"
            footer_panel.Size = dotNetObject "System.Drawing.Size" 600 30
            footer_panel.Location = dotNetObject "System.Drawing.Point" 0 600
            footer_panel.BackColor = TKN_C_BG2
            
            local lbl_footer = dotNetObject "System.Windows.Forms.Label"
            lbl_footer.Text = "[ INITIALIZE / LOAD PROJECT ]"
            lbl_footer.Location = dotNetObject "System.Drawing.Point" 200 5
            lbl_footer.Size = dotNetObject "System.Drawing.Size" 200 20
            lbl_footer.ForeColor = TKN_C_ACCENT
            lbl_footer.BackColor = (dotNetClass "System.Drawing.Color").Transparent
            footer_panel.controls.add lbl_footer
            
            for tab in tabs do
            (
                local btn = dotNetObject "System.Windows.Forms.Button"
                btn.Text = tab
                btn.Size = dotNetObject "System.Drawing.Size" tab_width 25
                btn.Location = dotNetObject "System.Drawing.Point" x_pos 0
                btn.ForeColor = TKN_C_TEXT
                btn.BackColor = if tab == tkn_ui_current_tab then TKN_C_ACCENT else TKN_C_BG2
                btn.FlatStyle = btn.FlatStyle.Flat
                btn.FlatAppearance.BorderColor = TKN_C_BORDER
                btn.Tag = tab
                tab_bar.controls.add btn
                append tkn_ui_tab_buttons btn
                x_pos = x_pos + tab_width + 5
            )
            
            tkn_ui_main_panel.controls.add header_panel
            tkn_ui_main_panel.controls.add tab_bar
            tkn_ui_main_panel.controls.add footer_panel
            
            for btn in tkn_ui_tab_buttons do
            (
                dotNet.addEventHandler btn "Click" tkn_ui_handleTabClick
            )
            
            tkn_ui_createSystemsTab tkn_ui_main_panel
            tkn_ui_createLevelsTab tkn_ui_main_panel
            tkn_ui_createCheckerTab tkn_ui_main_panel
            --tkn_ui_createComputeTab tkn_ui_main_panel
            --tkn_ui_createLogTab tkn_ui_main_panel
            --tkn_ui_createSettingsTab tkn_ui_main_panel
            
            tkn_ui_loadTab "SYSTEMS"
            
            tkn_ui_floater.controls.add tkn_ui_main_panel
            tkn_ui_floater.show()
            
            tkn_logInfo "UI opened."
        )
        catch (tkn_logError ("showUI error: " + (getCurrentException())))
    )
    
    tkn_logInfo "Module loaded: tkn_ui.ms"
)
catch (tkn_logError ("tkn_ui.ms load error: " + (getCurrentException())))

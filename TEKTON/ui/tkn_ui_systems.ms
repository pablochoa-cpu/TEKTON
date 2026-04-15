-- tkn_ui_systems.ms
-- SYSTEMS Tab para TEKTON UI

try
(
    global tkn_ui_systems_tab
    global tkn_ui_cb_system
    global tkn_ui_cb_family
    global tkn_ui_cb_level
    global tkn_ui_cb_finish
    global tkn_ui_inspector_panel
    global tkn_ui_launcher_panel
    global tkn_selected_obj
    global tkn_ui_sel_lock = false
    
    global prev_sys = 1
    global prev_fam = 1
    global prev_lvl = 1
    global prev_fin = 1
    
    global tkn_ui_onSelectionChanged
    global tkn_ui_onTagClick
    global tkn_ui_onTagByNameClick
    global tkn_ui_onExistingClick
    global tkn_ui_onActionClick
    
    fn tkn_ui_rebuildFamilyDropdown sys_name =
    (
        try
        (
            if tkn_ui_cb_family != undefined then
            (
                tkn_ui_cb_family.items.clear()
                local fam_list = #()
                if sys_name != "" and sys_name != undefined then
                (
                    for i = 1 to TEKTON.family_systems.count do
                    (
                        if (TEKTON.family_systems[i] as string) == sys_name then
                            append fam_list (TEKTON.family_names[i] as string)
                    )
                )
                for f in fam_list do tkn_ui_cb_family.items.add f
                if tkn_ui_cb_family.items.count > 0 then
                (
                    if prev_fam <= tkn_ui_cb_family.items.count then
                        tkn_ui_cb_family.selectedIndex = prev_fam - 1
                    else
                        tkn_ui_cb_family.selectedIndex = 0
                )
            )
        )
        catch (tkn_logError ("rebuildFamilyDropdown error: " + (getCurrentException())))
    )
    
    fn tkn_ui_rebuildLevelDropdown =
    (
        try
        (
            if tkn_ui_cb_level != undefined then
            (
                tkn_ui_cb_level.items.clear()
                for lvl in TEKTON.levels do
                    tkn_ui_cb_level.items.add (lvl[1] as string)
                if tkn_ui_cb_level.items.count > 0 then
                (
                    if prev_lvl <= tkn_ui_cb_level.items.count then
                        tkn_ui_cb_level.selectedIndex = prev_lvl - 1
                    else
                        tkn_ui_cb_level.selectedIndex = 0
                )
            )
        )
        catch (tkn_logError ("rebuildLevelDropdown error: " + (getCurrentException())))
    )
    
    fn tkn_ui_rebuildFinishDropdown =
    (
        try
        (
            if tkn_ui_cb_finish != undefined then
            (
                tkn_ui_cb_finish.items.clear()
                for fin in TEKTON.valid_finishes do
                    tkn_ui_cb_finish.items.add (fin as string)
                if tkn_ui_cb_finish.items.count > 0 then
                (
                    if prev_fin <= tkn_ui_cb_finish.items.count then
                        tkn_ui_cb_finish.selectedIndex = prev_fin - 1
                    else
                        tkn_ui_cb_finish.selectedIndex = 0
                )
            )
        )
        catch (tkn_logError ("rebuildFinishDropdown error: " + (getCurrentException())))
    )
    
    fn tkn_ui_rebuildInspector obj =
    (
        try
        (
            if tkn_ui_inspector_panel != undefined then
            (
                tkn_ui_inspector_panel.controls.clear()
                if obj != undefined and isValidNode obj then
                (
                    local y_pos = 10
                    local lbl_id = dotNetObject "System.Windows.Forms.Label"
                    lbl_id.Text = "ID: " + (tkn_getProperty obj "tkn_id")
                    lbl_id.Location = dotNetObject "System.Drawing.Point" 10 y_pos
                    lbl_id.Size = dotNetObject "System.Drawing.Size" 300 20
                    lbl_id.ForeColor = TKN_C_TEXT
                    lbl_id.BackColor = (dotNetClass "System.Drawing.Color").Transparent
                    tkn_ui_inspector_panel.controls.add lbl_id
                    y_pos = y_pos + 25
                    
                    local lbl_sys = dotNetObject "System.Windows.Forms.Label"
                    lbl_sys.Text = "System: " + (tkn_getProperty obj "tkn_system")
                    lbl_sys.Location = dotNetObject "System.Drawing.Point" 10 y_pos
                    lbl_sys.Size = dotNetObject "System.Drawing.Size" 300 20
                    lbl_sys.ForeColor = TKN_C_TEXT
                    lbl_sys.BackColor = (dotNetClass "System.Drawing.Color").Transparent
                    tkn_ui_inspector_panel.controls.add lbl_sys
                    y_pos = y_pos + 25
                    
                    local lbl_fam = dotNetObject "System.Windows.Forms.Label"
                    lbl_fam.Text = "Family: " + (tkn_getProperty obj "tkn_family")
                    lbl_fam.Location = dotNetObject "System.Drawing.Point" 10 y_pos
                    lbl_fam.Size = dotNetObject "System.Drawing.Size" 300 20
                    lbl_fam.ForeColor = TKN_C_TEXT
                    lbl_fam.BackColor = (dotNetClass "System.Drawing.Color").Transparent
                    tkn_ui_inspector_panel.controls.add lbl_fam
                    y_pos = y_pos + 25
                    
                    local lbl_lvl = dotNetObject "System.Windows.Forms.Label"
                    lbl_lvl.Text = "Level: " + (tkn_getProperty obj "tkn_level")
                    lbl_lvl.Location = dotNetObject "System.Drawing.Point" 10 y_pos
                    lbl_lvl.Size = dotNetObject "System.Drawing.Size" 300 20
                    lbl_lvl.ForeColor = TKN_C_TEXT
                    lbl_lvl.BackColor = (dotNetClass "System.Drawing.Color").Transparent
                    tkn_ui_inspector_panel.controls.add lbl_lvl
                )
            )
        )
        catch (tkn_logError ("rebuildInspector error: " + (getCurrentException())))
    )
    
    fn tkn_ui_onSelectionChanged =
    (
        try
        (
            if tkn_ui_sel_lock then return undefined
            local new_sel = if selection.count > 0 then selection[1] else undefined
            if new_sel != tkn_selected_obj then
            (
                tkn_selected_obj = new_sel
                tkn_ui_rebuildInspector tkn_selected_obj
            )
        )
        catch (tkn_logError ("onSelectionChanged error: " + (getCurrentException())))
    )
    
    fn tkn_ui_onTagClick s e =
    (
        try
        (
            local sys = if tkn_ui_cb_system.selectedIndex >= 0 then (tkn_ui_cb_system.items.item[tkn_ui_cb_system.selectedIndex] as string) else ""
            local fam = if tkn_ui_cb_family.selectedIndex >= 0 then (tkn_ui_cb_family.items.item[tkn_ui_cb_family.selectedIndex] as string) else undefined
            local lvl = if tkn_ui_cb_level.selectedIndex >= 0 then (tkn_ui_cb_level.items.item[tkn_ui_cb_level.selectedIndex] as string) else ""
            local fin = if tkn_ui_cb_finish.selectedIndex >= 0 then (tkn_ui_cb_finish.items.item[tkn_ui_cb_finish.selectedIndex] as string) else ""
            
            if selection.count == 0 then
            (
                tkn_logWarn "No objects selected for tagging."
                return undefined
            )
            
            for obj in selection do
            (
                tkn_tagObject obj sys fam lvl fin
            )
            
            tkn_logInfo ("Tagged " + (selection.count as string) + " objects.")
            tkn_ui_rebuildInspector (if selection.count > 0 then selection[1] else undefined)
        )
        catch (tkn_logError ("onTagClick error: " + (getCurrentException())))
    )
    
    fn tkn_ui_onTagByNameClick s e =
    (
        try
        (
            tkn_logInfo "TAG BY NAME not implemented yet."
        )
        catch (tkn_logError ("onTagByNameClick error: " + (getCurrentException())))
    )
    
    fn tkn_ui_onExistingClick s e =
    (
        try
        (
            tkn_logInfo "EXISTING not implemented yet."
        )
        catch (tkn_logError ("onExistingClick error: " + (getCurrentException())))
    )
    
    fn tkn_ui_onActionClick s e =
    (
        try
        (
            local action = s.Tag as string
            case action of
            (
                "SELECT": tkn_logInfo "SELECT not implemented yet."
                "FREEZE": tkn_logInfo "FREEZE not implemented yet."
                "ISOLATE": tkn_logInfo "ISOLATE not implemented yet."
                "HIDE": tkn_logInfo "HIDE not implemented yet."
                "COLOR": tkn_logInfo "COLOR not implemented yet."
                "UNHIDE ALL": (max unhide all; tkn_logInfo "All objects unhidden.")
            )
        )
        catch (tkn_logError ("onActionClick error: " + (getCurrentException())))
    )
    
    global tkn_ui_launcher_buttons = #()
    
    fn tkn_ui_handleLauncherClick s e =
    (
        try
        (
            local sys_name = s.Tag as string
            tkn_logInfo ("Launcher clicked: " + sys_name)
            
            if tkn_ui_cb_system != undefined then
            (
                for i = 0 to (tkn_ui_cb_system.items.count - 1) do
                (
                    if (tkn_ui_cb_system.items.item[i] as string) == sys_name then
                    (
                        tkn_ui_cb_system.selectedIndex = i
                        tkn_ui_rebuildFamilyDropdown sys_name
                        exit
                    )
                )
            )
        )
        catch (tkn_logError ("handleLauncherClick error: " + (getCurrentException())))
    )
    
    fn tkn_ui_handleSystemChange s e =
    (
        try
        (
            prev_sys = tkn_ui_cb_system.selectedIndex + 1
            tkn_ui_rebuildFamilyDropdown (tkn_ui_cb_system.items.item[tkn_ui_cb_system.selectedIndex] as string)
        )
        catch (tkn_logError ("handleSystemChange error: " + (getCurrentException())))
    )
    
    fn tkn_ui_handleFamilyChange s e =
    (
        try (prev_fam = tkn_ui_cb_family.selectedIndex + 1)
        catch (tkn_logError ("handleFamilyChange error: " + (getCurrentException())))
    )
    
    fn tkn_ui_handleLevelChange s e =
    (
        try (prev_lvl = tkn_ui_cb_level.selectedIndex + 1)
        catch (tkn_logError ("handleLevelChange error: " + (getCurrentException())))
    )
    
    fn tkn_ui_handleFinishChange s e =
    (
        try (prev_fin = tkn_ui_cb_finish.selectedIndex + 1)
        catch (tkn_logError ("handleFinishChange error: " + (getCurrentException())))
    )
    
    fn tkn_ui_rebuildOverview =
    (
        try
        (
            tkn_logInfo "rebuildOverview not implemented yet."
        )
        catch (tkn_logError ("rebuildOverview error: " + (getCurrentException())))
    )
    
    fn tkn_ui_createSystemsTab parent_panel =
    (
        try
        (
            tkn_ui_systems_tab = dotNetObject "System.Windows.Forms.Panel"
            tkn_ui_systems_tab.Size = dotNetObject "System.Drawing.Size" 600 480
            tkn_ui_systems_tab.Location = dotNetObject "System.Drawing.Point" 0 90
            tkn_ui_systems_tab.BackColor = TKN_C_BG
            tkn_ui_systems_tab.Visible = true
            
            local left_panel = dotNetObject "System.Windows.Forms.Panel"
            left_panel.Size = dotNetObject "System.Drawing.Size" 340 480
            left_panel.Location = dotNetObject "System.Drawing.Point" 0 0
            left_panel.BackColor = TKN_C_BG
            
            local lbl_overview = dotNetObject "System.Windows.Forms.Label"
            lbl_overview.Text = "OVERVIEW"
            lbl_overview.Location = dotNetObject "System.Drawing.Point" 10 10
            lbl_overview.Size = dotNetObject "System.Drawing.Size" 320 20
            lbl_overview.ForeColor = TKN_C_ACCENT
            lbl_overview.BackColor = (dotNetClass "System.Drawing.Color").Transparent
            left_panel.controls.add lbl_overview
            
            local y_pos = 40
            
            local lbl_tag = dotNetObject "System.Windows.Forms.Label"
            lbl_tag.Text = "TAG SELECTION"
            lbl_tag.Location = dotNetObject "System.Drawing.Point" 10 y_pos
            lbl_tag.Size = dotNetObject "System.Drawing.Size" 320 20
            lbl_tag.ForeColor = TKN_C_ACCENT
            lbl_tag.BackColor = (dotNetClass "System.Drawing.Color").Transparent
            left_panel.controls.add lbl_tag
            y_pos = y_pos + 25
            
            tkn_ui_cb_system = dotNetObject "System.Windows.Forms.ComboBox"
            tkn_ui_cb_system.Size = dotNetObject "System.Drawing.Size" 320 25
            tkn_ui_cb_system.Location = dotNetObject "System.Drawing.Point" 10 y_pos
            tkn_ui_cb_system.DropDownStyle = tkn_ui_cb_system.DropDownStyle.DropDownList
            tkn_ui_cb_system.ForeColor = TKN_C_TEXT
            tkn_ui_cb_system.BackColor = TKN_C_BG2
            for sys in TEKTON.valid_systems do tkn_ui_cb_system.items.add (sys as string)
            if tkn_ui_cb_system.items.count > 0 then
            (
                if prev_sys <= tkn_ui_cb_system.items.count then
                    tkn_ui_cb_system.selectedIndex = prev_sys - 1
                else
                    tkn_ui_cb_system.selectedIndex = 0
            )
            left_panel.controls.add tkn_ui_cb_system
            y_pos = y_pos + 30
            
            tkn_ui_cb_family = dotNetObject "System.Windows.Forms.ComboBox"
            tkn_ui_cb_family.Size = dotNetObject "System.Drawing.Size" 320 25
            tkn_ui_cb_family.Location = dotNetObject "System.Drawing.Point" 10 y_pos
            tkn_ui_cb_family.DropDownStyle = tkn_ui_cb_family.DropDownStyle.DropDownList
            tkn_ui_cb_family.ForeColor = TKN_C_TEXT
            tkn_ui_cb_family.BackColor = TKN_C_BG2
            left_panel.controls.add tkn_ui_cb_family
            y_pos = y_pos + 30
            
            tkn_ui_cb_level = dotNetObject "System.Windows.Forms.ComboBox"
            tkn_ui_cb_level.Size = dotNetObject "System.Drawing.Size" 320 25
            tkn_ui_cb_level.Location = dotNetObject "System.Drawing.Point" 10 y_pos
            tkn_ui_cb_level.DropDownStyle = tkn_ui_cb_level.DropDownStyle.DropDownList
            tkn_ui_cb_level.ForeColor = TKN_C_TEXT
            tkn_ui_cb_level.BackColor = TKN_C_BG2
            left_panel.controls.add tkn_ui_cb_level
            y_pos = y_pos + 30
            
            tkn_ui_cb_finish = dotNetObject "System.Windows.Forms.ComboBox"
            tkn_ui_cb_finish.Size = dotNetObject "System.Drawing.Size" 320 25
            tkn_ui_cb_finish.Location = dotNetObject "System.Drawing.Point" 10 y_pos
            tkn_ui_cb_finish.DropDownStyle = tkn_ui_cb_finish.DropDownStyle.DropDownList
            tkn_ui_cb_finish.ForeColor = TKN_C_TEXT
            tkn_ui_cb_finish.BackColor = TKN_C_BG2
            left_panel.controls.add tkn_ui_cb_finish
            y_pos = y_pos + 35
            
            tkn_ui_rebuildFamilyDropdown (if tkn_ui_cb_system.selectedIndex >= 0 then (tkn_ui_cb_system.items.item[tkn_ui_cb_system.selectedIndex] as string) else "")
            tkn_ui_rebuildLevelDropdown()
            tkn_ui_rebuildFinishDropdown()
            
            local btn_tag = dotNetObject "System.Windows.Forms.Button"
            btn_tag.Text = "TAG"
            btn_tag.Size = dotNetObject "System.Drawing.Size" 100 25
            btn_tag.Location = dotNetObject "System.Drawing.Point" 10 y_pos
            btn_tag.ForeColor = TKN_C_TEXT
            btn_tag.BackColor = TKN_C_BLUE
            btn_tag.FlatStyle = btn_tag.FlatStyle.Flat
            btn_tag.FlatAppearance.BorderColor = TKN_C_BORDER
            left_panel.controls.add btn_tag
            
            local btn_tag_name = dotNetObject "System.Windows.Forms.Button"
            btn_tag_name.Text = "TAG BY NAME"
            btn_tag_name.Size = dotNetObject "System.Drawing.Size" 100 25
            btn_tag_name.Location = dotNetObject "System.Drawing.Point" 115 y_pos
            btn_tag_name.ForeColor = TKN_C_TEXT
            btn_tag_name.BackColor = TKN_C_BG2
            btn_tag_name.FlatStyle = btn_tag_name.FlatStyle.Flat
            btn_tag_name.FlatAppearance.BorderColor = TKN_C_BORDER
            left_panel.controls.add btn_tag_name
            
            local btn_existing = dotNetObject "System.Windows.Forms.Button"
            btn_existing.Text = "EXISTING"
            btn_existing.Size = dotNetObject "System.Drawing.Size" 100 25
            btn_existing.Location = dotNetObject "System.Drawing.Point" 220 y_pos
            btn_existing.ForeColor = TKN_C_TEXT
            btn_existing.BackColor = TKN_C_BG2
            btn_existing.FlatStyle = btn_existing.FlatStyle.Flat
            btn_existing.FlatAppearance.BorderColor = TKN_C_BORDER
            left_panel.controls.add btn_existing
            y_pos = y_pos + 35
            
            local lbl_inspector = dotNetObject "System.Windows.Forms.Label"
            lbl_inspector.Text = "INSPECTOR"
            lbl_inspector.Location = dotNetObject "System.Drawing.Point" 10 y_pos
            lbl_inspector.Size = dotNetObject "System.Drawing.Size" 320 20
            lbl_inspector.ForeColor = TKN_C_ACCENT
            lbl_inspector.BackColor = (dotNetClass "System.Drawing.Color").Transparent
            left_panel.controls.add lbl_inspector
            y_pos = y_pos + 25
            
            tkn_ui_inspector_panel = dotNetObject "System.Windows.Forms.Panel"
            tkn_ui_inspector_panel.Size = dotNetObject "System.Drawing.Size" 320 100
            tkn_ui_inspector_panel.Location = dotNetObject "System.Drawing.Point" 10 y_pos
            tkn_ui_inspector_panel.BackColor = TKN_C_BG2
            left_panel.controls.add tkn_ui_inspector_panel
            y_pos = y_pos + 110
            
            local lbl_actions = dotNetObject "System.Windows.Forms.Label"
            lbl_actions.Text = "ACTIONS"
            lbl_actions.Location = dotNetObject "System.Drawing.Point" 10 y_pos
            lbl_actions.Size = dotNetObject "System.Drawing.Size" 320 20
            lbl_actions.ForeColor = TKN_C_ACCENT
            lbl_actions.BackColor = (dotNetClass "System.Drawing.Color").Transparent
            left_panel.controls.add lbl_actions
            y_pos = y_pos + 25
            
            local action_btns = #("SELECT", "FREEZE", "ISOLATE", "HIDE", "COLOR", "UNHIDE ALL")
            local x_pos = 10
            
            local right_panel = dotNetObject "System.Windows.Forms.Panel"
            right_panel.Size = dotNetObject "System.Drawing.Size" 238 480
            right_panel.Location = dotNetObject "System.Drawing.Point" 342 0
            right_panel.BackColor = TKN_C_BG
            
            local lbl_launcher = dotNetObject "System.Windows.Forms.Label"
            lbl_launcher.Text = "LAUNCHER"
            lbl_launcher.Location = dotNetObject "System.Drawing.Point" 10 10
            lbl_launcher.Size = dotNetObject "System.Drawing.Size" 220 20
            lbl_launcher.ForeColor = TKN_C_ACCENT
            lbl_launcher.BackColor = (dotNetClass "System.Drawing.Color").Transparent
            right_panel.controls.add lbl_launcher
            
            tkn_ui_launcher_panel = dotNetObject "System.Windows.Forms.Panel"
            tkn_ui_launcher_panel.Size = dotNetObject "System.Drawing.Size" 218 440
            tkn_ui_launcher_panel.Location = dotNetObject "System.Drawing.Point" 10 40
            tkn_ui_launcher_panel.BackColor = TKN_C_BG2
            
            tkn_ui_launcher_buttons = #()
            
            local launcher_y = 10
            local launcher_x = 10
            local col = 0
            
            dotNet.addEventHandler tkn_ui_cb_system "SelectedIndexChanged" tkn_ui_handleSystemChange
            dotNet.addEventHandler tkn_ui_cb_family "SelectedIndexChanged" tkn_ui_handleFamilyChange
            dotNet.addEventHandler tkn_ui_cb_level "SelectedIndexChanged" tkn_ui_handleLevelChange
            dotNet.addEventHandler tkn_ui_cb_finish "SelectedIndexChanged" tkn_ui_handleFinishChange
            
            dotNet.addEventHandler btn_tag "Click" tkn_ui_onTagClick
            dotNet.addEventHandler btn_tag_name "Click" tkn_ui_onTagByNameClick
            dotNet.addEventHandler btn_existing "Click" tkn_ui_onExistingClick
            
            for act in action_btns do
            (
                local btn = dotNetObject "System.Windows.Forms.Button"
                btn.Text = act
                btn.Size = dotNetObject "System.Drawing.Size" 100 25
                btn.Location = dotNetObject "System.Drawing.Point" x_pos y_pos
                btn.ForeColor = TKN_C_TEXT
                btn.BackColor = TKN_C_BG2
                btn.FlatStyle = btn.FlatStyle.Flat
                btn.FlatAppearance.BorderColor = TKN_C_BORDER
                btn.Tag = act
                left_panel.controls.add btn
                dotNet.addEventHandler btn "Click" tkn_ui_onActionClick
                x_pos = x_pos + 105
                if x_pos > 220 then (x_pos = 10; y_pos = y_pos + 30)
            )
            
            for sys in TEKTON.valid_systems do
            (
                local color_data = for c in TEKTON.system_colors where c[1] == sys collect c
                local btn_color = if color_data.count > 0 then ((dotNetClass "System.Drawing.Color").FromArgb color_data[1][2] color_data[1][3] color_data[1][4]) else TKN_C_BG2
                
                local btn = dotNetObject "System.Windows.Forms.Button"
                btn.Text = (substring (sys as string) 1 3)
                btn.Size = dotNetObject "System.Drawing.Size" 60 50
                btn.Location = dotNetObject "System.Drawing.Point" launcher_x launcher_y
                btn.ForeColor = TKN_C_WHITE
                btn.BackColor = btn_color
                btn.FlatStyle = btn.FlatStyle.Flat
                btn.FlatAppearance.BorderColor = TKN_C_BORDER
                btn.Tag = sys
                tkn_ui_launcher_panel.controls.add btn
                append tkn_ui_launcher_buttons btn
                
                col = col + 1
                launcher_x = launcher_x + 65
                if col >= 3 then (col = 0; launcher_x = 10; launcher_y = launcher_y + 55)
            )
            
            for btn in tkn_ui_launcher_buttons do
            (
                dotNet.addEventHandler btn "Click" tkn_ui_handleLauncherClick
            )
            
            right_panel.controls.add tkn_ui_launcher_panel
            
            tkn_ui_systems_tab.controls.add left_panel
            tkn_ui_systems_tab.controls.add right_panel
            parent_panel.controls.add tkn_ui_systems_tab
            
            tkn_ui_rebuildInspector tkn_selected_obj
            
            tkn_logInfo "Module loaded: tkn_ui_systems.ms"
        )
        catch (tkn_logError ("createSystemsTab error: " + (getCurrentException())))
    )
)
catch (tkn_logError ("tkn_ui_systems.ms load error: " + (getCurrentException())))

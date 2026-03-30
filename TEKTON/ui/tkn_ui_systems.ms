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
                    lbl_id.BackColor = drawing.color.transparent
                    tkn_ui_inspector_panel.controls.add lbl_id
                    y_pos = y_pos + 25
                    
                    local lbl_sys = dotNetObject "System.Windows.Forms.Label"
                    lbl_sys.Text = "System: " + (tkn_getProperty obj "tkn_system")
                    lbl_sys.Location = dotNetObject "System.Drawing.Point" 10 y_pos
                    lbl_sys.Size = dotNetObject "System.Drawing.Size" 300 20
                    lbl_sys.ForeColor = TKN_C_TEXT
                    lbl_sys.BackColor = drawing.color.transparent
                    tkn_ui_inspector_panel.controls.add lbl_sys
                    y_pos = y_pos + 25
                    
                    local lbl_fam = dotNetObject "System.Windows.Forms.Label"
                    lbl_fam.Text = "Family: " + (tkn_getProperty obj "tkn_family")
                    lbl_fam.Location = dotNetObject "System.Drawing.Point" 10 y_pos
                    lbl_fam.Size = dotNetObject "System.Drawing.Size" 300 20
                    lbl_fam.ForeColor = TKN_C_TEXT
                    lbl_fam.BackColor = drawing.color.transparent
                    tkn_ui_inspector_panel.controls.add lbl_fam
                    y_pos = y_pos + 25
                    
                    local lbl_lvl = dotNetObject "System.Windows.Forms.Label"
                    lbl_lvl.Text = "Level: " + (tkn_getProperty obj "tkn_level")
                    lbl_lvl.Location = dotNetObject "System.Drawing.Point" 10 y_pos
                    lbl_lvl.Size = dotNetObject "System.Drawing.Size" 300 20
                    lbl_lvl.ForeColor = TKN_C_TEXT
                    lbl_lvl.BackColor = drawing.color.transparent
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
            
            if sys == "" then (messageBox "Select a System first."; return undefined)
            if fam == undefined then (messageBox "Select a Family first."; return undefined)
            if lvl == "" then (messageBox "Select a Level first."; return undefined)
            
            local to_tag = #()
            local to_retag = #()
            for obj in selection do
            (
                local existing_id = tkn_getProperty obj "tkn_id"
                if existing_id == "" then
                    append to_tag obj
                else
                    append to_retag obj
            )
            
            if to_retag.count > 0 then
            (
                local confirm = queryBox ("Re-tag " + to_retag.count as string + " tagged objects?") title:"TEKTON"
                if not confirm then return undefined
            )
            
            tkn_tagMultiple (to_tag + to_retag) sys fam lvl fin "new" "" ""
            tkn_ui_loadTab "SYSTEMS"
        )
        catch (tkn_logError ("onTagClick error: " + (getCurrentException())))
    )
    
    fn tkn_ui_onTagByNameClick s e =
    (
        try
        (
            tkn_tagByName selection
            tkn_ui_loadTab "SYSTEMS"
        )
        catch (tkn_logError ("onTagByNameClick error: " + (getCurrentException())))
    )
    
    fn tkn_ui_onExistingClick s e =
    (
        try
        (
            tkn_tagExisting selection
            tkn_ui_loadTab "SYSTEMS"
        )
        catch (tkn_logError ("onExistingClick error: " + (getCurrentException())))
    )
    
    fn tkn_ui_onActionClick s e =
    (
        try
        (
            local action = s.Tag as string
            local objs = for obj in selection where (tkn_getProperty obj "tkn_id") != "" collect obj
            
            case action of
            (
                "SELECT": tkn_selectBySystem objs
                "FREEZE": for obj in objs do obj.isFrozen = true
                "ISOLATE": (
                    max select none
                    select objs
                    actionMan.executeAction 0 "311"
                )
                "HIDE": for obj in objs do obj.isHidden = true
                "COLOR": tkn_applyColorsBySystem objs
                "UNHIDE": unhide $*
            )
        )
        catch (tkn_logError ("onActionClick error: " + (getCurrentException())))
    )
    
    global tkn_ui_launcher_buttons = #()
    global tkn_ui_vh_buttons = #()
    global tkn_ui_ul_buttons = #()
    
    fn tkn_ui_handleLauncherClick =
    (
        try
        (
            local btn = this
            local sys_name = btn.Tag as string
            local objs = tkn_getObjectsBySystem sys_name
            if objs.count > 0 then
            (
                tkn_ui_sel_lock = true
                select objs
                tkn_ui_sel_lock = false
                if objs.count > 0 then
                (
                    tkn_selected_obj = objs[1]
                    tkn_ui_rebuildInspector tkn_selected_obj
                )
            )
        )
        catch (tkn_logError ("handleLauncherClick error: " + (getCurrentException())))
    )
    
    fn tkn_ui_handleSystemVHClick =
    (
        try
        (
            local btn = this
            local sys_name = btn.Tag as string
            local objs = tkn_getObjectsBySystem sys_name
            local new_state = if objs.count > 0 then (not objs[1].isHidden) else false
            for obj in objs do obj.isHidden = new_state
        )
        catch (tkn_logError ("handleSystemVHClick error: " + (getCurrentException())))
    )
    
    fn tkn_ui_handleSystemULClick =
    (
        try
        (
            local btn = this
            local sys_name = btn.Tag as string
            local objs = tkn_getObjectsBySystem sys_name
            local new_state = if objs.count > 0 then (not objs[1].isFrozen) else false
            for obj in objs do obj.isFrozen = new_state
        )
        catch (tkn_logError ("handleSystemULClick error: " + (getCurrentException())))
    )
    
    fn tkn_ui_createSystemsTab parent_panel =
    (
        try
        (
            tkn_ui_systems_tab = dotNetObject "System.Windows.Forms.Panel"
            tkn_ui_systems_tab.Size = dotNetObject "System.Drawing.Size" 580 480
            tkn_ui_systems_tab.Location = dotNetObject "System.Drawing.Point" 10 110
            tkn_ui_systems_tab.BackColor = TKN_C_BG
            
            local left_panel = dotNetObject "System.Windows.Forms.Panel"
            left_panel.Size = dotNetObject "System.Drawing.Size" 340 480
            left_panel.Location = dotNetObject "System.Drawing.Point" 0 0
            left_panel.BackColor = TKN_C_BG
            left_panel.AutoScroll = true
            
            local y_pos = 10
            local lbl_overview = dotNetObject "System.Windows.Forms.Label"
            lbl_overview.Text = "SYSTEMS OVERVIEW"
            lbl_overview.Location = dotNetObject "System.Drawing.Point" 10 y_pos
            lbl_overview.Size = dotNetObject "System.Drawing.Size" 320 20
            lbl_overview.ForeColor = TKN_C_ACCENT
            lbl_overview.BackColor = drawing.color.transparent
            left_panel.controls.add lbl_overview
            y_pos = y_pos + 30
            
            tkn_ui_vh_buttons = #()
            tkn_ui_ul_buttons = #()
            
            for sys in TEKTON.valid_systems do
            (
                local sys_row = dotNetObject "System.Windows.Forms.Panel"
                sys_row.Size = dotNetObject "System.Drawing.Size" 320 25
                sys_row.Location = dotNetObject "System.Drawing.Point" 10 y_pos
                sys_row.BackColor = drawing.color.transparent
                
                local btn_vh = dotNetObject "System.Windows.Forms.Button"
                btn_vh.Text = "V/H"
                btn_vh.Size = dotNetObject "System.Drawing.Size" 40 20
                btn_vh.Location = dotNetObject "System.Drawing.Point" 0 0
                btn_vh.ForeColor = TKN_C_TEXT
                btn_vh.BackColor = TKN_C_BG2
                btn_vh.FlatStyle = btn_vh.FlatStyle.Flat
                btn_vh.FlatAppearance.BorderColor = TKN_C_BORDER
                btn_vh.Tag = sys
                sys_row.controls.add btn_vh
                append tkn_ui_vh_buttons btn_vh
                
                local btn_ul = dotNetObject "System.Windows.Forms.Button"
                btn_ul.Text = "U/L"
                btn_ul.Size = dotNetObject "System.Drawing.Size" 40 20
                btn_ul.Location = dotNetObject "System.Drawing.Point" 45 0
                btn_ul.ForeColor = TKN_C_TEXT
                btn_ul.BackColor = TKN_C_BG2
                btn_ul.FlatStyle = btn_ul.FlatStyle.Flat
                btn_ul.FlatAppearance.BorderColor = TKN_C_BORDER
                btn_ul.Tag = sys
                sys_row.controls.add btn_ul
                append tkn_ui_ul_buttons btn_ul
                
                local lbl_sys = dotNetObject "System.Windows.Forms.Label"
                lbl_sys.Text = sys as string
                lbl_sys.Location = dotNetObject "System.Drawing.Point" 90 2
                lbl_sys.Size = dotNetObject "System.Drawing.Size" 230 20
                lbl_sys.ForeColor = TKN_C_TEXT2
                lbl_sys.BackColor = drawing.color.transparent
                sys_row.controls.add lbl_sys
                
                left_panel.controls.add sys_row
                y_pos = y_pos + 28
            )
            
            for btn in tkn_ui_vh_buttons do
                on btn click do tkn_ui_handleSystemVHClick.call btn
            
            for btn in tkn_ui_ul_buttons do
                on btn click do tkn_ui_handleSystemULClick.call btn
            
            y_pos = y_pos + 20
            local lbl_tag = dotNetObject "System.Windows.Forms.Label"
            lbl_tag.Text = "TAG SELECTION"
            lbl_tag.Location = dotNetObject "System.Drawing.Point" 10 y_pos
            lbl_tag.Size = dotNetObject "System.Drawing.Size" 320 20
            lbl_tag.ForeColor = TKN_C_ACCENT
            lbl_tag.BackColor = drawing.color.transparent
            left_panel.controls.add lbl_tag
            y_pos = y_pos + 30
            
            tkn_ui_cb_system = dotNetObject "System.Windows.Forms.ComboBox"
            tkn_ui_cb_system.Size = dotNetObject "System.Drawing.Size" 320 25
            tkn_ui_cb_system.Location = dotNetObject "System.Drawing.Point" 10 y_pos
            tkn_ui_cb_system.DropDownStyle = tkn_ui_cb_system.DropDownStyle.DropDownList
            tkn_ui_cb_system.ForeColor = TKN_C_TEXT
            tkn_ui_cb_system.BackColor = TKN_C_BG2
            for s in TEKTON.valid_systems do tkn_ui_cb_system.items.add (s as string)
            if prev_sys <= tkn_ui_cb_system.items.count then tkn_ui_cb_system.selectedIndex = prev_sys - 1
            left_panel.controls.add tkn_ui_cb_system
            y_pos = y_pos + 30
            
            on tkn_ui_cb_system selectedIndexChanged do
            (
                prev_sys = tkn_ui_cb_system.selectedIndex + 1
                local sys_str = tkn_ui_cb_system.items.item[tkn_ui_cb_system.selectedIndex] as string
                tkn_ui_rebuildFamilyDropdown sys_str
            )
            
            tkn_ui_cb_family = dotNetObject "System.Windows.Forms.ComboBox"
            tkn_ui_cb_family.Size = dotNetObject "System.Drawing.Size" 320 25
            tkn_ui_cb_family.Location = dotNetObject "System.Drawing.Point" 10 y_pos
            tkn_ui_cb_family.DropDownStyle = tkn_ui_cb_family.DropDownStyle.DropDownList
            tkn_ui_cb_family.ForeColor = TKN_C_TEXT
            tkn_ui_cb_family.BackColor = TKN_C_BG2
            left_panel.controls.add tkn_ui_cb_family
            y_pos = y_pos + 30
            
            on tkn_ui_cb_family selectedIndexChanged do (prev_fam = tkn_ui_cb_family.selectedIndex + 1)
            
            tkn_ui_cb_level = dotNetObject "System.Windows.Forms.ComboBox"
            tkn_ui_cb_level.Size = dotNetObject "System.Drawing.Size" 320 25
            tkn_ui_cb_level.Location = dotNetObject "System.Drawing.Point" 10 y_pos
            tkn_ui_cb_level.DropDownStyle = tkn_ui_cb_level.DropDownStyle.DropDownList
            tkn_ui_cb_level.ForeColor = TKN_C_TEXT
            tkn_ui_cb_level.BackColor = TKN_C_BG2
            left_panel.controls.add tkn_ui_cb_level
            y_pos = y_pos + 30
            
            on tkn_ui_cb_level selectedIndexChanged do (prev_lvl = tkn_ui_cb_level.selectedIndex + 1)
            
            tkn_ui_cb_finish = dotNetObject "System.Windows.Forms.ComboBox"
            tkn_ui_cb_finish.Size = dotNetObject "System.Drawing.Size" 320 25
            tkn_ui_cb_finish.Location = dotNetObject "System.Drawing.Point" 10 y_pos
            tkn_ui_cb_finish.DropDownStyle = tkn_ui_cb_finish.DropDownStyle.DropDownList
            tkn_ui_cb_finish.ForeColor = TKN_C_TEXT
            tkn_ui_cb_finish.BackColor = TKN_C_BG2
            left_panel.controls.add tkn_ui_cb_finish
            y_pos = y_pos + 35
            
            on tkn_ui_cb_finish selectedIndexChanged do (prev_fin = tkn_ui_cb_finish.selectedIndex + 1)
            
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
            
            on btn_tag click do tkn_ui_onTagClick btn_tag (dotNetObject "System.EventArgs")
            on btn_tag_name click do tkn_ui_onTagByNameClick btn_tag_name (dotNetObject "System.EventArgs")
            on btn_existing click do tkn_ui_onExistingClick btn_existing (dotNetObject "System.EventArgs")
            
            local lbl_inspector = dotNetObject "System.Windows.Forms.Label"
            lbl_inspector.Text = "INSPECTOR"
            lbl_inspector.Location = dotNetObject "System.Drawing.Point" 10 y_pos
            lbl_inspector.Size = dotNetObject "System.Drawing.Size" 320 20
            lbl_inspector.ForeColor = TKN_C_ACCENT
            lbl_inspector.BackColor = drawing.color.transparent
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
            lbl_actions.BackColor = drawing.color.transparent
            left_panel.controls.add lbl_actions
            y_pos = y_pos + 25
            
            local action_btns = #("SELECT", "FREEZE", "ISOLATE", "HIDE", "COLOR", "UNHIDE ALL")
            local x_pos = 10
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
                on btn click do tkn_ui_onActionClick btn (dotNetObject "System.EventArgs")
                x_pos = x_pos + 105
                if x_pos > 220 then (x_pos = 10; y_pos = y_pos + 30)
            )
            
            local right_panel = dotNetObject "System.Windows.Forms.Panel"
            right_panel.Size = dotNetObject "System.Drawing.Size" 238 480
            right_panel.Location = dotNetObject "System.Drawing.Point" 342 0
            right_panel.BackColor = TKN_C_BG
            
            local lbl_launcher = dotNetObject "System.Windows.Forms.Label"
            lbl_launcher.Text = "LAUNCHER"
            lbl_launcher.Location = dotNetObject "System.Drawing.Point" 10 10
            lbl_launcher.Size = dotNetObject "System.Drawing.Size" 220 20
            lbl_launcher.ForeColor = TKN_C_ACCENT
            lbl_launcher.BackColor = drawing.color.transparent
            right_panel.controls.add lbl_launcher
            
            tkn_ui_launcher_panel = dotNetObject "System.Windows.Forms.Panel"
            tkn_ui_launcher_panel.Size = dotNetObject "System.Drawing.Size" 218 440
            tkn_ui_launcher_panel.Location = dotNetObject "System.Drawing.Point" 10 40
            tkn_ui_launcher_panel.BackColor = TKN_C_BG2
            
            tkn_ui_launcher_buttons = #()
            
            local launcher_y = 10
            local launcher_x = 10
            local col = 0
            for sys in TEKTON.valid_systems do
            (
                local color_data = for c in TEKTON.system_colors where c[1] == sys collect c
                local btn_color = if color_data.count > 0 then (dotNetObject "System.Drawing.Color" color_data[1][2] color_data[1][3] color_data[1][4]) else TKN_C_BG2
                
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
                on btn click do tkn_ui_handleLauncherClick.call btn
            
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

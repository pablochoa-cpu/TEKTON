-- =============================================================================
-- TEKTON UI - Tab Systems
-- File: tkn_ui_systems.ms
-- =============================================================================

fn tkn_ui_onSysChanged s e = (
    if tkn_ui_cb_system == undefined then return false
    local sel_sys = tkn_ui_cb_system.SelectedItem
    tkn_ui_cb_family.Items.Clear()
    for i = 1 to TEKTON.family_names.count do (
        if (toLower TEKTON.family_systems[i]) == (toLower sel_sys) then (
            tkn_ui_cb_family.Items.Add TEKTON.family_names[i]
        )
    )
    if tkn_ui_cb_family.Items.Count > 0 then tkn_ui_cb_family.SelectedIndex = 0
)

fn tkn_ui_onTagClick s e = (
    local to_tag   = #()
    local to_retag = #()
    for obj in selection do (
        if (findString obj.name "TKN_LEVEL_") != undefined then continue
        if tkn_isTekton obj then (append to_retag obj) else (append to_tag obj)
    )
    if to_retag.count > 0 then (
        local confirm = queryBox (to_retag.count as string + " object(s) already tagged.\nOverwrite BIM data?") title:"TEKTON"
        if confirm then for obj in to_retag do append to_tag obj
    )
    if to_tag.count == 0 then (
        messageBox "No valid objects to tag." title:"TEKTON"
        return false
    )
    local sys = tkn_ui_cb_system.SelectedItem
    local fam = tkn_ui_cb_family.SelectedItem
    local lvl = tkn_ui_cb_level.SelectedItem
    local fin = tkn_ui_cb_finish.SelectedItem
    tkn_tagMultiple to_tag sys fam lvl finish:fin
    tkn_ui_loadTab 1
)

fn tkn_ui_onExistingClick s e = (
    local untagged = #()
    for obj in objects do (
        if not (tkn_isTekton obj) and (findString obj.name "TKN_") == undefined then (
            append untagged obj
        )
    )
    if untagged.count == 0 then (
        messageBox "No untagged objects in scene." title:"TEKTON"
    ) else (
        select untagged
        messageBox (untagged.count as string + " untagged objects selected.\nSet System/Family/Level and click TAG.") title:"TEKTON"
    )
)

fn tkn_ui_onTagByNameClick s e = (
    local result = selectByName caption:"TEKTON - Select objects to tag" showHidden:false
    if result != undefined and result.count > 0 then select result
)

fn tkn_ui_onLauncherClick s e = (
    try (
        local sys_name = s.Tag as string
        if sys_name == undefined or sys_name == "" then return false

        -- Capture selected object BEFORE any select call
        local cur_sel = tkn_selected_obj

        if cur_sel != undefined and (findString cur_sel.name "TKN_LEVEL_") == undefined then (
            local confirm = queryBox ("Add '" + cur_sel.name + "' to system:\n" + sys_name + "?") title:"TEKTON"
            if confirm then (
                -- Get first family of target system
                local fam = ""
                for i = 1 to TEKTON.family_names.count do (
                    if (toLower TEKTON.family_systems[i]) == (toLower sys_name) then (
                        fam = TEKTON.family_names[i]
                        exit
                    )
                )
                if fam == "" then fam = "generic"
                local lvl = if tkn_ui_cb_level != undefined then tkn_ui_cb_level.SelectedItem else "ground_floor"
                tkn_tagObject cur_sel sys_name fam lvl
                tkn_ui_loadTab 1
                return true
            )
        )

        -- No object selected: select all of this system
        global tkn_ui_sel_lock = true
        local objs = tkn_filterBySystem sys_name
        if objs.count > 0 then select objs
        tkn_ui_sel_lock = false

    ) catch()
)

-- =============================================================================

fn tkn_ui_buildSystems panel = (

    local DN_Label  = dotNetClass "System.Windows.Forms.Label"
    local DN_Button = dotNetClass "System.Windows.Forms.Button"
    local DN_Flat   = dotNetClass "System.Windows.Forms.FlatStyle"
    local DN_CB     = dotNetClass "System.Windows.Forms.ComboBox"
    local DN_Panel  = dotNetClass "System.Windows.Forms.Panel"

    local font_mono  = dotNetObject "System.Drawing.Font" "Courier New" 8
    local font_bold  = dotNetObject "System.Drawing.Font" "Courier New" 8 ((dotNetClass "System.Drawing.FontStyle").Bold)
    local font_small = dotNetObject "System.Drawing.Font" "Courier New" 7
    local font_btn   = dotNetObject "System.Drawing.Font" "Courier New" 7 ((dotNetClass "System.Drawing.FontStyle").Bold)

    -- Preserve dropdown state
    local prev_sys = try (if tkn_ui_cb_system != undefined then tkn_ui_cb_system.SelectedIndex else 0) catch(0)
    local prev_lvl = try (if tkn_ui_cb_level  != undefined then tkn_ui_cb_level.SelectedIndex  else 0) catch(0)
    local prev_fin = try (if tkn_ui_cb_finish != undefined then tkn_ui_cb_finish.SelectedIndex else 0) catch(0)

    -- =========================================================================
    -- LEFT PANEL
    -- =========================================================================

    local pnl_left = dotNetObject DN_Panel
    pnl_left.Location  = dotNetObject "System.Drawing.Point" 0 0
    pnl_left.Size      = dotNetObject "System.Drawing.Size" 340 460
    pnl_left.BackColor = TKN_C_BG2
    panel.Controls.Add pnl_left

    local y = 8

    -- SYSTEMS OVERVIEW
    local lbl_sec1 = dotNetObject DN_Label
    lbl_sec1.Text      = "-- SYSTEMS OVERVIEW --"
    lbl_sec1.Font      = font_bold
    lbl_sec1.ForeColor = TKN_C_ACCENT
    lbl_sec1.BackColor = TKN_C_BG2
    lbl_sec1.Location  = dotNetObject "System.Drawing.Point" 8 y
    lbl_sec1.Size      = dotNetObject "System.Drawing.Size" 324 16
    pnl_left.Controls.Add lbl_sec1
    y += 20

    tkn_listAll()
    for sys in TEKTON.valid_systems do (
        local objs = tkn_filterBySystem sys
        if objs.count == 0 then continue
        local sc = tkn_getSystemColor sys
        local dc = (dotNetClass "System.Drawing.Color").FromArgb sc.r sc.g sc.b
        local sw = dotNetObject DN_Label
        sw.BackColor = dc
        sw.Location  = dotNetObject "System.Drawing.Point" 8 (y+2)
        sw.Size      = dotNetObject "System.Drawing.Size" 10 11
        pnl_left.Controls.Add sw
        local ls = dotNetObject DN_Label
        ls.Text      = (sys + "  [" + objs.count as string + "]")
        ls.Font      = font_mono
        ls.ForeColor = TKN_C_TEXT
        ls.BackColor = TKN_C_BG2
        ls.Location  = dotNetObject "System.Drawing.Point" 22 y
        ls.Size      = dotNetObject "System.Drawing.Size" 310 15
        pnl_left.Controls.Add ls
        y += 15
    )
    y += 8

    -- TAG SELECTION
    local lbl_sec2 = dotNetObject DN_Label
    lbl_sec2.Text      = "-- TAG SELECTION --"
    lbl_sec2.Font      = font_bold
    lbl_sec2.ForeColor = TKN_C_ACCENT
    lbl_sec2.BackColor = TKN_C_BG2
    lbl_sec2.Location  = dotNetObject "System.Drawing.Point" 8 y
    lbl_sec2.Size      = dotNetObject "System.Drawing.Size" 324 16
    pnl_left.Controls.Add lbl_sec2
    y += 20

    fn mkLbl p t f fg bg px py pw = (
        local l = dotNetObject "System.Windows.Forms.Label"
        l.Text=t; l.Font=f; l.ForeColor=fg; l.BackColor=bg
        l.Location=dotNetObject "System.Drawing.Point" px py
        l.Size=dotNetObject "System.Drawing.Size" pw 15
        p.Controls.Add l
    )

    mkLbl pnl_left "SYSTEM" font_small TKN_C_TEXT2 TKN_C_BG2 8 y 55
    global tkn_ui_cb_system = dotNetObject DN_CB
    tkn_ui_cb_system.Font=font_mono; tkn_ui_cb_system.BackColor=TKN_C_BG; tkn_ui_cb_system.ForeColor=TKN_C_TEXT
    tkn_ui_cb_system.Location=dotNetObject "System.Drawing.Point" 65 y
    tkn_ui_cb_system.Size=dotNetObject "System.Drawing.Size" 267 20
    tkn_ui_cb_system.DropDownStyle=(dotNetClass "System.Windows.Forms.ComboBoxStyle").DropDownList
    for s in TEKTON.valid_systems do tkn_ui_cb_system.Items.Add s
    if prev_sys < tkn_ui_cb_system.Items.Count then tkn_ui_cb_system.SelectedIndex = prev_sys else tkn_ui_cb_system.SelectedIndex = 0
    pnl_left.Controls.Add tkn_ui_cb_system
    y += 22

    mkLbl pnl_left "FAMILY" font_small TKN_C_TEXT2 TKN_C_BG2 8 y 55
    global tkn_ui_cb_family = dotNetObject DN_CB
    tkn_ui_cb_family.Font=font_mono; tkn_ui_cb_family.BackColor=TKN_C_BG; tkn_ui_cb_family.ForeColor=TKN_C_TEXT
    tkn_ui_cb_family.Location=dotNetObject "System.Drawing.Point" 65 y
    tkn_ui_cb_family.Size=dotNetObject "System.Drawing.Size" 267 20
    tkn_ui_cb_family.DropDownStyle=(dotNetClass "System.Windows.Forms.ComboBoxStyle").DropDownList
    pnl_left.Controls.Add tkn_ui_cb_family
    y += 22

    mkLbl pnl_left "LEVEL" font_small TKN_C_TEXT2 TKN_C_BG2 8 y 55
    global tkn_ui_cb_level = dotNetObject DN_CB
    tkn_ui_cb_level.Font=font_mono; tkn_ui_cb_level.BackColor=TKN_C_BG; tkn_ui_cb_level.ForeColor=TKN_C_TEXT
    tkn_ui_cb_level.Location=dotNetObject "System.Drawing.Point" 65 y
    tkn_ui_cb_level.Size=dotNetObject "System.Drawing.Size" 267 20
    tkn_ui_cb_level.DropDownStyle=(dotNetClass "System.Windows.Forms.ComboBoxStyle").DropDownList
    for n in TEKTON.levels do tkn_ui_cb_level.Items.Add n[1]
    if prev_lvl < tkn_ui_cb_level.Items.Count then tkn_ui_cb_level.SelectedIndex = prev_lvl else tkn_ui_cb_level.SelectedIndex = 0
    pnl_left.Controls.Add tkn_ui_cb_level
    y += 22

    mkLbl pnl_left "FINISH" font_small TKN_C_TEXT2 TKN_C_BG2 8 y 55
    global tkn_ui_cb_finish = dotNetObject DN_CB
    tkn_ui_cb_finish.Font=font_mono; tkn_ui_cb_finish.BackColor=TKN_C_BG; tkn_ui_cb_finish.ForeColor=TKN_C_TEXT
    tkn_ui_cb_finish.Location=dotNetObject "System.Drawing.Point" 65 y
    tkn_ui_cb_finish.Size=dotNetObject "System.Drawing.Size" 267 20
    tkn_ui_cb_finish.DropDownStyle=(dotNetClass "System.Windows.Forms.ComboBoxStyle").DropDownList
    for f in TEKTON.valid_finishes do tkn_ui_cb_finish.Items.Add f
    if prev_fin < tkn_ui_cb_finish.Items.Count then tkn_ui_cb_finish.SelectedIndex = prev_fin else tkn_ui_cb_finish.SelectedIndex = 0
    pnl_left.Controls.Add tkn_ui_cb_finish
    y += 26

    -- Populate family based on current system
    local cur_sys = tkn_ui_cb_system.SelectedItem
    tkn_ui_cb_family.Items.Clear()
    for i = 1 to TEKTON.family_names.count do (
        if (toLower TEKTON.family_systems[i]) == (toLower cur_sys) then (
            tkn_ui_cb_family.Items.Add TEKTON.family_names[i]
        )
    )
    if tkn_ui_cb_family.Items.Count > 0 then tkn_ui_cb_family.SelectedIndex = 0

    -- Buttons
    local btn_tag = dotNetObject DN_Button
    btn_tag.Text="[ TAG ]"; btn_tag.Font=font_bold
    btn_tag.FlatStyle=DN_Flat.Flat
    btn_tag.FlatAppearance.BorderColor=TKN_C_ACCENT
    btn_tag.BackColor=TKN_C_ACCENT; btn_tag.ForeColor=TKN_C_WHITE
    btn_tag.Location=dotNetObject "System.Drawing.Point" 8 y
    btn_tag.Size=dotNetObject "System.Drawing.Size" 100 24
    pnl_left.Controls.Add btn_tag

    local btn_byname = dotNetObject DN_Button
    btn_byname.Text="[ TAG BY NAME ]"; btn_byname.Font=font_bold
    btn_byname.FlatStyle=DN_Flat.Flat
    btn_byname.FlatAppearance.BorderColor=TKN_C_BLUE
    btn_byname.BackColor=TKN_C_BG; btn_byname.ForeColor=TKN_C_BLUE
    btn_byname.Location=dotNetObject "System.Drawing.Point" 114 y
    btn_byname.Size=dotNetObject "System.Drawing.Size" 120 24
    pnl_left.Controls.Add btn_byname

    local btn_existing = dotNetObject DN_Button
    btn_existing.Text="[ EXISTING ]"; btn_existing.Font=font_bold
    btn_existing.FlatStyle=DN_Flat.Flat
    btn_existing.FlatAppearance.BorderColor=TKN_C_TEXT2
    btn_existing.BackColor=TKN_C_BG; btn_existing.ForeColor=TKN_C_TEXT2
    btn_existing.Location=dotNetObject "System.Drawing.Point" 240 y
    btn_existing.Size=dotNetObject "System.Drawing.Size" 92 24
    pnl_left.Controls.Add btn_existing
    y += 30

    dotNet.addEventHandler tkn_ui_cb_system "SelectedIndexChanged" tkn_ui_onSysChanged
    dotNet.addEventHandler btn_tag          "Click"                 tkn_ui_onTagClick
    dotNet.addEventHandler btn_byname       "Click"                 tkn_ui_onTagByNameClick
    dotNet.addEventHandler btn_existing     "Click"                 tkn_ui_onExistingClick

    -- INSPECTOR
    local lbl_sec3 = dotNetObject DN_Label
    lbl_sec3.Text="-- INSPECTOR --"; lbl_sec3.Font=font_bold
    lbl_sec3.ForeColor=TKN_C_ACCENT; lbl_sec3.BackColor=TKN_C_BG2
    lbl_sec3.Location=dotNetObject "System.Drawing.Point" 8 y
    lbl_sec3.Size=dotNetObject "System.Drawing.Size" 324 16
    pnl_left.Controls.Add lbl_sec3
    y += 20

    if tkn_selected_obj != undefined and (tkn_isTekton tkn_selected_obj) then (
        local props = tkn_getAllPropsComplete tkn_selected_obj
        for prop in props do (
            local lp = dotNetObject DN_Label
            lp.Text      = (prop[1] + ":  " + prop[2] as string)
            lp.Font      = font_mono
            lp.ForeColor = TKN_C_TEXT
            lp.BackColor = TKN_C_BG2
            lp.Location  = dotNetObject "System.Drawing.Point" 8 y
            lp.Size      = dotNetObject "System.Drawing.Size" 324 15
            pnl_left.Controls.Add lp
            y += 15
        )
    ) else (
        local lns = dotNetObject DN_Label
        lns.Text      = "Select a tagged object to inspect."
        lns.Font      = font_mono
        lns.ForeColor = TKN_C_TEXT2
        lns.BackColor = TKN_C_BG2
        lns.Location  = dotNetObject "System.Drawing.Point" 8 y
        lns.Size      = dotNetObject "System.Drawing.Size" 324 15
        pnl_left.Controls.Add lns
    )

    -- =========================================================================
    -- RIGHT PANEL - 3x7 launcher grid
    -- =========================================================================

    local pnl_right = dotNetObject DN_Panel
    pnl_right.Location  = dotNetObject "System.Drawing.Point" 342 0
    pnl_right.Size      = dotNetObject "System.Drawing.Size" 238 460
    pnl_right.BackColor = TKN_C_BG
    panel.Controls.Add pnl_right

    local lbl_r = dotNetObject DN_Label
    lbl_r.Text="-- SYSTEMS --"; lbl_r.Font=font_bold
    lbl_r.ForeColor=TKN_C_ACCENT; lbl_r.BackColor=TKN_C_BG
    lbl_r.Location=dotNetObject "System.Drawing.Point" 4 6
    lbl_r.Size=dotNetObject "System.Drawing.Size" 230 14
    pnl_right.Controls.Add lbl_r

    local sys_labels = #("STRUCT","STEEL","MASONRY","FOUND","INSUL","FLOOR","PLASTER","CLAD","ROOF","OPENINGS","METAL","PLUMBING","DRAINAGE","ELEC","GAS","SITE","EQUIP","VEGET","GENERIC")

    local btn_w   = 74
    local btn_h   = 56
    local gap     = 3
    local start_y = 24

    for i = 1 to TEKTON.valid_systems.count do (
        local sys      = TEKTON.valid_systems[i]
        local lbl      = sys_labels[i]
        local objs     = tkn_filterBySystem sys
        local has_objs = objs.count > 0
        local sc       = tkn_getSystemColor sys
        local dc       = (dotNetClass "System.Drawing.Color").FromArgb sc.r sc.g sc.b
        local dim      = (dotNetClass "System.Drawing.Color").FromArgb (sc.r/5) (sc.g/5) (sc.b/5)

        local col_i = mod (i-1) 3
        local row_i = (i-1) / 3
        local bx    = gap + col_i * (btn_w + gap)
        local btn_y = start_y + row_i * (btn_h + gap)

        local btn = dotNetObject DN_Button
        btn.Text      = (lbl + "\n" + (if has_objs then ("[" + objs.count as string + "]") else "---"))
        btn.Font      = font_btn
        btn.FlatStyle = DN_Flat.Flat
        btn.FlatAppearance.BorderColor = dc
        btn.BackColor = if has_objs then dim else TKN_C_BG
        btn.ForeColor = if has_objs then dc else TKN_C_TEXT2
        btn.Location  = dotNetObject "System.Drawing.Point" bx btn_y
        btn.Size      = dotNetObject "System.Drawing.Size" btn_w btn_h
        btn.Tag       = dotNetObject "System.String" sys
        pnl_right.Controls.Add btn

        dotNet.addEventHandler btn "Click" tkn_ui_onLauncherClick
    )
)

tkn_logInfo "Module loaded: tkn_ui_systems.ms"

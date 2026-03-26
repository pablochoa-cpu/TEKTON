-- =============================================================================
-- TEKTON UI - Tab Systems
-- File: tkn_ui_systems.ms
-- =============================================================================

-- Event handlers as global functions (MAXScript dotNet requirement)
fn tkn_ui_onSysChanged s e = (
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
    if selection.count == 0 then (
        messageBox "No objects selected." title:"TEKTON"
    ) else (
        local sys = tkn_ui_cb_system.SelectedItem
        local fam = tkn_ui_cb_family.SelectedItem
        local lvl = tkn_ui_cb_level.SelectedItem
        local fin = tkn_ui_cb_finish.SelectedItem
        tkn_tagSelection sys fam lvl finish:fin
        tkn_ui_loadTab 1
    )
)

fn tkn_ui_onExistingClick s e = (
    local untagged = #()
    for obj in objects do (
        if not (tkn_isTekton obj) then append untagged obj
    )
    if untagged.count == 0 then (
        messageBox "No untagged objects in scene." title:"TEKTON"
    ) else (
        select untagged
        messageBox (untagged.count as string + " untagged objects selected.\nSet System/Family/Level and click TAG SELECTION.") title:"TEKTON"
    )
)

-- =============================================================================

fn tkn_ui_buildSystems panel = (

    local DN_Label  = dotNetClass "System.Windows.Forms.Label"
    local DN_Button = dotNetClass "System.Windows.Forms.Button"
    local DN_Flat   = dotNetClass "System.Windows.Forms.FlatStyle"
    local DN_CB     = dotNetClass "System.Windows.Forms.ComboBox"
    local DN_Font   = "System.Drawing.Font"

    local font_mono  = dotNetObject DN_Font "Courier New" 8
    local font_bold  = dotNetObject DN_Font "Courier New" 8 ((dotNetClass "System.Drawing.FontStyle").Bold)
    local font_small = dotNetObject DN_Font "Courier New" 7

    local y = 8

    -- SYSTEMS OVERVIEW
    local lbl_sec1 = dotNetObject DN_Label
    lbl_sec1.Text      = "-- SYSTEMS OVERVIEW --"
    lbl_sec1.Font      = font_bold
    lbl_sec1.ForeColor = TKN_C_ACCENT
    lbl_sec1.BackColor = TKN_C_BG2
    lbl_sec1.Location  = dotNetObject "System.Drawing.Point" 8 y
    lbl_sec1.Size      = dotNetObject "System.Drawing.Size" 560 16
    panel.Controls.Add lbl_sec1
    y += 20

    tkn_listAll()
    for sys in TEKTON.valid_systems do (
        local objs = tkn_filterBySystem sys
        if objs.count == 0 then continue

        local sys_color = tkn_getSystemColor sys
        local dn_color  = (dotNetClass "System.Drawing.Color").FromArgb sys_color.r sys_color.g sys_color.b

        local lbl_swatch = dotNetObject DN_Label
        lbl_swatch.BackColor = dn_color
        lbl_swatch.Location  = dotNetObject "System.Drawing.Point" 8 y
        lbl_swatch.Size      = dotNetObject "System.Drawing.Size" 12 14
        panel.Controls.Add lbl_swatch

        local lbl_sys = dotNetObject DN_Label
        lbl_sys.Text      = (sys + "   [" + objs.count as string + "]")
        lbl_sys.Font      = font_mono
        lbl_sys.ForeColor = TKN_C_TEXT
        lbl_sys.BackColor = TKN_C_BG2
        lbl_sys.Location  = dotNetObject "System.Drawing.Point" 26 y
        lbl_sys.Size      = dotNetObject "System.Drawing.Size" 540 16
        panel.Controls.Add lbl_sys
        y += 18
    )
    y += 8

    -- TAG SELECTION
    local lbl_sec2 = dotNetObject DN_Label
    lbl_sec2.Text      = "-- TAG SELECTION --"
    lbl_sec2.Font      = font_bold
    lbl_sec2.ForeColor = TKN_C_ACCENT
    lbl_sec2.BackColor = TKN_C_BG2
    lbl_sec2.Location  = dotNetObject "System.Drawing.Point" 8 y
    lbl_sec2.Size      = dotNetObject "System.Drawing.Size" 560 16
    panel.Controls.Add lbl_sec2
    y += 20

    -- SYSTEM label + dropdown
    local lbl_sys_d = dotNetObject DN_Label
    lbl_sys_d.Text = "SYSTEM"
    lbl_sys_d.Font = font_small
    lbl_sys_d.ForeColor = TKN_C_TEXT2
    lbl_sys_d.BackColor = TKN_C_BG2
    lbl_sys_d.Location = dotNetObject "System.Drawing.Point" 8 y
    lbl_sys_d.Size = dotNetObject "System.Drawing.Size" 70 16
    panel.Controls.Add lbl_sys_d

    global tkn_ui_cb_system = dotNetObject DN_CB
    tkn_ui_cb_system.Font = font_mono
    tkn_ui_cb_system.BackColor = TKN_C_BG
    tkn_ui_cb_system.ForeColor = TKN_C_TEXT
    tkn_ui_cb_system.Location = dotNetObject "System.Drawing.Point" 80 y
    tkn_ui_cb_system.Size = dotNetObject "System.Drawing.Size" 490 20
    tkn_ui_cb_system.DropDownStyle = (dotNetClass "System.Windows.Forms.ComboBoxStyle").DropDownList
    for s in TEKTON.valid_systems do tkn_ui_cb_system.Items.Add s
    tkn_ui_cb_system.SelectedIndex = 0
    panel.Controls.Add tkn_ui_cb_system
    y += 22

    -- FAMILY label + dropdown
    local lbl_fam_d = dotNetObject DN_Label
    lbl_fam_d.Text = "FAMILY"
    lbl_fam_d.Font = font_small
    lbl_fam_d.ForeColor = TKN_C_TEXT2
    lbl_fam_d.BackColor = TKN_C_BG2
    lbl_fam_d.Location = dotNetObject "System.Drawing.Point" 8 y
    lbl_fam_d.Size = dotNetObject "System.Drawing.Size" 70 16
    panel.Controls.Add lbl_fam_d

    global tkn_ui_cb_family = dotNetObject DN_CB
    tkn_ui_cb_family.Font = font_mono
    tkn_ui_cb_family.BackColor = TKN_C_BG
    tkn_ui_cb_family.ForeColor = TKN_C_TEXT
    tkn_ui_cb_family.Location = dotNetObject "System.Drawing.Point" 80 y
    tkn_ui_cb_family.Size = dotNetObject "System.Drawing.Size" 490 20
    tkn_ui_cb_family.DropDownStyle = (dotNetClass "System.Windows.Forms.ComboBoxStyle").DropDownList
    panel.Controls.Add tkn_ui_cb_family
    y += 22

    -- LEVEL label + dropdown
    local lbl_lvl_d = dotNetObject DN_Label
    lbl_lvl_d.Text = "LEVEL"
    lbl_lvl_d.Font = font_small
    lbl_lvl_d.ForeColor = TKN_C_TEXT2
    lbl_lvl_d.BackColor = TKN_C_BG2
    lbl_lvl_d.Location = dotNetObject "System.Drawing.Point" 8 y
    lbl_lvl_d.Size = dotNetObject "System.Drawing.Size" 70 16
    panel.Controls.Add lbl_lvl_d

    global tkn_ui_cb_level = dotNetObject DN_CB
    tkn_ui_cb_level.Font = font_mono
    tkn_ui_cb_level.BackColor = TKN_C_BG
    tkn_ui_cb_level.ForeColor = TKN_C_TEXT
    tkn_ui_cb_level.Location = dotNetObject "System.Drawing.Point" 80 y
    tkn_ui_cb_level.Size = dotNetObject "System.Drawing.Size" 490 20
    tkn_ui_cb_level.DropDownStyle = (dotNetClass "System.Windows.Forms.ComboBoxStyle").DropDownList
    for n in TEKTON.levels do tkn_ui_cb_level.Items.Add n[1]
    tkn_ui_cb_level.SelectedIndex = 0
    panel.Controls.Add tkn_ui_cb_level
    y += 22

    -- FINISH label + dropdown
    local lbl_fin_d = dotNetObject DN_Label
    lbl_fin_d.Text = "FINISH"
    lbl_fin_d.Font = font_small
    lbl_fin_d.ForeColor = TKN_C_TEXT2
    lbl_fin_d.BackColor = TKN_C_BG2
    lbl_fin_d.Location = dotNetObject "System.Drawing.Point" 8 y
    lbl_fin_d.Size = dotNetObject "System.Drawing.Size" 70 16
    panel.Controls.Add lbl_fin_d

    global tkn_ui_cb_finish = dotNetObject DN_CB
    tkn_ui_cb_finish.Font = font_mono
    tkn_ui_cb_finish.BackColor = TKN_C_BG
    tkn_ui_cb_finish.ForeColor = TKN_C_TEXT
    tkn_ui_cb_finish.Location = dotNetObject "System.Drawing.Point" 80 y
    tkn_ui_cb_finish.Size = dotNetObject "System.Drawing.Size" 490 20
    tkn_ui_cb_finish.DropDownStyle = (dotNetClass "System.Windows.Forms.ComboBoxStyle").DropDownList
    for f in TEKTON.valid_finishes do tkn_ui_cb_finish.Items.Add f
    tkn_ui_cb_finish.SelectedIndex = 0
    panel.Controls.Add tkn_ui_cb_finish
    y += 26

    -- Buttons
    local btn_tag = dotNetObject DN_Button
    btn_tag.Text = "[ TAG SELECTION ]"
    btn_tag.Font = font_bold
    btn_tag.FlatStyle = DN_Flat.Flat
    btn_tag.FlatAppearance.BorderColor = TKN_C_ACCENT
    btn_tag.BackColor = TKN_C_ACCENT
    btn_tag.ForeColor = TKN_C_WHITE
    btn_tag.Location = dotNetObject "System.Drawing.Point" 8 y
    btn_tag.Size = dotNetObject "System.Drawing.Size" 270 24
    btn_tag.Cursor = (dotNetClass "System.Windows.Forms.Cursors").Hand
    panel.Controls.Add btn_tag

    local btn_existing = dotNetObject DN_Button
    btn_existing.Text = "[ TAG EXISTING... ]"
    btn_existing.Font = font_bold
    btn_existing.FlatStyle = DN_Flat.Flat
    btn_existing.FlatAppearance.BorderColor = TKN_C_BLUE
    btn_existing.BackColor = TKN_C_BG
    btn_existing.ForeColor = TKN_C_BLUE
    btn_existing.Location = dotNetObject "System.Drawing.Point" 286 y
    btn_existing.Size = dotNetObject "System.Drawing.Size" 284 24
    btn_existing.Cursor = (dotNetClass "System.Windows.Forms.Cursors").Hand
    panel.Controls.Add btn_existing
    y += 30

    -- Wire events
    dotNet.addEventHandler tkn_ui_cb_system "SelectedIndexChanged" tkn_ui_onSysChanged
    dotNet.addEventHandler btn_tag           "Click"                tkn_ui_onTagClick
    dotNet.addEventHandler btn_existing      "Click"                tkn_ui_onExistingClick

    -- Populate family on load
    tkn_ui_onSysChanged undefined undefined

    -- INSPECTOR
    y += 4
    local lbl_sec3 = dotNetObject DN_Label
    lbl_sec3.Text = "-- INSPECTOR --"
    lbl_sec3.Font = font_bold
    lbl_sec3.ForeColor = TKN_C_ACCENT
    lbl_sec3.BackColor = TKN_C_BG2
    lbl_sec3.Location = dotNetObject "System.Drawing.Point" 8 y
    lbl_sec3.Size = dotNetObject "System.Drawing.Size" 560 16
    panel.Controls.Add lbl_sec3
    y += 20

    if tkn_selected_obj != undefined and (tkn_isTekton tkn_selected_obj) then (
        local props = tkn_getAllPropsComplete tkn_selected_obj
        for prop in props do (
            local lbl_prop = dotNetObject DN_Label
            lbl_prop.Text = (prop[1] + ":  " + prop[2])
            lbl_prop.Font = font_mono
            lbl_prop.ForeColor = TKN_C_TEXT
            lbl_prop.BackColor = TKN_C_BG2
            lbl_prop.Location = dotNetObject "System.Drawing.Point" 8 y
            lbl_prop.Size = dotNetObject "System.Drawing.Size" 560 16
            panel.Controls.Add lbl_prop
            y += 16
        )
    ) else (
        local lbl_no_sel = dotNetObject DN_Label
        lbl_no_sel.Text = "Select a tagged object to inspect."
        lbl_no_sel.Font = font_mono
        lbl_no_sel.ForeColor = TKN_C_TEXT2
        lbl_no_sel.BackColor = TKN_C_BG2
        lbl_no_sel.Location = dotNetObject "System.Drawing.Point" 8 y
        lbl_no_sel.Size = dotNetObject "System.Drawing.Size" 560 16
        panel.Controls.Add lbl_no_sel
    )
)

tkn_logInfo "Module loaded: tkn_ui_systems.ms"
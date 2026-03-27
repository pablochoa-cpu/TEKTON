-- =============================================================================
-- TEKTON UI - Main Panel
-- File: tkn_ui.ms
-- =============================================================================

global tkn_ui_dialog    = undefined
global tkn_active_tab   = 1
global tkn_selected_obj = undefined
global tkn_ui_sel_lock  = false

global TKN_C_BG     = (dotNetClass "System.Drawing.Color").FromArgb 19  27  69
global TKN_C_BG2    = (dotNetClass "System.Drawing.Color").FromArgb 28  38  90
global TKN_C_BORDER = (dotNetClass "System.Drawing.Color").FromArgb 17  35  79
global TKN_C_TEXT   = (dotNetClass "System.Drawing.Color").FromArgb 224 224 224
global TKN_C_TEXT2  = (dotNetClass "System.Drawing.Color").FromArgb 136 136 136
global TKN_C_ACCENT = (dotNetClass "System.Drawing.Color").FromArgb 39  168 242
global TKN_C_BLUE   = (dotNetClass "System.Drawing.Color").FromArgb 10  127 194
global TKN_C_YELLOW = (dotNetClass "System.Drawing.Color").FromArgb 255 184 0
global TKN_C_GREEN  = (dotNetClass "System.Drawing.Color").FromArgb 61  170 92
global TKN_C_RED    = (dotNetClass "System.Drawing.Color").FromArgb 204 51  0
global TKN_C_WHITE  = (dotNetClass "System.Drawing.Color").FromArgb 255 255 255

-- =============================================================================

fn tkn_ui_setActiveTab idx = (
    tkn_active_tab = idx
    try (
        tkn_main_rollout.btn_tab1.BackColor = if idx == 1 then TKN_C_ACCENT else TKN_C_BG2
        tkn_main_rollout.btn_tab2.BackColor = if idx == 2 then TKN_C_ACCENT else TKN_C_BG2
        tkn_main_rollout.btn_tab3.BackColor = if idx == 3 then TKN_C_ACCENT else TKN_C_BG2
        tkn_main_rollout.btn_tab4.BackColor = if idx == 4 then TKN_C_ACCENT else TKN_C_BG2
        tkn_main_rollout.btn_tab5.BackColor = if idx == 5 then TKN_C_ACCENT else TKN_C_BG2
        tkn_main_rollout.btn_tab6.BackColor = if idx == 6 then TKN_C_ACCENT else TKN_C_BG2
    ) catch()
)

fn tkn_ui_loadTab idx = (
    if tkn_ui_dialog == undefined then return false
    tkn_ui_setActiveTab idx
    tkn_main_rollout.pnl_content.Controls.Clear()
    case idx of (
        1: if tkn_ui_buildSystems  != undefined then tkn_ui_buildSystems  tkn_main_rollout.pnl_content
        2: if tkn_ui_buildLevels   != undefined then tkn_ui_buildLevels   tkn_main_rollout.pnl_content
        3: if tkn_ui_buildChecker  != undefined then tkn_ui_buildChecker  tkn_main_rollout.pnl_content
        4: if tkn_ui_buildCompute  != undefined then tkn_ui_buildCompute  tkn_main_rollout.pnl_content
        5: if tkn_ui_buildLog      != undefined then tkn_ui_buildLog      tkn_main_rollout.pnl_content
        6: if tkn_ui_buildSettings != undefined then tkn_ui_buildSettings tkn_main_rollout.pnl_content
    )
)

fn tkn_ui_onSelectionChanged = (
    if tkn_ui_sel_lock == true then return false
    local new_sel = if selection.count == 1 then selection[1] else undefined
    if new_sel == tkn_selected_obj then return false
    tkn_selected_obj = new_sel
    if tkn_active_tab == 1 and tkn_ui_dialog != undefined then (
        try (
            tkn_main_rollout.pnl_content.Controls.Clear()
            tkn_ui_buildSystems tkn_main_rollout.pnl_content
        ) catch()
    )
)

-- =============================================================================
-- ROLLOUT
-- =============================================================================

rollout tkn_main_rollout "TEKTON BIM" (

    dotNetControl lbl_header  "System.Windows.Forms.Label"  pos:[8,6]   width:420 height:22
    dotNetControl lbl_errors  "System.Windows.Forms.Label"  pos:[434,6] width:80  height:22
    dotNetControl lbl_warns   "System.Windows.Forms.Label"  pos:[516,6] width:70  height:22

    dotNetControl btn_tab1 "System.Windows.Forms.Button" pos:[8,32]   width:90 height:22
    dotNetControl btn_tab2 "System.Windows.Forms.Button" pos:[100,32] width:90 height:22
    dotNetControl btn_tab3 "System.Windows.Forms.Button" pos:[192,32] width:90 height:22
    dotNetControl btn_tab4 "System.Windows.Forms.Button" pos:[284,32] width:90 height:22
    dotNetControl btn_tab5 "System.Windows.Forms.Button" pos:[376,32] width:90 height:22
    dotNetControl btn_tab6 "System.Windows.Forms.Button" pos:[468,32] width:90 height:22

    dotNetControl pnl_content "System.Windows.Forms.Panel"  pos:[8,58]  width:582 height:460
    dotNetControl btn_init    "System.Windows.Forms.Button" pos:[8,526] width:582 height:28

    fn styleTab btn lbl active = (
        btn.Text      = lbl
        btn.Font      = dotNetObject "System.Drawing.Font" "Courier New" 8
        btn.FlatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").Flat
        btn.FlatAppearance.BorderColor = TKN_C_BORDER
        btn.BackColor = if active then TKN_C_ACCENT else TKN_C_BG2
        btn.ForeColor = TKN_C_WHITE
    )

    on tkn_main_rollout open do (
        local fmono = dotNetObject "System.Drawing.Font" "Courier New" 9
        local fbold = dotNetObject "System.Drawing.Font" "Courier New" 9 ((dotNetClass "System.Drawing.FontStyle").Bold)

        lbl_header.Text      = ("TEKTON v" + TEKTON.version + "   " + TEKTON.project_name)
        lbl_header.Font      = fmono
        lbl_header.ForeColor = TKN_C_TEXT
        lbl_header.BackColor = TKN_C_BG

        local state = tkn_getLogIndicatorState()
        lbl_errors.Text      = ("ERR:" + state[2] as string)
        lbl_errors.Font      = fmono
        lbl_errors.ForeColor = if state[2] > 0 then TKN_C_RED else TKN_C_TEXT2
        lbl_errors.BackColor = TKN_C_BG

        lbl_warns.Text      = ("WRN:" + state[1] as string)
        lbl_warns.Font      = fmono
        lbl_warns.ForeColor = if state[1] > 0 then TKN_C_YELLOW else TKN_C_TEXT2
        lbl_warns.BackColor = TKN_C_BG

        styleTab btn_tab1 "SYSTEMS"  true
        styleTab btn_tab2 "LEVELS"   false
        styleTab btn_tab3 "CHECKER"  false
        styleTab btn_tab4 "COMPUTE"  false
        styleTab btn_tab5 "LOG"      false
        styleTab btn_tab6 "SETTINGS" false

        pnl_content.BackColor   = TKN_C_BG2
        pnl_content.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").FixedSingle

        btn_init.Text      = "[ INITIALIZE / LOAD PROJECT ]"
        btn_init.Font      = fbold
        btn_init.FlatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").Flat
        btn_init.FlatAppearance.BorderColor = TKN_C_ACCENT
        btn_init.BackColor = TKN_C_BG
        btn_init.ForeColor = TKN_C_ACCENT

        callbacks.addScript #selectionSetChanged "tkn_ui_onSelectionChanged()" id:#TKN_UI_sel persistent:false

        tkn_ui_loadTab 1
    )

    on btn_tab1 click do tkn_ui_loadTab 1
    on btn_tab2 click do tkn_ui_loadTab 2
    on btn_tab3 click do tkn_ui_loadTab 3
    on btn_tab4 click do tkn_ui_loadTab 4
    on btn_tab5 click do tkn_ui_loadTab 5
    on btn_tab6 click do tkn_ui_loadTab 6

    on btn_init click do (
        tkn_initialize()
        lbl_header.Text = ("TEKTON v" + TEKTON.version + "   " + TEKTON.project_name)
        tkn_ui_loadTab tkn_active_tab
    )

    on tkn_main_rollout close do (
        callbacks.removeScripts id:#TKN_UI_sel
        tkn_ui_dialog = undefined
    )
)

-- =============================================================================

fn tkn_showUI = (
    if tkn_ui_dialog != undefined then (
        try (closeRolloutFloater tkn_ui_dialog) catch()
    )
    tkn_ui_dialog = newRolloutFloater "TEKTON BIM" 600 570
    addRollout tkn_main_rollout tkn_ui_dialog
)

tkn_logInfo "Module loaded: tkn_ui.ms"

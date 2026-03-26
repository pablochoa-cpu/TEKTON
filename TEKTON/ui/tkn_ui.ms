-- =============================================================================
-- TEKTON UI - Main Panel
-- File: tkn_ui.ms
-- =============================================================================

global tkn_ui_dialog    = undefined
global tkn_active_tab   = 1
global tkn_selected_obj = undefined

global TKN_C_BG     = (dotNetClass "System.Drawing.Color").FromArgb 26  26  26
global TKN_C_BG2    = (dotNetClass "System.Drawing.Color").FromArgb 36  36  36
global TKN_C_BORDER = (dotNetClass "System.Drawing.Color").FromArgb 51  51  51
global TKN_C_TEXT   = (dotNetClass "System.Drawing.Color").FromArgb 224 224 224
global TKN_C_TEXT2  = (dotNetClass "System.Drawing.Color").FromArgb 136 136 136
global TKN_C_ACCENT = (dotNetClass "System.Drawing.Color").FromArgb 232 68  10
global TKN_C_BLUE   = (dotNetClass "System.Drawing.Color").FromArgb 10  127 194
global TKN_C_YELLOW = (dotNetClass "System.Drawing.Color").FromArgb 255 184 0
global TKN_C_GREEN  = (dotNetClass "System.Drawing.Color").FromArgb 61  170 92
global TKN_C_RED    = (dotNetClass "System.Drawing.Color").FromArgb 204 51  0
global TKN_C_WHITE  = (dotNetClass "System.Drawing.Color").FromArgb 255 255 255

-- =============================================================================
-- GLOBAL TAB FUNCTIONS (outside rollout so they can call other globals)
-- =============================================================================

fn tkn_ui_setActiveTab idx = (
    if tkn_ui_dialog == undefined then return false
    local tab_btns = #(
        tkn_main_rollout.btn_tab1,
        tkn_main_rollout.btn_tab2,
        tkn_main_rollout.btn_tab3,
        tkn_main_rollout.btn_tab4,
        tkn_main_rollout.btn_tab5,
        tkn_main_rollout.btn_tab6
    )
    tkn_active_tab = idx
    for i = 1 to tab_btns.count do (
        tab_btns[i].BackColor = if i == idx then TKN_C_ACCENT else TKN_C_BG2
    )
)

fn tkn_ui_loadTab idx = (
    if tkn_ui_dialog == undefined then return false
    tkn_ui_setActiveTab idx
    tkn_main_rollout.pnl_content.Controls.Clear()
    case idx of (
        1: tkn_ui_buildSystems  tkn_main_rollout.pnl_content
        2: tkn_ui_buildLevels   tkn_main_rollout.pnl_content
        3: tkn_ui_buildChecker  tkn_main_rollout.pnl_content
        4: tkn_ui_buildCompute  tkn_main_rollout.pnl_content
        5: tkn_ui_buildLog      tkn_main_rollout.pnl_content
        6: tkn_ui_buildSettings tkn_main_rollout.pnl_content
    )
)

fn tkn_ui_onSelectionChanged = (
    if selection.count == 1 then (
        tkn_selected_obj = selection[1]
    ) else (
        tkn_selected_obj = undefined
    )
    if tkn_active_tab == 1 then tkn_ui_loadTab 1
)

-- Tab click handlers
fn tkn_ui_tab1 s e = ( tkn_ui_loadTab 1 )
fn tkn_ui_tab2 s e = ( tkn_ui_loadTab 2 )
fn tkn_ui_tab3 s e = ( tkn_ui_loadTab 3 )
fn tkn_ui_tab4 s e = ( tkn_ui_loadTab 4 )
fn tkn_ui_tab5 s e = ( tkn_ui_loadTab 5 )
fn tkn_ui_tab6 s e = ( tkn_ui_loadTab 6 )
fn tkn_ui_initClick s e = (
    tkn_initialize()
    tkn_main_rollout.lbl_header.Text = ("TEKTON v" + TEKTON.version + "   " + TEKTON.project_name)
    tkn_ui_loadTab tkn_active_tab
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

    dotNetControl pnl_content "System.Windows.Forms.Panel" pos:[8,58] width:582 height:460
    dotNetControl btn_init    "System.Windows.Forms.Button" pos:[8,526] width:582 height:28

    on tkn_main_rollout open do (

        local font_mono = dotNetObject "System.Drawing.Font" "Courier New" 9
        local font_bold = dotNetObject "System.Drawing.Font" "Courier New" 9 ((dotNetClass "System.Drawing.FontStyle").Bold)
        local font_sm   = dotNetObject "System.Drawing.Font" "Courier New" 8

        -- Header
        lbl_header.Text      = ("TEKTON v" + TEKTON.version + "   " + TEKTON.project_name)
        lbl_header.Font      = font_mono
        lbl_header.ForeColor = TKN_C_TEXT
        lbl_header.BackColor = TKN_C_BG

        -- Error/warn counters
        local state = tkn_getLogIndicatorState()
        lbl_errors.Text      = ("ERR:" + state[2] as string)
        lbl_errors.Font      = font_sm
        lbl_errors.ForeColor = if state[2] > 0 then TKN_C_RED else TKN_C_TEXT2
        lbl_errors.BackColor = TKN_C_BG

        lbl_warns.Text      = ("WRN:" + state[1] as string)
        lbl_warns.Font      = font_sm
        lbl_warns.ForeColor = if state[1] > 0 then TKN_C_YELLOW else TKN_C_TEXT2
        lbl_warns.BackColor = TKN_C_BG

        -- Tabs
        local tab_labels = #("SYSTEMS","LEVELS","CHECKER","COMPUTE","LOG","SETTINGS")
        local tab_btns   = #(btn_tab1,btn_tab2,btn_tab3,btn_tab4,btn_tab5,btn_tab6)
        local tab_fns    = #(tkn_ui_tab1,tkn_ui_tab2,tkn_ui_tab3,tkn_ui_tab4,tkn_ui_tab5,tkn_ui_tab6)

        local DN_Flat    = dotNetClass "System.Windows.Forms.FlatStyle"
        local DN_Cursors = dotNetClass "System.Windows.Forms.Cursors"

        local all_tabs = #(btn_tab1,btn_tab2,btn_tab3,btn_tab4,btn_tab5,btn_tab6)
        for i = 1 to all_tabs.count do (
            all_tabs[i].Text      = tab_labels[i]
            all_tabs[i].Font      = font_sm
            all_tabs[i].FlatStyle = DN_Flat.Flat
            all_tabs[i].FlatAppearance.BorderColor = TKN_C_BORDER
            all_tabs[i].BackColor = if i == 1 then TKN_C_ACCENT else TKN_C_BG2
            all_tabs[i].ForeColor = TKN_C_WHITE
            all_tabs[i].Cursor    = DN_Cursors.Hand
        )
        dotNet.addEventHandler btn_tab1 "Click" tkn_ui_tab1
        dotNet.addEventHandler btn_tab2 "Click" tkn_ui_tab2
        dotNet.addEventHandler btn_tab3 "Click" tkn_ui_tab3
        dotNet.addEventHandler btn_tab4 "Click" tkn_ui_tab4
        dotNet.addEventHandler btn_tab5 "Click" tkn_ui_tab5
        dotNet.addEventHandler btn_tab6 "Click" tkn_ui_tab6
        dotNet.addEventHandler btn_init "Click" tkn_ui_initClick

        -- Content panel
        pnl_content.BackColor   = TKN_C_BG2
        pnl_content.BorderStyle = (dotNetClass "System.Windows.Forms.BorderStyle").FixedSingle

        -- Init button
        btn_init.Text      = "[ INITIALIZE / LOAD PROJECT ]"
        btn_init.Font      = font_bold
        btn_init.FlatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").Flat
        btn_init.FlatAppearance.BorderColor = TKN_C_ACCENT
        btn_init.BackColor = TKN_C_BG
        btn_init.ForeColor = TKN_C_ACCENT
        btn_init.Cursor    = (dotNetClass "System.Windows.Forms.Cursors").Hand
        dotNet.addEventHandler btn_init "Click" tkn_ui_initClick

        -- Selection callback
        callbacks.addScript #selectionSetChanged "tkn_ui_onSelectionChanged()" id:#TKN_UI_sel persistent:false

        -- Load tab 1
        tkn_ui_loadTab 1
    )

    on tkn_main_rollout close do (
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

    fn styleTab btn label active = (
        btn.Text      = label
        btn.Font      = dotNetObject "System.Drawing.Font" "Courier New" 8
        btn.FlatStyle = (dotNetClass "System.Windows.Forms.FlatStyle").Flat
        btn.FlatAppearance.BorderColor = TKN_C_BORDER
        btn.BackColor = if active then TKN_C_ACCENT else TKN_C_BG2
        btn.ForeColor = TKN_C_WHITE
    )

    on tkn_main_rollout open do (
        local font_mono = dotNetObject "System.Drawing.Font" "Courier New" 9
        local font_bold = dotNetObject "System.Drawing.Font" "Courier New" 9 ((dotNetClass "System.Drawing.FontStyle").Bold)

        lbl_header.Text      = ("TEKTON v" + TEKTON.version + "   " + TEKTON.project_name)
        lbl_header.Font      = font_mono
        lbl_header.ForeColor = TKN_C_TEXT
        lbl_header.BackColor = TKN_C_BG

        local state = tkn_getLogIndicatorState()
        lbl_errors.Text      = ("ERR:" + state[2] as string)
        lbl_errors.Font      = font_mono
        lbl_errors.ForeColor = if state[2] > 0 then TKN_C_RED else TKN_C_TEXT2
        lbl_errors.BackColor = TKN_C_BG

        lbl_warns.Text      = ("WRN:" + state[1] as string)
        lbl_warns.Font      = font_mono
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
        btn_init.Font      = font_bold
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
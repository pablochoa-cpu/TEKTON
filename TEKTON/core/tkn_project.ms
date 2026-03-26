-- =============================================================================
-- TEKTON Module: Project
-- File: tkn_project.ms
-- Depends on: tekton_core.ms, tkn_log.ms, tkn_files.ms, tkn_levels.ms
-- Block: 8
-- =============================================================================

fn tkn_isNewProject = (

    local has_config  = doesFileExist (tkn_getConfigPath())
    local has_objects = false

    for obj in objects do (
        if tkn_isTekton obj then (
            has_objects = true
            exit
        )
    )

    return (not has_config and not has_objects)
)

fn tkn_checkScene = (

    local has_config  = doesFileExist (tkn_getConfigPath())
    local has_objects = false

    for obj in objects do (
        if tkn_isTekton obj then (
            has_objects = true
            exit
        )
    )

    if has_config or has_objects then (
        tkn_logInfo "TEKTON data detected. Loading project..."
        tkn_loadExistingProject()
    )
)

-- =============================================================================
-- WIZARD
-- =============================================================================

fn tkn_newProjectWizard = (

    if maxFilePath == "" then (
        messageBox "Save the scene first before creating a TEKTON project." title:"TEKTON - Save Scene First"
        return false
    )

    global tkn_wiz_name      = ""
    global tkn_wiz_type      = 1
    global tkn_wiz_confirmed = false

    rollout tkn_wizard_rollout "TEKTON - New Project" (

        label        lbl_name  "Project name:"  align:#left
        edittext     edt_name  ""               width:280 align:#left
        label        lbl_sp    ""               align:#left
        label        lbl_type  "Project type:"  align:#left
        radiobuttons rdo_type  labels:#("Single family house", "Multi family house", "Building", "Commercial", "Industrial", "Other") default:1 columns:1 align:#left
        label        lbl_sp2   ""               align:#left
        button       btn_ok     "Create"        width:130 across:2 align:#left
        button       btn_cancel "Cancel"        width:130 align:#right

        on btn_ok pressed do (
            if edt_name.text == "" then (
                messageBox "Project name cannot be empty." title:"TEKTON"
            ) else (
                tkn_wiz_name      = edt_name.text
                tkn_wiz_type      = rdo_type.state
                tkn_wiz_confirmed = true
                destroyDialog tkn_wizard_rollout
            )
        )

        on btn_cancel pressed do (
            destroyDialog tkn_wizard_rollout
        )

        on tkn_wizard_rollout close do (
            if tkn_wiz_confirmed then (
                local types = #("single_family", "multi_family", "building", "commercial", "industrial", "other")
                TEKTON.project_name   = tkn_wiz_name
                TEKTON.project_type   = types[tkn_wiz_type]
                TEKTON.project_date   = localTime as string
                TEKTON.project_active = true
                tkn_createFolderStructure()
                tkn_saveProjectData()
                tkn_saveLevels()
                tkn_createAllLayers()
                tkn_registerCallbacks()
                tkn_logInfo ("Project created: " + TEKTON.project_name)
                messageBox ("TEKTON project created.\n\nName: " + TEKTON.project_name + "\nType: " + TEKTON.project_type) title:"TEKTON - Project Created"
            ) else (
                tkn_logWarn "Project creation cancelled by user."
            )
        )
    )

    createDialog tkn_wizard_rollout width:320 style:#(#style_titlebar, #style_sysmenu)
    return true
)

-- =============================================================================
-- PROJECT FLOW
-- =============================================================================

fn tkn_startNewProject = (
    tkn_logInfo "Starting new project wizard..."
    tkn_newProjectWizard()
    return true
)

fn tkn_loadExistingProject = (

    tkn_logInfo "Loading existing project..."

    local loaded = tkn_loadProjectData()

    if not loaded then (
        tkn_logWarn "No project data found. Starting fresh."
        return false
    )

    tkn_loadLevels()
    tkn_createAllLayers()
    tkn_registerCallbacks()

    tkn_logInfo ("Project ready: " + TEKTON.project_name)
    return true
)

fn tkn_saveProject = (

    if not TEKTON.project_active then (
        tkn_logWarn "saveProject: no active project."
        return false
    )

    tkn_saveProjectData()
    tkn_saveLevels()

    tkn_logInfo "Project saved."
    return true
)

-- =============================================================================
-- MAIN ENTRY POINT
-- =============================================================================

fn tkn_initialize = (

    tkn_logInfo "TEKTON initializing..."

    -- Step 1: check system units
    if units.SystemType != #meters then (
        local fix = queryBox "TEKTON requires units set to Meters.\n\nFix automatically?" title:"TEKTON - Units"
        if fix then (
            units.SystemType  = #meters
            units.SystemScale = 1.0
            tkn_logInfo "System units set to Meters."
        ) else (
            tkn_logError "Initialization cancelled - wrong units."
            return false
        )
    )

    -- Step 2: check display units
    if units.DisplayType != #metric then (
        local fix_disp = queryBox "Display units are not Meters.\n\nFix display units too?" title:"TEKTON - Units"
        if fix_disp then (
            units.DisplayType = #metric
            tkn_logInfo "Display units set to Meters."
        )
    )

    -- Step 3: new or existing project
    if tkn_isNewProject() then (
        tkn_startNewProject()
    ) else (
        tkn_loadExistingProject()
    )

    tkn_logInfo "TEKTON ready."
    return true
)

-- =============================================================================

tkn_logInfo "Module loaded: tkn_project.ms"
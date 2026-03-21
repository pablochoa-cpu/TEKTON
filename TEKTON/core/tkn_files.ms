-- =============================================================================
-- TEKTON Module: Files
-- File: tkn_files.ms
-- Depends on: tekton_core.ms, tkn_log.ms
-- Block: 7
-- =============================================================================

-- =============================================================================
-- PATH MANAGEMENT
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_getConfigPath
-- Returns full path to the project config folder.
-- Lives next to the current Max scene file.
-- -----------------------------------------------------------------------------

fn tkn_getConfigPath = (

    local scene_path = maxFilePath

    if scene_path == "" then (
        scene_path = (getDir #temp) + "\\"
        tkn_logWarn "Scene not saved. Using temp folder for config."
    )

    return (scene_path + "TEKTON\\config\\")
)

-- -----------------------------------------------------------------------------
-- tkn_getExportPath
-- Returns full path to the exports folder.
-- -----------------------------------------------------------------------------

fn tkn_getExportPath = (

    local scene_path = maxFilePath

    if scene_path == "" then (
        scene_path = (getDir #temp) + "\\"
    )

    return (scene_path + "TEKTON\\exportaciones\\")
)

-- =============================================================================
-- FOLDER STRUCTURE
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_createFolderStructure
-- Creates all TEKTON folders next to the scene file.
-- Called once during project initialization.
-- -----------------------------------------------------------------------------

fn tkn_createFolderStructure = (

    local scene_path = maxFilePath

    if scene_path == "" then (
        tkn_logError "createFolderStructure: scene must be saved first."
        return false
    )

    local base_path   = scene_path + "TEKTON\\"
    local config_path = base_path  + "config\\"
    local export_path = base_path  + "exportaciones\\"

    makeDir base_path   all:true
    makeDir config_path all:true
    makeDir export_path all:true

    tkn_logInfo ("Folder structure created at: " + base_path)
    return true
)

-- =============================================================================
-- CFG READ / WRITE
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_writeCFG
-- Writes an array of strings to a .cfg file.
-- Creates a backup of the previous version first.
--
-- Parameters:
--   filename  -> string without extension (ex: "levels")
--   lines     -> array of strings
--   comment   -> description written at top of file
-- -----------------------------------------------------------------------------

fn tkn_writeCFG filename lines comment = (

    local path     = (tkn_getConfigPath()) + filename + ".cfg"
    local bak_path = path + ".bak"

    -- Backup existing file before overwriting
    if doesFileExist path then (
        copyFile path bak_path
        tkn_logInfo ("Backup created: " + filename + ".cfg.bak")
    )

    local file = openFile path mode:"w"

    if file == undefined then (
        tkn_logError ("writeCFG: could not create file -> " + path)
        return false
    )

    format "-- TEKTON v%\n" TEKTON.version to:file
    format "-- %\n" comment to:file
    format "-- Auto-generated. Do not modify format.\n" to:file
    format "--\n" to:file

    for line in lines do (
        format "%\n" line to:file
    )

    close file
    tkn_logInfo ("Config saved: " + filename + ".cfg")
    return true
)

-- -----------------------------------------------------------------------------
-- tkn_readCFG
-- Reads a .cfg file and returns an array of data lines.
-- Skips comments and empty lines.
-- Validates file before loading -- uses backup if corrupted.
--
-- Parameters:
--   filename -> string without extension (ex: "levels")
-- -----------------------------------------------------------------------------

fn tkn_readCFG filename = (

    local path     = (tkn_getConfigPath()) + filename + ".cfg"
    local bak_path = path + ".bak"
    local result   = #()

    if not (doesFileExist path) then (
        tkn_logWarn ("readCFG: file not found -> " + filename + ".cfg")
        return result
    )

    local file = openFile path mode:"r"

    if file == undefined then (
        tkn_logError ("readCFG: could not open -> " + path)
        return result
    )

    while not (eof file) do (

        local line = readline file

        if line == "" then continue
        if (substring line 1 2) == "--" then continue

        append result line
    )

    close file

    -- Validate -- if empty and backup exists, try backup
    if result.count == 0 and (doesFileExist bak_path) then (
        tkn_logWarn ("readCFG: empty file detected. Trying backup...")
        return tkn_readCFG_path bak_path
    )

    tkn_logInfo ("Config loaded: " + filename + ".cfg (" + result.count as string + " lines)")
    return result
)

-- -----------------------------------------------------------------------------
-- tkn_readCFG_path
-- Same as readCFG but accepts a full path.
-- Used internally for backup loading and locale files.
-- -----------------------------------------------------------------------------

fn tkn_readCFG_path path = (

    local result = #()

    if not (doesFileExist path) then (
        tkn_logWarn ("readCFG_path: file not found -> " + path)
        return result
    )

    local file = openFile path mode:"r"

    if file == undefined then (
        tkn_logError ("readCFG_path: could not open -> " + path)
        return result
    )

    while not (eof file) do (

        local line = readline file

        if line == "" then continue
        if (substring line 1 2) == "--" then continue

        append result line
    )

    close file
    return result
)

-- -----------------------------------------------------------------------------
-- tkn_parseLine
-- Splits a data line into parts separated by |
-- Trims whitespace from each part.
--
-- Example:
--   tkn_parseLine "ground_floor | 0.0 | 3.0"
--   -> #("ground_floor", "0.0", "3.0")
-- -----------------------------------------------------------------------------

fn tkn_parseLine line = (

    local parts      = #()
    local current    = ""

    for i = 1 to line.count do (

        local ch = substring line i 1

        if ch == "|" then (
            append parts (trimLeft (trimRight current))
            current = ""
        ) else (
            current = current + ch
        )
    )

    if current != "" then (
        append parts (trimLeft (trimRight current))
    )

    return parts
)

-- =============================================================================
-- SAVE / LOAD LEVELS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_saveLevels
-- Writes current levels array to levels.cfg
-- -----------------------------------------------------------------------------

fn tkn_saveLevels = (

    local lines = #()

    for n in TEKTON.levels do (
        local line = n[1] + " | " + n[2] as string + " | " + n[3] as string
        append lines line
    )

    tkn_writeCFG "levels" lines "Project levels with Z heights in meters"
)

-- -----------------------------------------------------------------------------
-- tkn_loadLevels
-- Reads levels.cfg and loads levels into memory.
-- Replaces default levels with project levels.
-- -----------------------------------------------------------------------------

fn tkn_loadLevels = (

    local lines = tkn_readCFG "levels"

    if lines.count == 0 then (
        tkn_logWarn "loadLevels: no levels file found. Using defaults."
        return false
    )

    TEKTON.levels = #()

    for line in lines do (

        local parts = tkn_parseLine line

        if parts.count == 3 then (
            local name    = parts[1]
            local z_start = parts[2] as float
            local z_end   = parts[3] as float
            append TEKTON.levels #(name, z_start, z_end)
        ) else (
            tkn_logWarn ("loadLevels: skipping malformed line -> " + line)
        )
    )

    tkn_logInfo ("Levels loaded: " + TEKTON.levels.count as string + " levels.")
    return true
)

-- =============================================================================
-- SAVE / LOAD PROJECT DATA
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_saveProjectData
-- Writes basic project info to proyecto.cfg
-- -----------------------------------------------------------------------------

fn tkn_saveProjectData = (

    local lines = #()
    append lines ("name    | " + TEKTON.project_name)
    append lines ("type    | " + TEKTON.project_type)
    append lines ("date    | " + TEKTON.project_date)
    append lines ("version | " + TEKTON.version)

    tkn_writeCFG "project" lines "TEKTON project data"
)

-- -----------------------------------------------------------------------------
-- tkn_loadProjectData
-- Reads project.cfg and restores project data.
-- -----------------------------------------------------------------------------

fn tkn_loadProjectData = (

    local lines = tkn_readCFG "project"
    if lines.count == 0 then return false

    for line in lines do (

        local parts = tkn_parseLine line

        if parts.count == 2 then (
            local key = parts[1]
            local val = parts[2]

            if key == "name"    then TEKTON.project_name = val
            if key == "type"    then TEKTON.project_type = val
            if key == "date"    then TEKTON.project_date = val
        )
    )

    TEKTON.project_active = true
    tkn_logInfo ("Project loaded: " + TEKTON.project_name)
    return true
)

-- =============================================================================
-- CALLBACKS
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_registerCallbacks
-- Registers Max callbacks for auto-save and auto-load.
-- -----------------------------------------------------------------------------

fn tkn_registerCallbacks = (

    -- Auto-save when user saves the scene
    callbacks.addScript #filePostSave "tkn_saveProjectData() ; tkn_saveLevels()" id:#TKN_autosave persistent:false

    -- Auto-load when user opens a scene with TEKTON data
    callbacks.addScript #filePostOpen "tkn_checkScene()" id:#TKN_autoload persistent:false

    tkn_logInfo "Callbacks registered."
)

-- -----------------------------------------------------------------------------
-- tkn_unregisterCallbacks
-- Removes all TEKTON callbacks.
-- -----------------------------------------------------------------------------

fn tkn_unregisterCallbacks = (

    callbacks.removeScripts id:#TKN_autosave
    callbacks.removeScripts id:#TKN_autoload

    tkn_logInfo "Callbacks removed."
)

-- =============================================================================

tkn_logInfo "Module loaded: tkn_files.ms"
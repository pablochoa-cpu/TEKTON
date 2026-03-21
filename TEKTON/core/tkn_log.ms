-- =============================================================================
-- TEKTON Module: Log System
-- File: tkn_log.ms
-- Depends on: tekton_core.ms (TEKTON instance must exist)
-- Block: 11a
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_log
-- Core log function. All other log functions call this one.
-- -----------------------------------------------------------------------------

fn tkn_log level message = (

    local ts    = localTime as string
    local entry = #(level, message, ts)

    append TEKTON.log_entries entry

    if TEKTON.log_entries.count > TEKTON.log_max_entries then (
        deleteItem TEKTON.log_entries 1
    )

    if level == TEKTON.LOG_INFO then (
        TEKTON.log_count_info = TEKTON.log_count_info + 1
    )

    if level == TEKTON.LOG_WARN then (
        TEKTON.log_count_warn   = TEKTON.log_count_warn + 1
        TEKTON.log_has_new_warn = true
    )

    if level == TEKTON.LOG_ERROR then (
        TEKTON.log_count_error   = TEKTON.log_count_error + 1
        TEKTON.log_has_new_error = true
    )

    print ("[TEKTON " + level + "] " + message)
)

-- -----------------------------------------------------------------------------
-- tkn_logInfo / tkn_logWarn / tkn_logError
-- Shorthand functions -- used everywhere in the codebase.
-- -----------------------------------------------------------------------------

fn tkn_logInfo message = (
    tkn_log TEKTON.LOG_INFO message
)

fn tkn_logWarn message = (
    tkn_log TEKTON.LOG_WARN message
)

fn tkn_logError message = (
    tkn_log TEKTON.LOG_ERROR message
)

-- -----------------------------------------------------------------------------
-- tkn_getLog
-- Returns the full log array.
-- -----------------------------------------------------------------------------

fn tkn_getLog = (
    return TEKTON.log_entries
)

-- -----------------------------------------------------------------------------
-- tkn_getLastLog
-- Returns the most recent N entries. Default 1.
-- -----------------------------------------------------------------------------

fn tkn_getLastLog n:1 = (

    local result = #()
    local start  = TEKTON.log_entries.count - n + 1
    if start < 1 then start = 1

    for i = start to TEKTON.log_entries.count do (
        append result TEKTON.log_entries[i]
    )

    return result
)

-- -----------------------------------------------------------------------------
-- tkn_getFilteredLog
-- Returns log entries filtered by level. Newest first.
-- -----------------------------------------------------------------------------

fn tkn_getFilteredLog show_info:true show_warn:true show_error:true = (

    local result     = #()
    local i          = TEKTON.log_entries.count

    while i >= 1 do (

        local entry      = TEKTON.log_entries[i]
        local do_include = false

        if show_info  and entry[1] == TEKTON.LOG_INFO  then do_include = true
        if show_warn  and entry[1] == TEKTON.LOG_WARN  then do_include = true
        if show_error and entry[1] == TEKTON.LOG_ERROR then do_include = true

        if do_include then append result entry

        i = i - 1
    )

    return result
)

-- -----------------------------------------------------------------------------
-- tkn_getLogIndicatorState
-- Returns #(warn_count, error_count, has_new_error, has_new_warn)
-- -----------------------------------------------------------------------------

fn tkn_getLogIndicatorState = (
    return #(TEKTON.log_count_warn, TEKTON.log_count_error, TEKTON.log_has_new_error, TEKTON.log_has_new_warn)
)

-- -----------------------------------------------------------------------------
-- tkn_acknowledgeErrors
-- Resets new-error flags. Stops the blink animation.
-- -----------------------------------------------------------------------------

fn tkn_acknowledgeErrors = (
    TEKTON.log_has_new_error = false
    TEKTON.log_has_new_warn  = false
)

-- -----------------------------------------------------------------------------
-- tkn_clearLog
-- Clears all entries and resets all counters.
-- -----------------------------------------------------------------------------

fn tkn_clearLog = (
    TEKTON.log_entries       = #()
    TEKTON.log_count_info    = 0
    TEKTON.log_count_warn    = 0
    TEKTON.log_count_error   = 0
    TEKTON.log_has_new_error = false
    TEKTON.log_has_new_warn  = false
    print "[TEKTON INFO] Log cleared."
)

-- -----------------------------------------------------------------------------
-- tkn_exportLog
-- Exports full log to a text file next to the project.
-- -----------------------------------------------------------------------------

fn tkn_exportLog = (

    local path = maxFilePath + "TEKTON\\tekton_log.txt"
    local file = openFile path mode:"w"

    if file == undefined then (
        print "[TEKTON ERROR] Could not create log file."
        return false
    )

    format "TEKTON Log Export\n" to:file
    format "Project: %\n" TEKTON.project_name to:file
    format "Version: %\n" TEKTON.version to:file
    format "-----------------------------------\n" to:file

    for entry in TEKTON.log_entries do (
        format "[%] [%] %\n" entry[3] entry[1] entry[2] to:file
    )

    close file
    tkn_logInfo ("Log exported -> " + path)
    return true
)

-- =============================================================================

print "[TEKTON INFO] Module loaded: tkn_log.ms"
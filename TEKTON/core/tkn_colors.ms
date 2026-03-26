-- =============================================================================
-- TEKTON Module: Colors
-- File: tkn_colors.ms
-- Depends on: tekton_core.ms, tkn_log.ms
-- Block: 11d
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_getSystemColor
-- Returns the wireframe color for a given system.
-- Returns gray if system not found.
-- -----------------------------------------------------------------------------

fn tkn_getSystemColor system = (

    for entry in TEKTON.system_colors do (
        if (toLower entry[1]) == (toLower system) then (
            return (color entry[2] entry[3] entry[4])
        )
    )

    return (color 150 150 150)
)

-- -----------------------------------------------------------------------------
-- tkn_applySystemColor
-- Applies the system wireframe color to a tagged object.
-- -----------------------------------------------------------------------------

fn tkn_applySystemColor obj = (

    if not (tkn_isTekton obj) then return false

    local sys = tkn_getProperty obj "system"
    obj.wireColor = tkn_getSystemColor sys
    return true
)

-- -----------------------------------------------------------------------------
-- tkn_applyColorsToAll
-- Applies system colors to all tagged objects in the scene.
-- Useful when opening an existing project.
-- -----------------------------------------------------------------------------

fn tkn_applyColorsToAll = (

    local count = 0

    for obj in objects do (
        if tkn_isTekton obj then (
            tkn_applySystemColor obj
            count = count + 1
        )
    )

    tkn_logInfo ("System colors applied to " + count as string + " objects.")
)

-- -----------------------------------------------------------------------------
-- tkn_resetColors
-- Resets all tagged object wirecolors to default gray.
-- -----------------------------------------------------------------------------

fn tkn_resetColors = (

    for obj in objects do (
        if tkn_isTekton obj then (
            obj.wireColor = color 150 150 150
        )
    )

    tkn_logInfo "Object colors reset to default."
)

-- -----------------------------------------------------------------------------
-- tkn_toggleBIMMode
-- Switches between BIM color mode and normal display.
-- -----------------------------------------------------------------------------

fn tkn_toggleBIMMode = (

    if not TEKTON.bim_mode_active then (
        tkn_applyColorsToAll()
        TEKTON.bim_mode_active = true
        tkn_logInfo "BIM color mode activated."
    ) else (
        tkn_resetColors()
        TEKTON.bim_mode_active = false
        tkn_logInfo "BIM color mode deactivated."
    )

    return TEKTON.bim_mode_active
)

-- =============================================================================

tkn_logInfo "Module loaded: tkn_colors.ms"
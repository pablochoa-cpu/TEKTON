-- =============================================================================
-- TEKTON Module: Queries
-- File: tkn_queries.ms
-- Depends on: tekton_core.ms, tkn_log.ms, tkn_properties.ms, tkn_levels.ms
-- Block: 9
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_listAll
-- Returns all TEKTON tagged objects in the scene.
-- Parameters:
--   include_hidden  -> include objects on hidden layers (default false)
--   include_locked  -> include objects on locked layers (default false)
-- -----------------------------------------------------------------------------

fn tkn_listAll include_hidden:false include_locked:false = (

    local result = #()

    for obj in objects do (
        if tkn_isTekton obj then (

            local layer = obj.layer

            if not include_hidden and layer.isHidden then continue
            if not include_locked and layer.Lock     then continue

            append result obj
        )
    )

    tkn_logInfo ("listAll: " + result.count as string + " objects found.")
    return result
)

-- -----------------------------------------------------------------------------
-- tkn_filterBySystem
-- Returns all tagged objects of a given system.
-- -----------------------------------------------------------------------------

fn tkn_filterBySystem system = (

    local result = #()

    for obj in objects do (
        if tkn_isTekton obj then (
            local s = tkn_getProperty obj "system"
            if (toLower s) == (toLower system) then (
                append result obj
            )
        )
    )

    return result
)

-- -----------------------------------------------------------------------------
-- tkn_filterByFamily
-- Returns all tagged objects of a given family.
-- -----------------------------------------------------------------------------

fn tkn_filterByFamily family = (

    local result = #()

    for obj in objects do (
        if tkn_isTekton obj then (
            local f = tkn_getProperty obj "family"
            if (toLower f) == (toLower family) then (
                append result obj
            )
        )
    )

    return result
)

-- -----------------------------------------------------------------------------
-- tkn_filterBySystemAndFamily
-- Returns objects matching both system and family.
-- -----------------------------------------------------------------------------

fn tkn_filterBySystemAndFamily system family = (

    local result = #()

    for obj in objects do (
        if tkn_isTekton obj then (
            local s = tkn_getProperty obj "system"
            local f = tkn_getProperty obj "family"
            if (toLower s) == (toLower system) and \
               (toLower f) == (toLower family) then (
                append result obj
            )
        )
    )

    return result
)

-- -----------------------------------------------------------------------------
-- tkn_filterByFinish
-- Returns objects with a specific finish.
-- Useful for plaster and paint area reports.
-- -----------------------------------------------------------------------------

fn tkn_filterByFinish finish = (

    local result = #()

    for obj in objects do (
        if tkn_isTekton obj then (
            local fin = tkn_getProperty obj "finish"
            if fin != undefined and (toLower fin) == (toLower finish) then (
                append result obj
            )
        )
    )

    return result
)

-- -----------------------------------------------------------------------------
-- tkn_filterByStatus
-- Returns objects with a specific construction status.
-- -----------------------------------------------------------------------------

fn tkn_filterByStatus status = (

    local result = #()

    for obj in objects do (
        if tkn_isTekton obj then (
            local st = tkn_getProperty obj "status"
            if st != undefined and (toLower st) == (toLower status) then (
                append result obj
            )
        )
    )

    return result
)

-- -----------------------------------------------------------------------------
-- tkn_filterByPhase
-- Returns objects of a specific construction phase.
-- -----------------------------------------------------------------------------

fn tkn_filterByPhase phase = (

    local result = #()

    for obj in objects do (
        if tkn_isTekton obj then (
            local ph = tkn_getProperty obj "phase"
            if ph != undefined and (toLower ph) == (toLower phase) then (
                append result obj
            )
        )
    )

    return result
)

-- -----------------------------------------------------------------------------
-- tkn_findByID
-- Finds a specific object by its TEKTON ID.
-- Returns the object or undefined if not found.
-- -----------------------------------------------------------------------------

fn tkn_findByID id = (

    for obj in objects do (
        if tkn_isTekton obj then (
            local obj_id = tkn_getProperty obj "id"
            if obj_id == id then (
                return obj
            )
        )
    )

    tkn_logWarn ("findByID: object not found -> " + id)
    return undefined
)

-- -----------------------------------------------------------------------------
-- tkn_compoundQuery
-- Multi-filter query. Pass undefined to skip any filter.
--
-- Example -- all beams on ground floor with plastered finish:
--   tkn_compoundQuery system:"concrete_structure" family:"beam" \
--       level:"ground_floor" finish:"plastered" \
--       status:undefined phase:undefined
-- -----------------------------------------------------------------------------

fn tkn_compoundQuery system level finish status phase family = (

    local result = #()

    for obj in objects do (
        if tkn_isTekton obj then (

            local ok = true

            if system != undefined then (
                local v = tkn_getProperty obj "system"
                if (toLower v) != (toLower system) then ok = false
            )

            if ok and family != undefined then (
                local v = tkn_getProperty obj "family"
                if (toLower v) != (toLower family) then ok = false
            )

            if ok and level != undefined then (
                local v = tkn_getProperty obj "level"
                if (toLower v) != (toLower level) then ok = false
            )

            if ok and finish != undefined then (
                local v = tkn_getProperty obj "finish"
                if v == undefined or (toLower v) != (toLower finish) then ok = false
            )

            if ok and status != undefined then (
                local v = tkn_getProperty obj "status"
                if v == undefined or (toLower v) != (toLower status) then ok = false
            )

            if ok and phase != undefined then (
                local v = tkn_getProperty obj "phase"
                if v == undefined or (toLower v) != (toLower phase) then ok = false
            )

            if ok then append result obj
        )
    )

    tkn_logInfo ("compoundQuery: " + result.count as string + " objects found.")
    return result
)

-- -----------------------------------------------------------------------------
-- tkn_sceneOverview
-- Returns a summary of all tagged objects grouped by system.
-- Used by the UI dashboard.
-- -----------------------------------------------------------------------------

fn tkn_sceneOverview = (

    local total  = 0
    local lines  = #()

    for sys in TEKTON.valid_systems do (
        local objs = tkn_filterBySystem sys
        if objs.count > 0 then (
            append lines (sys + ": " + objs.count as string)
            total = total + objs.count
        )
    )

    tkn_logInfo ("Scene overview - Total BIM objects: " + total as string)
    for line in lines do print ("[TEKTON] " + line)

    return lines
)

-- -----------------------------------------------------------------------------
-- tkn_selectBySystem
-- Selects all objects of a system in the Max viewport.
-- Useful for quick visual verification.
-- -----------------------------------------------------------------------------

fn tkn_selectBySystem system = (

    local objs = tkn_filterBySystem system

    if objs.count == 0 then (
        tkn_logWarn ("selectBySystem: no objects found for system '" + system + "'")
        return false
    )

    select objs
    tkn_logInfo ("Selected " + objs.count as string + " objects of system: " + system)
    return true
)

-- -----------------------------------------------------------------------------
-- tkn_selectByLevel
-- Selects all objects of a level in the Max viewport.
-- -----------------------------------------------------------------------------

fn tkn_selectByLevel level = (

    local objs = tkn_filterByLevel level

    if objs.count == 0 then (
        tkn_logWarn ("selectByLevel: no objects found for level '" + level + "'")
        return false
    )

    select objs
    tkn_logInfo ("Selected " + objs.count as string + " objects on level: " + level)
    return true
)

-- =============================================================================

tkn_logInfo "Module loaded: tkn_queries.ms"
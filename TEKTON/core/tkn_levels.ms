-- =============================================================================
-- TEKTON Module: Levels
-- File: tkn_levels.ms
-- Depends on: tekton_core.ms, tkn_log.ms
-- Block: 6
-- =============================================================================

-- =============================================================================
-- LEVEL MANAGEMENT
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_getLevels
-- Returns the full levels array.
-- -----------------------------------------------------------------------------

fn tkn_getLevels = (
    return TEKTON.levels
)

-- -----------------------------------------------------------------------------
-- tkn_getLevel
-- Returns a single level by name as #(name, z_start, z_end)
-- Returns undefined if not found.
-- -----------------------------------------------------------------------------

fn tkn_getLevel name = (

    for n in TEKTON.levels do (
        if (toLower n[1]) == (toLower name) then (
            return n
        )
    )

    tkn_logError ("Level not found: '" + name + "'")
    return undefined
)

-- -----------------------------------------------------------------------------
-- tkn_addLevel
-- Adds a new level to the project.
-- Checks for duplicate names and valid Z range.
-- -----------------------------------------------------------------------------

fn tkn_addLevel name z_start z_end = (

    for n in TEKTON.levels do (
        if (toLower n[1]) == (toLower name) then (
            tkn_logError ("Level already exists: '" + name + "'")
            return false
        )
    )

    if z_start >= z_end then (
        tkn_logError "addLevel: z_start must be less than z_end."
        return false
    )

    append TEKTON.levels #(name, z_start, z_end)
    tkn_logInfo ("Level added: " + name + " [" + z_start as string + " / " + z_end as string + "]")
    return true
)

-- -----------------------------------------------------------------------------
-- tkn_editLevel
-- Modifies the Z range of an existing level.
-- -----------------------------------------------------------------------------

fn tkn_editLevel name z_start z_end = (

    for i = 1 to TEKTON.levels.count do (
        if (toLower TEKTON.levels[i][1]) == (toLower name) then (

            if z_start >= z_end then (
                tkn_logError "editLevel: z_start must be less than z_end."
                return false
            )

            TEKTON.levels[i][2] = z_start
            TEKTON.levels[i][3] = z_end

            tkn_logInfo ("Level edited: " + name + " [" + z_start as string + " / " + z_end as string + "]")
            return true
        )
    )

    tkn_logError ("Level not found: '" + name + "'")
    return false
)

-- -----------------------------------------------------------------------------
-- tkn_removeLevel
-- Removes a level only if no objects are assigned to it.
-- -----------------------------------------------------------------------------

fn tkn_removeLevel name = (

    local objs_in_level = tkn_filterByLevel name

    if objs_in_level.count > 0 then (
        tkn_logError ("Cannot remove level '" + name + "' -- " + objs_in_level.count as string + " object(s) assigned.")
        return false
    )

    for i = 1 to TEKTON.levels.count do (
        if (toLower TEKTON.levels[i][1]) == (toLower name) then (
            deleteItem TEKTON.levels i
            tkn_logInfo ("Level removed: '" + name + "'")
            return true
        )
    )

    tkn_logError ("Level not found: '" + name + "'")
    return false
)

-- -----------------------------------------------------------------------------
-- tkn_getObjectLevel
-- Returns the level data of a tagged object.
-- -----------------------------------------------------------------------------

fn tkn_getObjectLevel obj = (

    if not (tkn_isTekton obj) then (
        tkn_logError "getObjectLevel: object has no TEKTON data."
        return undefined
    )

    local level_name = tkn_getProperty obj "level"
    return tkn_getLevel level_name
)

-- -----------------------------------------------------------------------------
-- tkn_checkPhysicalLevel
-- Verifies that an object is physically within its assigned level Z range.
-- -----------------------------------------------------------------------------

fn tkn_checkPhysicalLevel obj = (

    if not (tkn_isTekton obj) then return false

    local level_data = tkn_getObjectLevel obj
    if level_data == undefined then return false

    local z_start = level_data[2]
    local z_end   = level_data[3]
    local z_real  = obj.pos.z

    if z_real >= z_start and z_real <= z_end then (
        return true
    ) else (
        tkn_logWarn ("'" + obj.name + "' is at Z=" + z_real as string + " but level '" + level_data[1] + "' goes from Z=" + z_start as string + " to Z=" + z_end as string)
        return false
    )
)

-- -----------------------------------------------------------------------------
-- tkn_filterByLevel
-- Returns all TEKTON objects assigned to a level.
-- -----------------------------------------------------------------------------

fn tkn_filterByLevel name = (

    local result = #()

    for obj in objects do (
        if tkn_isTekton obj then (
            local lvl = tkn_getProperty obj "level"
            if (toLower lvl) == (toLower name) then (
                append result obj
            )
        )
    )

    return result
)

-- =============================================================================
-- LAYER MANAGEMENT
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_getLayerName
-- Returns the Max layer name for a level.
-- Convention: TKN_ + level name
-- -----------------------------------------------------------------------------

fn tkn_getLayerName level_name = (
    return ("TKN_" + level_name)
)

-- -----------------------------------------------------------------------------
-- tkn_createLevelLayer
-- Creates a Max layer for a level if it doesnt exist.
-- -----------------------------------------------------------------------------

fn tkn_createLevelLayer level_name = (

    local layer_name = tkn_getLayerName level_name
    local existing   = LayerManager.getLayerFromName layer_name

    if existing == undefined then (
        LayerManager.newLayerFromName layer_name
        tkn_logInfo ("Layer created: " + layer_name)
    ) else (
        tkn_logInfo ("Layer already exists: " + layer_name)
    )

    return LayerManager.getLayerFromName layer_name
)

-- -----------------------------------------------------------------------------
-- tkn_createAllLayers
-- Creates layers for all levels in the project.
-- Called once during project initialization.
-- -----------------------------------------------------------------------------

fn tkn_createAllLayers = (

    tkn_logInfo "Creating level layers..."

    for n in TEKTON.levels do (
        tkn_createLevelLayer n[1]
        tkn_createLevelPlane n
    )

    tkn_logInfo "All level layers created."
)

-- -----------------------------------------------------------------------------
-- tkn_assignObjectToLevel
-- Moves an object to its level layer.
-- Called automatically by tkn_tagObject.
-- -----------------------------------------------------------------------------

fn tkn_assignObjectToLevel obj level_name = (

    local layer_name = tkn_getLayerName level_name
    local layer      = LayerManager.getLayerFromName layer_name

    if layer == undefined then (
        tkn_logError ("Layer not found: " + layer_name + ". Run tkn_createAllLayers first.")
        return false
    )

    layer.addNode obj
    return true
)

-- -----------------------------------------------------------------------------
-- tkn_hideLevel
-- Hides all objects in a level by hiding its layer.
-- -----------------------------------------------------------------------------

fn tkn_hideLevel name = (

    local layer = LayerManager.getLayerFromName (tkn_getLayerName name)

    if layer == undefined then (
        tkn_logError ("Layer not found for level: '" + name + "'")
        return false
    )

    layer.isHidden = true
    tkn_logInfo ("Level hidden: " + name)
    return true
)

-- -----------------------------------------------------------------------------
-- tkn_showLevel
-- Shows all objects in a level.
-- -----------------------------------------------------------------------------

fn tkn_showLevel name = (

    local layer = LayerManager.getLayerFromName (tkn_getLayerName name)

    if layer == undefined then (
        tkn_logError ("Layer not found for level: '" + name + "'")
        return false
    )

    layer.isHidden = false
    tkn_logInfo ("Level shown: " + name)
    return true
)

-- -----------------------------------------------------------------------------
-- tkn_lockLevel
-- Locks a level layer -- objects cannot be selected or moved.
-- -----------------------------------------------------------------------------

fn tkn_lockLevel name = (

    local layer = LayerManager.getLayerFromName (tkn_getLayerName name)

    if layer == undefined then (
        tkn_logError ("Layer not found for level: '" + name + "'")
        return false
    )

    layer.isLocked = true
    tkn_logInfo ("Level locked: " + name)
    return true
)

-- -----------------------------------------------------------------------------
-- tkn_unlockLevel
-- Unlocks a level layer.
-- -----------------------------------------------------------------------------

fn tkn_unlockLevel name = (

    local layer = LayerManager.getLayerFromName (tkn_getLayerName name)

    if layer == undefined then (
        tkn_logError ("Layer not found for level: '" + name + "'")
        return false
    )

    layer.isLocked = false
    tkn_logInfo ("Level unlocked: " + name)
    return true
)

-- -----------------------------------------------------------------------------
-- tkn_isolateLevel
-- Shows only the specified level -- hides all others.
-- -----------------------------------------------------------------------------

fn tkn_isolateLevel name = (

    for n in TEKTON.levels do (
        if (toLower n[1]) == (toLower name) then (
            tkn_showLevel n[1]
        ) else (
            tkn_hideLevel n[1]
        )
    )

    tkn_logInfo ("Level isolated: " + name)
)

-- -----------------------------------------------------------------------------
-- tkn_showAllLevels
-- Makes all level layers visible.
-- -----------------------------------------------------------------------------

fn tkn_showAllLevels = (

    for n in TEKTON.levels do (
        tkn_showLevel n[1]
    )

    tkn_logInfo "All levels visible."
)

-- -----------------------------------------------------------------------------
-- tkn_layerStatus
-- Returns status of all level layers as array of #(name, isHidden, isLocked)
-- -----------------------------------------------------------------------------

fn tkn_layerStatus = (

    local result = #()

    for n in TEKTON.levels do (
        local layer = LayerManager.getLayerFromName (tkn_getLayerName n[1])
        if layer != undefined then (
            append result #(n[1], layer.isHidden, layer.isLocked)
        )
    )

    tkn_logInfo "Layer status:"
    for item in result do (
        local vis = if item[2] then "HIDDEN  " else "VISIBLE "
        local lck = if item[3] then "LOCKED" else "free  "
        print (vis + " | " + lck + " | " + item[1])
    )

    return result
)

-- =============================================================================
-- REFERENCE PLANES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_createLevelPlane
-- Creates an invisible reference plane at the Z start of a level.
-- The plane is frozen and non-renderable.
-- -----------------------------------------------------------------------------

fn tkn_createLevelPlane level_data = (

    local name    = level_data[1]
    local z_start = level_data[2]
    local obj_name = "TKN_LEVEL_" + name

    local existing = getNodeByName obj_name

    if existing != undefined then (
        tkn_logInfo ("Level plane already exists: " + obj_name)
        return existing
    )

    local ref_plane = plane length:1000 width:1000 lengthsegs:1 widthsegs:1 name:obj_name

    ref_plane.pos.z      = z_start
    ref_plane.renderable = false
    ref_plane.isFrozen   = true
    ref_plane.isHidden   = true
    ref_plane.wireColor  = color 40 120 200

    local layer = LayerManager.getLayerFromName (tkn_getLayerName name)
    if layer != undefined then (
        layer.addNode ref_plane
    )

    tkn_logInfo ("Level plane created: " + obj_name + " at Z=" + z_start as string)
    return ref_plane
)

-- -----------------------------------------------------------------------------
-- tkn_showLevelPlane
-- Makes the reference plane of a level temporarily visible.
-- Useful for snapping and modeling reference.
-- -----------------------------------------------------------------------------

fn tkn_showLevelPlane name = (

    local obj_name  = "TKN_LEVEL_" + name
    local ref_plane = getNodeByName obj_name

    if ref_plane == undefined then (
        tkn_logError ("Level plane not found: " + obj_name)
        return false
    )

    ref_plane.isHidden = false
    ref_plane.isFrozen = false
    tkn_logInfo ("Level plane visible: " + name)
    return true
)

-- -----------------------------------------------------------------------------
-- tkn_hideLevelPlane
-- Hides the reference plane of a level.
-- -----------------------------------------------------------------------------

fn tkn_hideLevelPlane name = (

    local obj_name  = "TKN_LEVEL_" + name
    local ref_plane = getNodeByName obj_name

    if ref_plane == undefined then return false

    ref_plane.isHidden = true
    ref_plane.isFrozen = true
    return true
)

-- -----------------------------------------------------------------------------
-- tkn_syncLayerConsistency
-- Checks all TEKTON objects are in their correct layer.
-- Fixes inconsistencies automatically.
-- -----------------------------------------------------------------------------

fn tkn_syncLayerConsistency = (

    local fixed   = 0
    local correct = 0

    for obj in objects do (
        if tkn_isTekton obj then (

            local level_name   = tkn_getProperty obj "level"
            local correct_layer = tkn_getLayerName level_name
            local current_layer = obj.layer.name

            if current_layer != correct_layer then (
                tkn_assignObjectToLevel obj level_name
                fixed = fixed + 1
            ) else (
                correct = correct + 1
            )
        )
    )

    tkn_logInfo ("Layer sync complete. Correct: " + correct as string + " Fixed: " + fixed as string)
)

-- =============================================================================

tkn_logInfo "Module loaded: tkn_levels.ms"
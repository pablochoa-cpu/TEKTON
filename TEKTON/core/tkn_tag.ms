-- =============================================================================
-- TEKTON Module: Tag
-- File: tkn_tag.ms
-- Depends on: tekton_core.ms, tkn_log.ms, tkn_properties.ms,
--             tkn_levels.ms, tkn_queries.ms
-- Block: 10
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_tagObject
-- Main tagging function. Tags a single object with full BIM data.
-- Validates all data, generates ID, assigns to layer.
--
-- Parameters:
--   obj         -> scene object (required)
--   system      -> system name (required)
--   family      -> family name (required)
--   level       -> level name (required)
--   finish      -> surface finish (default "undefined")
--   phase       -> construction phase (default "new")
--   material    -> material description (default "")
--   description -> free text (default "")
--   level_end   -> end level for multi-level objects (default "")
-- -----------------------------------------------------------------------------

fn tkn_tagObject obj system family level finish:"undefined" phase:"new" material:"" description:"" level_end:"" = (

    -- -----------------------------------------------------------------
    -- Step 1: validate object
    -- -----------------------------------------------------------------

    if obj == undefined then (
        tkn_logError "tagObject: object is undefined."
        return false
    )

    -- -----------------------------------------------------------------
    -- Step 2: validate all data
    -- -----------------------------------------------------------------

    local valid = tkn_validateAll obj system family level finish phase

    if not valid then (
        tkn_logError ("tagObject: validation failed for '" + obj.name + "'.")
        return false
    )

    -- -----------------------------------------------------------------
    -- Step 3: check if object already has a TEKTON ID
    -- If yes -> update, keep existing ID
    -- If no  -> generate new ID
    -- -----------------------------------------------------------------

    local existing_id = tkn_getProperty obj "id"
    local final_id    = ""

    if existing_id != undefined then (
        final_id = existing_id
        tkn_logInfo ("tagObject: updating existing object -> " + final_id)
    ) else (
        final_id = tkn_generateID system family
        if not (tkn_validateUniqueID final_id) then (
            tkn_logError "tagObject: could not generate unique ID."
            return false
        )
        tkn_logInfo ("tagObject: new object -> " + final_id)
    )

    -- -----------------------------------------------------------------
    -- Step 4: write all BIM properties
    -- -----------------------------------------------------------------

    tkn_setProperty obj "id"      final_id
    tkn_setProperty obj "system"  system
    tkn_setProperty obj "family"  family
    tkn_setProperty obj "level"   level
    tkn_setProperty obj "finish"  finish
    tkn_setProperty obj "phase"   phase
    tkn_setProperty obj "version" TEKTON.version

    if material    != "" then tkn_setProperty obj "material"    material
    if description != "" then tkn_setProperty obj "description" description
    if level_end   != "" then tkn_setProperty obj "level_end"   level_end

    -- -----------------------------------------------------------------
    -- Step 5: assign object to its level layer
    -- -----------------------------------------------------------------

    tkn_assignObjectToLevel obj level

    -- -----------------------------------------------------------------
    -- Step 6: apply system wireframe color
    -- -----------------------------------------------------------------

    local sys_color = tkn_getSystemColor system
    obj.wireColor   = sys_color

    -- -----------------------------------------------------------------
    -- Step 7: check physical Z position
    -- -----------------------------------------------------------------

    if not (tkn_checkPhysicalLevel obj) then (
        tkn_logWarn ("tagObject: '" + obj.name + "' may be at wrong height for level '" + level + "'.")
    )

    -- -----------------------------------------------------------------
    -- Step 8: rename object with its ID
    -- -----------------------------------------------------------------

    obj.name = final_id

    -- -----------------------------------------------------------------
    -- Step 9: auto-save project
    -- -----------------------------------------------------------------

    tkn_saveProject()

    tkn_logInfo ("tagObject: '" + final_id + "' tagged successfully.")
    return final_id
)

-- -----------------------------------------------------------------------------
-- tkn_untagObject
-- Removes all TEKTON BIM data from an object.
-- Asks for confirmation before proceeding.
-- -----------------------------------------------------------------------------

fn tkn_untagObject obj = (

    if not (tkn_isTekton obj) then (
        tkn_logWarn ("untagObject: '" + obj.name + "' has no TEKTON data.")
        return false
    )

    local obj_id = tkn_getProperty obj "id"

    local confirm = queryBox ("Remove BIM data from '" + obj.name + "'?\n\nID: " + obj_id + "\n\nThis cannot be undone.") title:"TEKTON - Confirm Untag"

    if not confirm then return false

    tkn_clearProps obj

    -- Move object back to default layer
    local default_layer = LayerManager.getLayerFromName "0"
    if default_layer != undefined then (
        default_layer.addNode obj
    )

    -- Reset wirecolor to default gray
    obj.wireColor = color 150 150 150

    tkn_logInfo ("untagObject: BIM data removed from '" + obj.name + "'")
    tkn_saveProject()
    return true
)

-- -----------------------------------------------------------------------------
-- tkn_tagSelection
-- Tags all currently selected objects with the same BIM data.
-- Most common workflow -- select in viewport then tag.
-- -----------------------------------------------------------------------------

fn tkn_tagSelection system family level finish:"undefined" phase:"new" material:"" description:"" = (

    if selection.count == 0 then (
        tkn_logWarn "tagSelection: no objects selected."
        return #()
    )

    tkn_logInfo ("tagSelection: tagging " + selection.count as string + " selected objects...")

    local objs = #()
    for obj in selection do append objs obj

    local ids      = #()
    local ok_count = 0
    local fail_count = 0

    for obj in objs do (
        local id = tkn_tagObject obj \
            system:system \
            family:family \
            level:level \
            finish:finish \
            phase:phase \
            material:material \
            description:description

        if id != false then (
            append ids id
            ok_count = ok_count + 1
        ) else (
            fail_count = fail_count + 1
        )
    )

    tkn_logInfo ("tagSelection: " + ok_count as string + " tagged, " + fail_count as string + " failed.")
    return ids
)

-- -----------------------------------------------------------------------------
-- tkn_tagMultiple
-- Tags an array of objects with the same BIM data.
-- Used by modeler scripts that generate geometry automatically.
-- -----------------------------------------------------------------------------

fn tkn_tagMultiple objs system family level finish:"undefined" phase:"new" material:"" description:"" = (

    if objs.count == 0 then (
        tkn_logWarn "tagMultiple: empty object array."
        return #()
    )

    local ids        = #()
    local ok_count   = 0
    local fail_count = 0

    for obj in objs do (
        local id = tkn_tagObject obj \
            system:system \
            family:family \
            level:level \
            finish:finish \
            phase:phase \
            material:material \
            description:description

        if id != false then (
            append ids id
            ok_count = ok_count + 1
        ) else (
            fail_count = fail_count + 1
        )
    )

    tkn_logInfo ("tagMultiple: " + ok_count as string + " tagged, " + fail_count as string + " failed.")
    return ids
)

-- =============================================================================

tkn_logInfo "Module loaded: tkn_tag.ms"
-- =============================================================================
-- TEKTON Module: Extended Properties
-- File: tkn_extended.ms
-- Depends on: tekton_core.ms, tkn_log.ms, tkn_properties.ms
-- Block: 11c
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_setExtended
-- Writes an extended (family-specific) property to an object.
-- Uses tkn_x_ prefix to separate from standard properties.
--
-- Parameters:
--   obj   -> scene object
--   key   -> property name without prefix (ex: "section")
--   value -> value to store
--
-- Example:
--   tkn_setExtended beam "section" "20x40"
--   tkn_setExtended beam "steel"   "4f16"
--   -> writes tkn_x_section and tkn_x_steel to the object
-- -----------------------------------------------------------------------------

fn tkn_setExtended obj key value = (

    if obj == undefined then (
        tkn_logError "setExtended: invalid object."
        return false
    )

    local full_key = TEKTON.ext_prefix + key
    local val_str  = value as string

    setUserProp obj full_key val_str
    return true
)

-- -----------------------------------------------------------------------------
-- tkn_getExtended
-- Reads an extended property from an object.
-- Returns undefined if property does not exist.
-- -----------------------------------------------------------------------------

fn tkn_getExtended obj key = (

    if obj == undefined then (
        tkn_logError "getExtended: invalid object."
        return undefined
    )

    local full_key = TEKTON.ext_prefix + key
    return getUserProp obj full_key
)

-- -----------------------------------------------------------------------------
-- tkn_getAllExtended
-- Returns all extended properties of an object
-- as array of #(key, value) pairs.
-- Keys are returned WITHOUT the tkn_x_ prefix.
-- -----------------------------------------------------------------------------

fn tkn_getAllExtended obj = (

    if obj == undefined then return #()
    if not (tkn_isTekton obj) then return #()

    local result = #()
    local buffer = getUserPropBuffer obj
    local lines  = filterString buffer "\n"

    for line in lines do (

        local parts = filterString line "="

        if parts.count >= 2 then (

            local key = trimLeft (trimRight parts[1])
            local val = trimLeft (trimRight parts[2])

            -- Only include extended properties
            if (substring key 1 6) == "tkn_x_" then (
                local clean_key = substring key 7 (key.count - 6)
                append result #(clean_key, val)
            )
        )
    )

    return result
)

-- -----------------------------------------------------------------------------
-- tkn_clearExtended
-- Removes all extended properties from an object.
-- Called by tkn_untagObject.
-- -----------------------------------------------------------------------------

fn tkn_clearExtended obj = (

    if obj == undefined then return false

    local buffer   = getUserPropBuffer obj
    local lines    = filterString buffer "\n"
    local new_buf  = ""

    for line in lines do (

        local parts = filterString line "="

        if parts.count >= 2 then (
            local key = trimLeft (trimRight parts[1])

            -- Keep everything that is NOT an extended property
            if (substring key 1 6) != "tkn_x_" then (
                new_buf = new_buf + line + "\n"
            )
        )
    )

    setUserPropBuffer obj new_buf
    tkn_logInfo ("Extended properties cleared from: " + obj.name)
    return true
)

-- -----------------------------------------------------------------------------
-- tkn_getAllPropsComplete
-- Returns ALL properties of an object -- standard + extended.
-- Combines tkn_getAllProps and tkn_getAllExtended.
-- Useful for the UI inspector panel.
-- -----------------------------------------------------------------------------

fn tkn_getAllPropsComplete obj = (

    if obj == undefined then return #()
    if not (tkn_isTekton obj) then return #()

    local standard = tkn_getAllProps obj
    local extended = tkn_getAllExtended obj
    local result   = #()

    -- Add standard props
    for item in standard do append result item

    -- Add extended props with x: prefix for display
    for item in extended do (
        append result #("x:" + item[1], item[2])
    )

    return result
)

-- =============================================================================

tkn_logInfo "Module loaded: tkn_extended.ms"
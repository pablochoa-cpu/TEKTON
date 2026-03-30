-- =============================================================================
-- TEKTON Module: Properties
-- File: tkn_properties.ms
-- Depends on: tekton_core.ms, tkn_log.ms
-- Blocks: 3 (read/write), 4 (ID generation), 5 (validation)
-- =============================================================================

-- =============================================================================
-- BLOCK 3: READ / WRITE OBJECT PROPERTIES
-- =============================================================================

fn tkn_setProperty obj key value = (

    if obj == undefined then (
        tkn_logError "setProperty: invalid object."
        return false
    )

    local full_key = TEKTON.prefix + key
    local val_str  = value as string

    setUserProp obj full_key val_str
    return true
)

fn tkn_getProperty obj key = (

    if obj == undefined then (
        tkn_logError "getProperty: invalid object."
        return undefined
    )

    local full_key = TEKTON.prefix + key
    return getUserProp obj full_key
)

fn tkn_isTekton obj = (

    if obj == undefined then return false
    local id = getUserProp obj (TEKTON.prefix + "id")
    return (id != undefined)
)

fn tkn_getAllProps obj = (

    if obj == undefined then return #()
    if not (tkn_isTekton obj) then return #()

    local keys = #("id", "system", "family", "level", "level_end", "finish", "phase", "status", "material", "description", "version")
    local result = #()

    for k in keys do (
        local val = tkn_getProperty obj k
        if val != undefined then (
            append result #(k, val)
        )
    )

    return result
)

fn tkn_clearProps obj = (

    if obj == undefined then return false
    if not (tkn_isTekton obj) then return false

    local keys = #("id", "system", "family", "level", "level_end", "finish", "phase", "status", "material", "description", "version")

    for k in keys do (
        setUserProp obj (TEKTON.prefix + k) undefined
    )

    tkn_logInfo ("Properties cleared from: " + obj.name)
    return true
)

-- =============================================================================
-- BLOCK 4: UNIQUE ID GENERATION
-- =============================================================================

fn tkn_getAbbreviation name table_n table_c = (

    for i = 1 to table_n.count do (
        if (toLower table_n[i]) == (toLower name) then (
            return table_c[i]
        )
    )

    return "GEN"
)

fn tkn_countFamily system family = (

    local count = 0

    for obj in objects do (
        if tkn_isTekton obj then (
            local s = tkn_getProperty obj "system"
            local f = tkn_getProperty obj "family"
            if s == system and f == family then (
                count = count + 1
            )
        )
    )

    return count
)

fn tkn_generateID system family = (

    local sys_codes = #("FND", "CST", "STL", "MAS", "INS", "FLR", "PLS", "CLD", "ROF", "OPN", "MTW", "PLB", "DRN", "ELC", "GAS", "SIT", "EQP", "VEG", "GEN")

    local sys_code = tkn_getAbbreviation system TEKTON.valid_systems sys_codes
    local fam_code = tkn_getAbbreviation family TEKTON.family_names TEKTON.family_codes

    local num = (tkn_countFamily system family) + 1
    local num_str = ""

    if num < 10 then (
        num_str = "00" + num as string
    ) else if num < 100 then (
        num_str = "0" + num as string
    ) else (
        num_str = num as string
    )

    return (sys_code + "-" + fam_code + "-" + num_str)
)

-- =============================================================================
-- BLOCK 5: DATA VALIDATION
-- =============================================================================

fn tkn_validateSystem system = (

    for s in TEKTON.valid_systems do (
        if (toLower s) == (toLower system) then return true
    )

    tkn_logError ("Invalid system: '" + system + "'")
    return false
)

-- tkn_properties.ms — Fix validacion family

fn tkn_validateFamily family system =
(
    try
    (
        if family == undefined then
        (
            tkn_logError "Family is undefined."
            return false
        )
        
        local family_str = family as string
        local system_str = system as string
        local found = false
        local correct = false
        
        for i = 1 to TEKTON.family_names.count do
        (
            local current_fam = TEKTON.family_names[i] as string
            if (toLower current_fam) == (toLower family_str) then
            (
                found = true
                local fam_sys = TEKTON.family_systems[i] as string
                if fam_sys == system_str then
                    correct = true
                exit
            )
        )
        
        if not found then
        (
            tkn_logError ("Family '" + family_str + "' is not valid.")
            return false
        )
        
        if not correct then
        (
            tkn_logError ("Family '" + family_str + "' does not belong to system '" + system_str + "'.")
            return false
        )
        
        return true
    )
    catch
    (
        tkn_logError ("validateFamily error: " + (getCurrentException()))
        return false
    )
)

fn tkn_validateLevel level = (

    for n in TEKTON.levels do (
        if (toLower n[1]) == (toLower level) then return true
    )

    tkn_logError ("Invalid level: '" + level + "'")
    return false
)

fn tkn_validateFinish finish = (

    for f in TEKTON.valid_finishes do (
        if (toLower f) == (toLower finish) then return true
    )

    tkn_logError ("Invalid finish: '" + finish + "'")
    return false
)

fn tkn_validatePhase phase = (

    for p in TEKTON.valid_phases do (
        if (toLower p) == (toLower phase) then return true
    )

    tkn_logError ("Invalid phase: '" + phase + "'")
    return false
)

fn tkn_validateUniqueID id = (

    for obj in objects do (
        if tkn_isTekton obj then (
            local existing = tkn_getProperty obj "id"
            if existing == id then (
                tkn_logError ("Duplicate ID: '" + id + "' already on " + obj.name)
                return false
            )
        )
    )

    return true
)

fn tkn_validateAll obj system family level finish phase = (

    local errors = 0

    if obj == undefined then (
        tkn_logError "validateAll: object is undefined."
        errors = errors + 1
    )

    if not (tkn_validateSystem system)        then errors = errors + 1
    if not (tkn_validateFamily family system) then errors = errors + 1
    if not (tkn_validateLevel level)          then errors = errors + 1
    if not (tkn_validateFinish finish)        then errors = errors + 1
    if not (tkn_validatePhase phase)          then errors = errors + 1

    if errors > 0 then (
        tkn_logError ("Validation failed with " + errors as string + " error(s).")
        return false
    )

    return true
)

-- =============================================================================

tkn_logInfo "Module loaded: tkn_properties.ms"
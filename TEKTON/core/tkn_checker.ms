-- =============================================================================
-- TEKTON Module: Checker
-- File: tkn_checker.ms
-- Depends on: tekton_core.ms, tkn_log.ms, tkn_properties.ms,
--             tkn_geometry.ms, tkn_files.ms
-- Block: Fase 2
-- =============================================================================

-- =============================================================================
-- CLASH DATA
-- =============================================================================

-- Active clash rules loaded from rules.cfg
-- Each rule: #(system_a, system_b, type, priority, min_distance)
tkn_clash_rules = #()

-- Detected clashes in current session
-- Each clash: #(id, type, priority, obj_a, obj_b, sys_a, sys_b, desc, status)
tkn_clash_list = #()

-- Clash counter for ID generation
tkn_clash_counter = 0

-- Priority constants
CLASH_CRITICA = "CRITICA"
CLASH_ALTA    = "ALTA"
CLASH_MEDIA   = "MEDIA"
CLASH_BAJA    = "BAJA"

-- Type constants
CLASH_HARD     = "HARD"
CLASH_SOFT     = "SOFT"
CLASH_WORKFLOW = "WORKFLOW"

-- Status constants
CLASH_OPEN     = "open"
CLASH_RESOLVED = "resolved"
CLASH_IGNORED  = "ignored"

-- Colors for clash highlighting
CLASH_COLOR_CRITICA = color 255 0   0    -- red
CLASH_COLOR_ALTA    = color 255 140 0    -- orange
CLASH_COLOR_MEDIA   = color 255 200 0    -- yellow
CLASH_COLOR_BAJA    = color 180 180 180  -- gray

-- =============================================================================
-- RULES MANAGEMENT
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_loadRules
-- Loads clash rules from rules.cfg into memory.
-- -----------------------------------------------------------------------------

fn tkn_loadRules = (

    local lines = tkn_readCFG "rules"

    if lines.count == 0 then (
        tkn_logWarn "loadRules: no rules file found. Using empty ruleset."
        tkn_clash_rules = #()
        return false
    )

    tkn_clash_rules = #()

    for line in lines do (

        local parts = tkn_parseLine line

        if parts.count == 5 then (
            local rule = #(
                parts[1],           -- system_a
                parts[2],           -- system_b
                parts[3],           -- type
                parts[4],           -- priority
                parts[5] as float   -- min_distance
            )
            append tkn_clash_rules rule
        ) else (
            tkn_logWarn ("loadRules: skipping malformed line -> " + line)
        )
    )

    tkn_logInfo ("Rules loaded: " + tkn_clash_rules.count as string + " rules.")
    return true
)

-- -----------------------------------------------------------------------------
-- tkn_getRulesForSystems
-- Returns all rules that apply to a given pair of systems.
-- Checks both directions: A vs B and B vs A.
-- -----------------------------------------------------------------------------

fn tkn_getRulesForSystems sys_a sys_b = (

    local result = #()

    for rule in tkn_clash_rules do (
        local ra = toLower rule[1]
        local rb = toLower rule[2]
        local sa = toLower sys_a
        local sb = toLower sys_b

        if (ra == sa and rb == sb) or (ra == sb and rb == sa) then (
            append result rule
        )
    )

    return result
)

-- =============================================================================
-- CLASH DETECTION
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_generateClashID
-- Generates a unique ID for each clash.
-- -----------------------------------------------------------------------------

fn tkn_generateClashID = (
    tkn_clash_counter = tkn_clash_counter + 1
    local num = tkn_clash_counter
    local num_str = ""
    if num < 10 then num_str = "00" + num as string
    else if num < 100 then num_str = "0" + num as string
    else num_str = num as string
    return ("CLH-" + num_str)
)

-- -----------------------------------------------------------------------------
-- tkn_isFalsePositive
-- Filters out known false positives before reporting.
-- Based on best practices from Navisworks / BIMCollab workflows.
-- -----------------------------------------------------------------------------

fn tkn_isFalsePositive obj_a obj_b sys_a sys_b = (

    -- Rule 1: same system -- not a clash
    if (toLower sys_a) == (toLower sys_b) then return true

    -- Rule 2: same object -- not a clash
    if obj_a == obj_b then return true

    -- Rule 3: openings in masonry -- expected intersection
    if (toLower sys_a) == "openings" and (toLower sys_b) == "masonry" then return true
    if (toLower sys_a) == "masonry"  and (toLower sys_b) == "openings" then return true

    -- Rule 4: flooring on foundations -- expected contact
    if (toLower sys_a) == "flooring"     and (toLower sys_b) == "foundations" then return true
    if (toLower sys_a) == "foundations"  and (toLower sys_b) == "flooring"    then return true

    -- Rule 5: plastering on masonry -- expected contact
    if (toLower sys_a) == "plastering" and (toLower sys_b) == "masonry" then return true
    if (toLower sys_a) == "masonry"    and (toLower sys_b) == "plastering" then return true

    return false
)

-- -----------------------------------------------------------------------------
-- tkn_checkHardClash
-- Checks if two objects physically intersect.
-- Returns a clash array or undefined if no clash.
-- -----------------------------------------------------------------------------

fn tkn_checkHardClash obj_a obj_b rule = (

    -- Fast bbox pre-check
    local bbox_a = tkn_getWorldBBox obj_a
    local bbox_b = tkn_getWorldBBox obj_b

    if not (tkn_doBBoxesOverlap bbox_a bbox_b) then return undefined

    -- Detailed intersection check
    if not (intersects obj_a obj_b) then return undefined

    -- Clash confirmed
    local sys_a = tkn_getProperty obj_a "system"
    local sys_b = tkn_getProperty obj_b "system"
    local fam_a = tkn_getProperty obj_a "family"
    local fam_b = tkn_getProperty obj_b "family"

    local desc = "HARD CLASH: " + sys_a + " [" + obj_a.name + "] intersects " + sys_b + " [" + obj_b.name + "]"

    return #(tkn_generateClashID(), CLASH_HARD, rule[4], obj_a, obj_b, sys_a, sys_b, desc, CLASH_OPEN)
)

-- -----------------------------------------------------------------------------
-- tkn_checkSoftClash
-- Checks if two objects violate a minimum distance.
-- Returns a clash array or undefined if no clash.
-- -----------------------------------------------------------------------------

fn tkn_checkSoftClash obj_a obj_b rule = (

    local min_dist = rule[5]

    local dist = tkn_getDistanceBetween obj_a obj_b

    if dist >= min_dist then return undefined

    -- Already intersecting objects are reported as HARD not SOFT
    local bbox_a = tkn_getWorldBBox obj_a
    local bbox_b = tkn_getWorldBBox obj_b
    if tkn_doBBoxesOverlap bbox_a bbox_b then return undefined

    local sys_a = tkn_getProperty obj_a "system"
    local sys_b = tkn_getProperty obj_b "system"

    local desc = "SOFT CLASH: " + sys_a + " [" + obj_a.name + "] is " + (dist as string) + "m from " + sys_b + " [" + obj_b.name + "] (min: " + min_dist as string + "m)"

    return #(tkn_generateClashID(), CLASH_SOFT, rule[4], obj_a, obj_b, sys_a, sys_b, desc, CLASH_OPEN)
)

-- -----------------------------------------------------------------------------
-- tkn_runChecker
-- Main checker function. Runs all clash rules against all tagged objects.
-- Returns array of detected clashes.
-- -----------------------------------------------------------------------------

fn tkn_runChecker = (

    tkn_logInfo "Running TEKTON Checker..."

    -- Reset clash list and counter
    tkn_clash_list    = #()
    tkn_clash_counter = 0

    -- Load rules if not loaded
    if tkn_clash_rules.count == 0 then (
        tkn_loadRules()
    )

    if tkn_clash_rules.count == 0 then (
        tkn_logWarn "runChecker: no rules loaded. Aborting."
        return #()
    )

    -- Get all tagged objects
    local all_objects = tkn_listAll()

    if all_objects.count < 2 then (
        tkn_logWarn "runChecker: need at least 2 tagged objects."
        return #()
    )

    tkn_logInfo ("Checking " + all_objects.count as string + " objects against " + tkn_clash_rules.count as string + " rules...")

    -- Check every pair of objects
    local checked = 0
    local found   = 0

    for i = 1 to all_objects.count do (
        for j = (i + 1) to all_objects.count do (

            local obj_a = all_objects[i]
            local obj_b = all_objects[j]

            local sys_a = tkn_getProperty obj_a "system"
            local sys_b = tkn_getProperty obj_b "system"

            -- Skip if no rules apply to this pair
            local rules = tkn_getRulesForSystems sys_a sys_b
            if rules.count == 0 then continue

            -- Skip false positives
            if tkn_isFalsePositive obj_a obj_b sys_a sys_b then continue

            -- Run applicable rules
            for rule in rules do (

                local clash = undefined

                if rule[3] == CLASH_HARD then (
                    clash = tkn_checkHardClash obj_a obj_b rule
                ) else if rule[3] == CLASH_SOFT then (
                    clash = tkn_checkSoftClash obj_a obj_b rule
                )

                if clash != undefined then (
                    append tkn_clash_list clash
                    found = found + 1
                )
            )

            checked = checked + 1
        )
    )

    tkn_logInfo ("Checker complete. Pairs checked: " + checked as string + " | Clashes found: " + found as string)

    return tkn_clash_list
)

-- =============================================================================
-- CLASH VISUALIZATION
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_getClashColor
-- Returns the highlight color for a clash priority.
-- -----------------------------------------------------------------------------

fn tkn_getClashColor priority = (
    if priority == CLASH_CRITICA then return CLASH_COLOR_CRITICA
    if priority == CLASH_ALTA    then return CLASH_COLOR_ALTA
    if priority == CLASH_MEDIA   then return CLASH_COLOR_MEDIA
    return CLASH_COLOR_BAJA
)

-- -----------------------------------------------------------------------------
-- tkn_highlightClashes
-- Highlights all detected clashes in the viewport.
-- Objects with clashes get their wirecolor changed to clash priority color.
-- -----------------------------------------------------------------------------

fn tkn_highlightClashes = (

    if tkn_clash_list.count == 0 then (
        tkn_logWarn "highlightClashes: no clashes to highlight."
        return false
    )

    for clash in tkn_clash_list do (

        local priority = clash[3]
        local obj_a    = clash[4]
        local obj_b    = clash[5]
        local col      = tkn_getClashColor priority

        if obj_a != undefined then obj_a.wireColor = col
        if obj_b != undefined then obj_b.wireColor = col
    )

    tkn_logInfo ("Highlighted " + tkn_clash_list.count as string + " clashes.")
    return true
)

-- -----------------------------------------------------------------------------
-- tkn_clearHighlights
-- Restores original system colors after highlighting.
-- -----------------------------------------------------------------------------

fn tkn_clearHighlights = (
    tkn_applyColorsToAll()
    tkn_logInfo "Clash highlights cleared."
)

-- -----------------------------------------------------------------------------
-- tkn_printClashReport
-- Prints a formatted clash report to the Listener.
-- -----------------------------------------------------------------------------

fn tkn_printClashReport = (

    if tkn_clash_list.count == 0 then (
        print "[TEKTON CHECKER] No clashes detected."
        return true
    )

    print "============================================"
    print ("[TEKTON CHECKER] " + tkn_clash_list.count as string + " clashes detected:")
    print "============================================"

    for clash in tkn_clash_list do (
        local line = "[" + clash[3] + "] " + clash[1] + " | " + clash[8]
        print line
    )

    print "============================================"

    -- Summary by priority
    local n_critica = 0
    local n_alta    = 0
    local n_media   = 0
    local n_baja    = 0

    for clash in tkn_clash_list do (
        if clash[3] == CLASH_CRITICA then n_critica = n_critica + 1
        if clash[3] == CLASH_ALTA    then n_alta    = n_alta    + 1
        if clash[3] == CLASH_MEDIA   then n_media   = n_media   + 1
        if clash[3] == CLASH_BAJA    then n_baja    = n_baja    + 1
    )

    print ("CRITICA: " + n_critica as string + " | ALTA: " + n_alta as string + " | MEDIA: " + n_media as string + " | BAJA: " + n_baja as string)
    print "============================================"

    return true
)

-- =============================================================================
-- CLASH EXPORT
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_exportClashCSV
-- Exports the clash report to a CSV file.
-- -----------------------------------------------------------------------------

fn tkn_exportClashCSV = (

    if tkn_clash_list.count == 0 then (
        tkn_logWarn "exportClashCSV: no clashes to export."
        return false
    )

    local path = (tkn_getExportPath()) + "clash_report.csv"
    local file = openFile path mode:"w"

    if file == undefined then (
        tkn_logError ("exportClashCSV: could not create file -> " + path)
        return false
    )

    -- Header
    format "ID,Type,Priority,Object A,Object B,System A,System B,Description,Status\n" to:file

    -- Data rows
    for clash in tkn_clash_list do (
        local obj_a_name = if clash[4] != undefined then clash[4].name else "unknown"
        local obj_b_name = if clash[5] != undefined then clash[5].name else "unknown"

        format "%,%,%,%,%,%,%,%,%\n" \
            clash[1] clash[2] clash[3] \
            obj_a_name obj_b_name \
            clash[6] clash[7] \
            clash[8] clash[9] \
            to:file
    )

    close file
    tkn_logInfo ("Clash report exported -> " + path)
    return true
)

-- =============================================================================
-- CLASH MANAGEMENT
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_resolveClash
-- Marks a clash as resolved by ID.
-- -----------------------------------------------------------------------------

fn tkn_resolveClash clash_id = (

    for i = 1 to tkn_clash_list.count do (
        if tkn_clash_list[i][1] == clash_id then (
            tkn_clash_list[i][9] = CLASH_RESOLVED
            tkn_logInfo ("Clash resolved: " + clash_id)
            return true
        )
    )

    tkn_logWarn ("resolveClash: clash not found -> " + clash_id)
    return false
)

-- -----------------------------------------------------------------------------
-- tkn_ignoreClash
-- Marks a clash as ignored by ID.
-- Ignored clashes are excluded from future reports.
-- -----------------------------------------------------------------------------

fn tkn_ignoreClash clash_id = (

    for i = 1 to tkn_clash_list.count do (
        if tkn_clash_list[i][1] == clash_id then (
            tkn_clash_list[i][9] = CLASH_IGNORED
            tkn_logInfo ("Clash ignored: " + clash_id)
            return true
        )
    )

    tkn_logWarn ("ignoreClash: clash not found -> " + clash_id)
    return false
)

-- -----------------------------------------------------------------------------
-- tkn_getOpenClashes
-- Returns only open (unresolved, unignored) clashes.
-- -----------------------------------------------------------------------------

fn tkn_getOpenClashes = (

    local result = #()

    for clash in tkn_clash_list do (
        if clash[9] == CLASH_OPEN then (
            append result clash
        )
    )

    return result
)

-- =============================================================================

tkn_logInfo "Module loaded: tkn_checker.ms"
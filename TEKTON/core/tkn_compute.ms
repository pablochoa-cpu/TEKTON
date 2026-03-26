-- =============================================================================
-- TEKTON Module: Compute
-- File: tkn_compute.ms
-- Depends on: tekton_core.ms, tkn_log.ms, tkn_properties.ms,
--             tkn_geometry.ms, tkn_queries.ms
-- =============================================================================

-- Compute results storage
tkn_compute_results = #()

-- -----------------------------------------------------------------------------
-- tkn_getUnitForSystem
-- Returns measurement unit for a system.
-- -----------------------------------------------------------------------------

fn tkn_getUnitForSystem system = (
    local ml_systems = #("concrete_structure", "steel_structure", "plumbing", "drainage", "electrical", "gas", "metalwork")
    local m2_systems = #("masonry", "flooring", "plastering", "cladding", "roofing", "insulation")
    local m3_systems = #("foundations", "concrete_structure")

    for s in ml_systems do if (toLower s) == (toLower system) then return "ml"
    for s in m2_systems do if (toLower s) == (toLower system) then return "m2"
    return "un"
)

-- -----------------------------------------------------------------------------
-- tkn_computeObject
-- Returns measurement for a single object based on its system.
-- -----------------------------------------------------------------------------

fn tkn_computeObject obj = (

    if not (tkn_isTekton obj) then return 0.0

    local system = tkn_getProperty obj "system"
    local unit   = tkn_getUnitForSystem system

    if unit == "ml" then return (tkn_getObjectLength obj)
    if unit == "m2" then return (tkn_getObjectArea obj)
    if unit == "m3" then return (tkn_getObjectVolume obj)
    return 1.0
)

-- -----------------------------------------------------------------------------
-- tkn_computeBySystem
-- Computes total quantities grouped by system.
-- Returns array of #(system, total, unit, count)
-- -----------------------------------------------------------------------------

fn tkn_computeBySystem = (

    tkn_compute_results = #()

    for sys in TEKTON.valid_systems do (

        local objs  = tkn_filterBySystem sys
        if objs.count == 0 then continue

        local total = 0.0
        local unit  = tkn_getUnitForSystem sys

        for obj in objs do (
            total = total + (tkn_computeObject obj)
        )

        local rounded = (floor (total * 100 + 0.5)) / 100.0
        append tkn_compute_results #(sys, rounded, unit, objs.count)
    )

    tkn_logInfo ("Compute complete. " + tkn_compute_results.count as string + " systems with data.")
    return tkn_compute_results
)

-- -----------------------------------------------------------------------------
-- tkn_computeByFamily
-- Computes quantities grouped by system + family.
-- Returns array of #(system, family, total, unit, count)
-- -----------------------------------------------------------------------------

fn tkn_computeByFamily = (

    local results = #()
    local all_objs = tkn_listAll()

    -- Build unique system+family pairs
    local pairs = #()

    for obj in all_objs do (
        local sys = tkn_getProperty obj "system"
        local fam = tkn_getProperty obj "family"
        local key = sys + "|" + fam
        local found = false
        for p in pairs do if p == key then found = true
        if not found then append pairs key
    )

    -- Compute each pair
    for pair in pairs do (
        local parts = filterString pair "|"
        local sys   = parts[1]
        local fam   = parts[2]
        local objs  = tkn_filterBySystemAndFamily sys fam
        local unit  = tkn_getUnitForSystem sys
        local total = 0.0

        for obj in objs do total = total + (tkn_computeObject obj)

        local rounded = (floor (total * 100 + 0.5)) / 100.0
        append results #(sys, fam, rounded, unit, objs.count)
    )

    tkn_logInfo ("Compute by family complete. " + results.count as string + " entries.")
    return results
)

-- -----------------------------------------------------------------------------
-- tkn_computeByLevel
-- Computes quantities grouped by level.
-- Returns array of #(level, system, total, unit, count)
-- -----------------------------------------------------------------------------

fn tkn_computeByLevel = (

    local results = #()

    for n in TEKTON.levels do (
        local level_name = n[1]
        local objs = tkn_filterByLevel level_name
        if objs.count == 0 then continue

        for sys in TEKTON.valid_systems do (
            local sys_objs = #()
            for obj in objs do (
                local s = tkn_getProperty obj "system"
                if (toLower s) == (toLower sys) then append sys_objs obj
            )
            if sys_objs.count == 0 then continue

            local unit  = tkn_getUnitForSystem sys
            local total = 0.0
            for obj in sys_objs do total = total + (tkn_computeObject obj)

            local rounded = (floor (total * 100 + 0.5)) / 100.0
            append results #(level_name, sys, rounded, unit, sys_objs.count)
        )
    )

    tkn_logInfo ("Compute by level complete. " + results.count as string + " entries.")
    return results
)

-- -----------------------------------------------------------------------------
-- tkn_printComputeReport
-- Prints formatted compute report to Listener.
-- -----------------------------------------------------------------------------

fn tkn_printComputeReport = (

    if tkn_compute_results.count == 0 then (
        tkn_computeBySystem()
    )

    print "============================================"
    print "[TEKTON COMPUTE] Quantities by system:"
    print "============================================"

    for item in tkn_compute_results do (
        print (item[1] + ": " + item[2] as string + " " + item[3] + " (" + item[4] as string + " elements)")
    )

    print "============================================"
)

-- -----------------------------------------------------------------------------
-- tkn_exportComputeCSV
-- Exports compute results to CSV.
-- -----------------------------------------------------------------------------

fn tkn_exportComputeCSV = (

    local results = tkn_computeByFamily()

    if results.count == 0 then (
        tkn_logWarn "exportComputeCSV: no data to export."
        return false
    )

    local path = (tkn_getExportPath()) + "compute_report.csv"
    local file = openFile path mode:"w"

    if file == undefined then (
        tkn_logError ("exportComputeCSV: could not create file -> " + path)
        return false
    )

    format "System,Family,Total,Unit,Count\n" to:file

    for item in results do (
        format "%,%,%,%,%\n" item[1] item[2] item[3] item[4] item[5] to:file
    )

    close file
    tkn_logInfo ("Compute report exported -> " + path)
    return true
)

-- =============================================================================

tkn_logInfo "Module loaded: tkn_compute.ms"
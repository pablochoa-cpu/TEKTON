-- =============================================================================
-- TEKTON Core Loader
-- Version: 1.0
-- Description: Main entry point. Defines the global struct and loads
--              all core modules in dependency order.
-- =============================================================================

-- Global struct -- all modules attach their functions here
struct TEKTON_Struct (

    -- -------------------------------------------------------------------------
    -- SYSTEM CONSTANTS
    -- -------------------------------------------------------------------------

    version      = "1.0",
    prefix       = "tkn_",
    ext_prefix   = "tkn_x_",
    app_name     = "TEKTON",

    -- -------------------------------------------------------------------------
    -- VALID SYSTEMS
    -- -------------------------------------------------------------------------

    valid_systems = #("foundations", "concrete_structure", "steel_structure", "masonry", "insulation", "flooring", "plastering", "cladding", "roofing", "openings", "metalwork", "plumbing", "drainage", "electrical", "gas", "site_works", "equipment", "vegetation", "generic"),

    -- -------------------------------------------------------------------------
    -- DEFAULT LEVELS
    -- Format: #(name, z_start, z_end) -- meters
    -- -------------------------------------------------------------------------

    levels = #(#("foundations", -1.5, 0.0), #("ground_floor", 0.0, 3.0), #("first_floor", 3.0, 6.0), #("roof", 6.0, 7.0)),

    -- -------------------------------------------------------------------------
    -- VALID VALUES FOR CONTROLLED FIELDS
    -- -------------------------------------------------------------------------

    valid_finishes = #("visible", "plastered", "clad", "painted", "undefined"),

    valid_phases = #("existing", "to_demolish", "new", "provisional"),

    valid_statuses = #("projected", "in_progress", "completed", "inspected"),

    -- -------------------------------------------------------------------------
    -- PROJECT DATA
    -- -------------------------------------------------------------------------

    project_name   = "",
    project_type   = "",
    project_date   = "",
    project_active = false,

    -- -------------------------------------------------------------------------
    -- LOG STATE
    -- -------------------------------------------------------------------------

    log_entries       = #(),
    log_max_entries   = 200,
    log_count_info    = 0,
    log_count_warn    = 0,
    log_count_error   = 0,
    log_has_new_error = false,
    log_has_new_warn  = false,

    LOG_INFO  = "INFO",
    LOG_WARN  = "WARN",
    LOG_ERROR = "ERROR",

    -- -------------------------------------------------------------------------
    -- LOCALE STATE
    -- -------------------------------------------------------------------------

    current_locale = "en",
    locale_strings = #(),

    -- -------------------------------------------------------------------------
    -- UI STATE
    -- -------------------------------------------------------------------------

    bim_mode_active = false,

    -- -------------------------------------------------------------------------
    -- SYSTEM COLORS
    -- Format: #(system_name, r, g, b)
    -- -------------------------------------------------------------------------

    system_colors = #(#("foundations", 101, 67, 33), #("concrete_structure", 150, 150, 150), #("steel_structure", 70, 130, 180), #("masonry", 210, 105, 30), #("insulation", 255, 215, 0), #("flooring", 188, 170, 164), #("plastering", 245, 245, 220), #("cladding", 160, 82, 45), #("roofing", 178, 34, 34), #("openings", 60, 179, 113), #("metalwork", 112, 128, 144), #("plumbing", 30, 144, 255), #("drainage", 139, 90, 43), #("electrical", 255, 200, 0), #("gas", 255, 140, 0), #("site_works", 107, 142, 35), #("equipment", 147, 112, 219), #("vegetation", 34, 139, 34), #("generic", 180, 180, 180)),

    -- -------------------------------------------------------------------------
    -- FAMILY TABLES
    -- Parallel arrays -- index matches across all three
    -- -------------------------------------------------------------------------

    family_names = #("beam", "column", "slab", "stair", "lintel", "tie_beam", "steel_beam", "steel_column", "ipn_profile", "upn_profile", "sheet", "purlin", "wall_30", "wall_15", "partition", "compound_wall", "horiz_insulation", "vert_insulation", "thermal_insulation", "floor_screed", "floor_tile", "floor_concrete", "floor_cement", "floor_gravel", "skirting_tile", "skirting_stone", "skirting_cement", "plaster_scratch", "plaster_fine", "plaster_ext", "plaster_base", "roof_slab", "roof_sheet", "roof_tiles", "pergola", "aluminium_window", "aluminium_door", "gate", "sheet_door", "timber_door", "railing", "barrier", "metal_stair", "chimney", "cold_water_pipe", "hot_water_pipe", "water_tank", "tap", "toilet", "bidet", "shower", "sink", "water_heater", "drainage_pipe", "inspection_chamber", "cleanout", "trap", "septic_tank", "absorption_pit", "conduit", "junction_box", "panel", "power_outlet", "switch", "light_fitting", "gas_pipe", "gas_valve", "gas_meter", "gas_appliance", "roman_well", "pile", "footing", "strip_footing", "raft", "foundation_beam", "pavement", "fence", "ext_floor", "furniture", "render_block", "generic_block", "tree", "shrub", "lawn", "planter", "generic"),

    family_codes = #("BEM", "COL", "SLB", "STR", "LNT", "TIB", "SBM", "SCL", "IPN", "UPN", "SHT", "PRL", "W30", "W15", "PAR", "CWL", "HAI", "VAI", "TAI", "SCR", "FTL", "FCO", "FCE", "FGR", "SKT", "SKS", "SKC", "PLB", "PLF", "PLE", "PLR", "RSL", "RSH", "RTL", "PER", "AWN", "ADR", "GAT", "SHD", "TMD", "RAL", "BAR", "MST", "CHI", "CWP", "HWP", "WTK", "TAP", "TOI", "BID", "SHW", "SNK", "WHT", "DRP", "ICH", "CLO", "TRP", "SPT", "ABP", "CDT", "JBX", "PNL", "PWO", "SWT", "LFT", "GSP", "GSV", "GSM", "GSA", "RWL", "PIL", "FTG", "STF", "RFT", "FBM", "PAV", "FEN", "EFL", "FUR", "RBL", "GBL", "TRE", "SHR", "LWN", "PLT", "GEN"),

    family_systems = #("concrete_structure", "concrete_structure", "concrete_structure", "concrete_structure", "concrete_structure", "concrete_structure", "steel_structure", "steel_structure", "steel_structure", "steel_structure", "steel_structure", "steel_structure", "masonry", "masonry", "masonry", "masonry", "insulation", "insulation", "insulation", "flooring", "flooring", "flooring", "flooring", "flooring", "flooring", "flooring", "flooring", "plastering", "plastering", "plastering", "plastering", "roofing", "roofing", "roofing", "roofing", "openings", "openings", "openings", "openings", "openings", "metalwork", "metalwork", "metalwork", "metalwork", "plumbing", "plumbing", "plumbing", "plumbing", "plumbing", "plumbing", "plumbing", "plumbing", "plumbing", "drainage", "drainage", "drainage", "drainage", "drainage", "drainage", "electrical", "electrical", "electrical", "electrical", "electrical", "electrical", "gas", "gas", "gas", "gas", "foundations", "foundations", "foundations", "foundations", "foundations", "foundations", "site_works", "site_works", "site_works", "equipment", "equipment", "equipment", "vegetation", "vegetation", "vegetation", "vegetation", "generic"),

    -- placeholder
    dummy = 0

)

-- =============================================================================
-- Create global instance
-- =============================================================================

TEKTON = TEKTON_Struct()

-- =============================================================================
-- Load all modules in dependency order
-- =============================================================================

core_path = (getFilenamePath (getThisScriptFilename()))

fileIn (core_path + "tkn_log.ms")
fileIn (core_path + "tkn_properties.ms")
fileIn (core_path + "tkn_levels.ms")
fileIn (core_path + "tkn_files.ms")
fileIn (core_path + "tkn_project.ms")
fileIn (core_path + "tkn_queries.ms")
fileIn (core_path + "tkn_colors.ms")
fileIn (core_path + "tkn_undo.ms")
fileIn (core_path + "tkn_tag.ms")
fileIn (core_path + "tkn_extended.ms")
--fileIn (core_path + "tkn_geometry.ms")
--fileIn (core_path + "tkn_locale.ms")

print "TEKTON: All modules loaded."
print ("TEKTON: Version " + TEKTON.version + " ready.")
-- =============================================================================
-- TEKTON Module: Locale
-- File: tkn_locale.ms
-- Depends on: tekton_core.ms, tkn_log.ms, tkn_files.ms
-- Block: 12
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_loadLocale
-- Loads a language file into memory.
-- Falls back to English if requested language not found.
--
-- Parameters:
--   lang_code -> string ("en", "es", "pt", etc.)
-- -----------------------------------------------------------------------------

fn tkn_loadLocale lang_code = (

    local scripts_path = (getDir #scripts)
    local path = scripts_path + "\\TEKTON\\locales\\" + lang_code + ".cfg"

    -- Fallback to English if not found
    if not (doesFileExist path) then (
        tkn_logWarn ("Locale '" + lang_code + "' not found. Falling back to English.")
        path = scripts_path + "\\TEKTON\\locales\\en.cfg"
    )

    if not (doesFileExist path) then (
        tkn_logError "No locale files found. UI will use raw keys."
        return false
    )

    -- Clear current dictionary
    TEKTON.locale_strings = #()

    -- Read and parse
    local lines = tkn_readCFG_path path

    for line in lines do (
        local parts = tkn_parseLine line
        if parts.count == 2 then (
            append TEKTON.locale_strings #(parts[1], parts[2])
        )
    )

    TEKTON.current_locale = lang_code
    tkn_logInfo ("Locale loaded: " + lang_code + " (" + TEKTON.locale_strings.count as string + " strings)")
    return true
)

-- -----------------------------------------------------------------------------
-- tkn_t
-- Translate -- returns the UI text for a given key.
-- Short name intentional -- used everywhere in the UI.
-- Returns the key itself if translation not found.
--
-- Parameters:
--   key -> string (ex: "btn_tag")
--
-- Usage:
--   messageBox (tkn_t "msg_tagged")
--   label text:(tkn_t "lbl_system")
-- -----------------------------------------------------------------------------

fn tkn_t key = (

    for pair in TEKTON.locale_strings do (
        if pair[1] == key then (
            return pair[2]
        )
    )

    -- Key not found -- return key as fallback
    tkn_logWarn ("Missing translation for key: '" + key + "'")
    return key
)

-- -----------------------------------------------------------------------------
-- tkn_setLocale
-- Changes the active language at runtime.
--
-- Parameters:
--   lang_code -> string ("en", "es")
-- -----------------------------------------------------------------------------

fn tkn_setLocale lang_code = (

    tkn_loadLocale lang_code

    -- Save preference
    local lines = #("locale | " + lang_code)
    tkn_writeCFG "preferences" lines "User preferences"

    tkn_logInfo ("Language changed: " + lang_code)
)

-- -----------------------------------------------------------------------------
-- tkn_getAvailableLocales
-- Scans the locales folder and returns available languages.
-- Used to populate the language selector in settings.
-- -----------------------------------------------------------------------------

fn tkn_getAvailableLocales = (

    local scripts_path  = (getDir #scripts)
    local locales_path  = scripts_path + "\\TEKTON\\locales\\"
    local available     = #()
    local files         = getFiles (locales_path + "*.cfg")

    for f in files do (
        local filename = getFilenameFile f
        append available filename
    )

    return available
)

-- =============================================================================

tkn_logInfo "Module loaded: tkn_locale.ms"
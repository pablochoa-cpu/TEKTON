-- =============================================================================
-- TEKTON Module: Undo
-- File: tkn_undo.ms
-- Depends on: tekton_core.ms, tkn_log.ms
-- Block: 11b
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_beginUndo
-- Opens a Max undo block.
-- Call before any operation that modifies the scene.
--
-- Parameters:
--   label -> string shown in Edit menu (ex: "Tag Object")
-- -----------------------------------------------------------------------------

fn tkn_beginUndo label = (
    theHold.Begin()
    tkn_logInfo ("Undo block opened: " + label)
)

-- -----------------------------------------------------------------------------
-- tkn_acceptUndo
-- Closes and accepts the undo block.
-- The operation is now undoable with Ctrl+Z.
--
-- Parameters:
--   label -> same label used in tkn_beginUndo
-- -----------------------------------------------------------------------------

fn tkn_acceptUndo label = (
    theHold.Accept ("TEKTON: " + label)
    tkn_logInfo ("Undo block accepted: " + label)
)

-- -----------------------------------------------------------------------------
-- tkn_cancelUndo
-- Cancels the undo block and reverts all changes.
-- Call when an operation fails midway.
-- -----------------------------------------------------------------------------

fn tkn_cancelUndo = (
    theHold.Cancel()
    tkn_logWarn "Undo block cancelled - changes reverted."
)

-- =============================================================================

tkn_logInfo "Module loaded: tkn_undo.ms"
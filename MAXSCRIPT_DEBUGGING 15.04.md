# MAXScript Debugging Guide - TEKTON Project

## Critical Rules Learned Through Pain

### 1. Event Handler Syntax - THE BIG ONE

**NEVER MIX ROLLOUT AND DOTNET EVENT HANDLERS**

```maxscript
-- ❌ WRONG - Causes "Syntax error: at name, expected while"
local btn = dotNetObject "System.Windows.Forms.Button"
on btn click do someFunction()

-- ✅ CORRECT - Use dotNet.addEventHandler
local btn = dotNetObject "System.Windows.Forms.Button"
dotNet.addEventHandler btn "Click" someFunction
```

**Rule:**
- `on control event do` → ONLY for `dotNetControl` inside `rollout`
- `dotNet.addEventHandler` → ONLY for `dotNetObject` created dynamically

**Handler Function Signature:**
```maxscript
-- ❌ WRONG - 'this' doesn't work with dotNet.addEventHandler
fn myHandler =
(
    local btn = this
    local value = btn.Tag
)

-- ✅ CORRECT - Use sender parameter 's'
fn myHandler s e =
(
    local value = s.Tag
)
```

---

### 2. Local Variables After Loops = Death

**NEVER declare `local` after a loop that contains event handlers**

```maxscript
-- ❌ WRONG - Parser explosion
for btn in buttons do
    on btn click do handleClick.call btn

local footer_panel = dotNetObject "System.Windows.Forms.Panel"

-- ✅ CORRECT - Declare BEFORE the loop
local footer_panel = dotNetObject "System.Windows.Forms.Panel"

for btn in buttons do
    dotNet.addEventHandler btn "Click" handleClick
```

**Why:** MAXScript treats the entire `for` block + event handler as a unit. Putting `local` after breaks the parser's brain.

**Fix Pattern:**
1. Find all loops with event handlers
2. Move ALL `local` declarations ABOVE those loops
3. Group related event handler assignments together

---

### 3. Color Creation - dotNetObject vs dotNetClass

**Colors require static methods, not constructors**

```maxscript
-- ❌ WRONG - "No constructor found"
TKN_C_BG = dotNetObject "System.Drawing.Color" 19 27 69

-- ✅ CORRECT - Use FromArgb static method
TKN_C_BG = (dotNetClass "System.Drawing.Color").FromArgb 19 27 69
```

**Common Color Patterns:**
```maxscript
-- RGB color
local red = (dotNetClass "System.Drawing.Color").FromArgb 255 0 0

-- ARGB with alpha
local semi_red = (dotNetClass "System.Drawing.Color").FromArgb 128 255 0 0

-- Transparent
local clear = (dotNetClass "System.Drawing.Color").Transparent

-- System colors
local winBG = (dotNetClass "System.Drawing.SystemColors").Control
```

---

### 4. The `drawing.color.transparent` Trap

**`drawing` object doesn't exist in MAXScript**

```maxscript
-- ❌ WRONG - "Unknown property: 'color' in undefined"
lbl.BackColor = drawing.color.transparent

-- ✅ CORRECT
lbl.BackColor = (dotNetClass "System.Drawing.Color").Transparent
```

**Quick Fix:** Find/Replace
```
FIND: drawing.color.transparent
REPLACE: (dotNetClass "System.Drawing.Color").Transparent
```

---

### 5. Module Loading Order

**Functions must exist BEFORE they're called**

```maxscript
-- ❌ WRONG - tekton_core.ms
fileIn "tkn_ui.ms"              -- Calls tkn_ui_createSystemsTab
fileIn "tkn_ui_systems.ms"       -- Defines it (TOO LATE)

-- ✅ CORRECT
fileIn "tkn_ui.ms"              -- Only defines tkn_showUI function
fileIn "tkn_ui_systems.ms"      -- Defines tab creators
fileIn "tkn_ui_levels.ms"
-- ... all tab modules ...
-- User manually calls: tkn_showUI()
```

**Golden Rule:** 
- Modules should ONLY define functions/globals
- Never execute code at module load (except initialization)
- User explicitly calls entry points like `tkn_showUI()`

---

### 6. Inline Functions in Loops - Forbidden

**MAXScript doesn't allow anonymous functions inside loops**

```maxscript
-- ❌ WRONG - Syntax error
for btn in buttons do
(
    on btn click do (fn s e = print s.Tag; s e)()
)

-- ✅ CORRECT - Define function globally, pass data via Tag
fn handleClick s e =
(
    print (s.Tag)
)

for btn in buttons do
(
    btn.Tag = someData
    dotNet.addEventHandler btn "Click" handleClick
)
```

---

### 7. Debugging Workflow

**Step-by-step error isolation:**

1. **Load modules manually one-by-one:**
```maxscript
fileIn "C:\\path\\to\\module1.ms"
fileIn "C:\\path\\to\\module2.ms"
-- See which one fails
```

2. **Check function existence:**
```maxscript
tkn_someFunction  -- Returns 'undefined' if not loaded
```

3. **Wrap EVERYTHING in try/catch:**
```maxscript
try
(
    -- Your code
)
catch (print (getCurrentException()))
```

4. **Use print for checkpoints:**
```maxscript
fn myFunction =
(
    print "START myFunction"
    -- code
    print "MIDDLE myFunction"
    -- code
    print "END myFunction"
)
```

5. **Check variable state:**
```maxscript
print ("Variable state: " + (myVar as string))
```

---

### 8. Common Syntax Traps

#### `+=` operator doesn't exist
```maxscript
-- ❌ WRONG
x += 5

-- ✅ CORRECT
x = x + 5
```

#### `by` is a reserved word
```maxscript
-- ❌ WRONG
local by = 10

-- ✅ CORRECT
local step_by = 10
```

#### `local` at top level = error
```maxscript
-- ❌ WRONG (outside any function/block)
local x = 10

-- ✅ CORRECT
global x = 10
```

#### `exit` only in loops
```maxscript
-- ❌ WRONG
if condition then exit

-- ✅ CORRECT
if condition then return undefined
```

---

### 9. Units and Properties

```maxscript
-- ✅ CORRECT
units.SystemType = #meters   -- NOT #metric
units.DisplayType = #metric  -- NOT #meters

-- Layer locking
layer.Lock = true            -- NOT layer.isLocked

-- Node transform
tm = getNodeTM obj           -- Takes 1 arg, NOT getNodeTM obj 0
```

---

### 10. File Handling Best Practices

**Always use double backslashes in paths:**
```maxscript
-- ✅ CORRECT
fileIn "C:\\Users\\Pablo\\script.ms"

-- ❌ WRONG (single backslash = escape char)
fileIn "C:\Users\Pablo\script.ms"
```

**Use getFilenamePath for relative paths:**
```maxscript
core_path = getFilenamePath (getThisScriptFilename())
fileIn (core_path + "module.ms")
```

---

### 11. Common Error Messages Decoded

| Error | Cause | Fix |
|-------|-------|-----|
| `Syntax error: at local, expected while` | `local` after loop with event handler | Move `local` before loop |
| `No constructor found` | Using `dotNetObject` for static method | Use `dotNetClass` |
| `Unknown property: "color" in undefined` | `drawing.color.transparent` | Use `(dotNetClass "System.Drawing.Color").Transparent` |
| `Unknown property: "tag" in undefined` | Using `this` in dotNet handler | Use `s` parameter |
| `Call needs function or class, got: undefined` | Function not loaded yet | Check module load order |
| `Type error: Call needs function` | Missing function definition | Ensure module loaded |

---

### 12. dotNetObject vs dotNetControl vs dotNetClass

```maxscript
-- dotNetObject - Create instance dynamically
local btn = dotNetObject "System.Windows.Forms.Button"
btn.Text = "Click"

-- dotNetControl - Declare in rollout (DIFFERENT SYNTAX)
rollout myRollout "Test"
(
    dotNetControl btn "System.Windows.Forms.Button"
    on btn click do print "Clicked"  -- Native event syntax
)

-- dotNetClass - Access static members
local color = (dotNetClass "System.Drawing.Color").FromArgb 255 0 0
local font = dotNetClass "System.Drawing.Font"
```

---

### 13. Event Handler Patterns

**Pattern 1: Single control**
```maxscript
fn handleClick s e =
(
    print (s.Text)
)

local btn = dotNetObject "System.Windows.Forms.Button"
dotNet.addEventHandler btn "Click" handleClick
```

**Pattern 2: Multiple controls, same handler**
```maxscript
fn handleClick s e =
(
    case s.Tag of
    (
        "save": print "Save clicked"
        "load": print "Load clicked"
    )
)

for action in #("save", "load") do
(
    local btn = dotNetObject "System.Windows.Forms.Button"
    btn.Tag = action
    dotNet.addEventHandler btn "Click" handleClick
)
```

**Pattern 3: Dropdown selection changed**
```maxscript
fn handleSelectionChange s e =
(
    if s.SelectedIndex >= 0 then
    (
        local item = s.Items.Item[s.SelectedIndex] as string
        print ("Selected: " + item)
    )
)

local combo = dotNetObject "System.Windows.Forms.ComboBox"
dotNet.addEventHandler combo "SelectedIndexChanged" handleSelectionChange
```

---

### 14. Prevent Future Breaks - Checklist

Before committing code, verify:

- [ ] All `local` declarations are BEFORE loops with event handlers
- [ ] No `on X click do` syntax with `dotNetObject`
- [ ] All event handlers use `s e` parameters, not `this`
- [ ] All colors use `(dotNetClass "System.Drawing.Color").FromArgb`
- [ ] No `drawing.color.transparent` anywhere
- [ ] All functions defined globally (not inside loops)
- [ ] Module load order matches dependency tree
- [ ] No inline anonymous functions
- [ ] All paths use double backslashes `\\`
- [ ] No `+=` operators (use `x = x + n`)
- [ ] Try/catch blocks on all major functions
- [ ] No `local` at top-level scope

---

### 15. Safe Refactoring Pattern

When moving from rollout to dotNet:

**OLD (rollout):**
```maxscript
rollout myUI "Test"
(
    dotNetControl btn "Button"
    on btn click do print "Hi"
)
createDialog myUI
```

**NEW (dotNet):**
```maxscript
-- 1. Define handler FIRST
fn handleClick s e =
(
    print "Hi"
)

-- 2. Create UI
fn createUI =
(
    local form = dotNetObject "System.Windows.Forms.Form"
    local btn = dotNetObject "System.Windows.Forms.Button"
    
    -- 3. Configure
    btn.Text = "Click"
    form.Controls.Add btn
    
    -- 4. Attach handler LAST
    dotNet.addEventHandler btn "Click" handleClick
    
    form.Show()
)
```

---

### 16. Testing Strategy

**Progressive Loading:**
```maxscript
-- Test 1: Load core only
fileIn "tekton_core.ms"
print TEKTON.version  -- Should print version

-- Test 2: Load one UI module
fileIn "tkn_ui.ms"
print tkn_showUI  -- Should print function definition

-- Test 3: Call function
tkn_showUI()
-- UI should appear

-- Test 4: Click buttons
-- Check listener for errors
```

**Isolate Problems:**
```maxscript
-- Comment out sections to find break point
tkn_ui_createSystemsTab panel
-- tkn_ui_createLevelsTab panel
-- tkn_ui_createCheckerTab panel
```

---

### 17. Emergency Fixes

**When UI won't close:**
```maxscript
for w in (windows.getChildrenHWND 0) where w[5] == "TEKTON BIM" do
    windows.sendMessage w[1] 0x0010 0 0  -- WM_CLOSE
```

**Clear all globals:**
```maxscript
clearListener()
gc light:true
```

**Force reload module:**
```maxscript
tkn_ui_floater = undefined
fileIn "C:\\...\\tkn_ui.ms"
```

---

### 18. Code Review Red Flags

Watch for these patterns in PRs:

🚩 `on btn click do` with `dotNetObject`
🚩 `local` after `for` loops
🚩 `dotNetObject "System.Drawing.Color"`
🚩 `drawing.color.transparent`
🚩 `this` in event handlers
🚩 Anonymous functions in loops
🚩 Missing try/catch blocks
🚩 Executing code at module load
🚩 Single backslashes in paths

---

### 19. Performance Tips

**Batch UI updates:**
```maxscript
-- Suspend layout during bulk changes
panel.SuspendLayout()

for i = 1 to 100 do
(
    local btn = dotNetObject "System.Windows.Forms.Button"
    panel.Controls.Add btn
)

panel.ResumeLayout()
```

**Clear controls efficiently:**
```maxscript
panel.Controls.Clear()  -- Better than removing one-by-one
```

---

### 20. Documentation Template

Every UI module should have:

```maxscript
-- module_name.ms
-- Brief description
--
-- DEPENDENCIES:
--   - tkn_log.ms
--   - tkn_properties.ms
--
-- PROVIDES:
--   - tkn_functionName (args) -> return
--
-- USAGE:
--   fileIn "module_name.ms"
--   tkn_functionName()

try
(
    -- Globals
    global var1
    global var2
    
    -- Functions
    fn tkn_myFunction =
    (
        try
        (
            -- Implementation
        )
        catch (tkn_logError ("myFunction error: " + getCurrentException()))
    )
    
    tkn_logInfo "Module loaded: module_name.ms"
)
catch (tkn_logError ("module_name.ms load error: " + getCurrentException()))
```

---

## Summary

**The Three Golden Rules:**

1. **Event handlers are NOT rollout syntax** - Use `dotNet.addEventHandler` with global functions
2. **Declare ALL locals BEFORE loops** - Parser treats loop+handler as atomic block
3. **Static methods need dotNetClass** - Colors, fonts, system types use class methods

Follow these and 90% of MAXScript pain disappears.

---

**Last Updated:** 2026-04-15
**Author:** TEKTON Development Team
**Status:** Living Document - Add new traps as discovered

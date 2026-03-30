# TEKTON — Contexto de Proyecto

## Descripcion
Sistema BIM para 3ds Max en MAXScript. Open source. i18n ES/EN.
Repo: github.com/pablochoa-cpu/TEKTON

## Protocolo TOKEN-SAVER (activo siempre)
- Sin saludos ni introducciones
- Solo bloque de codigo modificado, nunca script completo salvo solicitud explicita
- Sin explicaciones salvo palabra clave "EXPLICAR"
- try/catch siempre incluido
- UI: eventos nativos MAXScript `on btn click do` para dotNetControl del rollout
- dotNet.addEventHandler solo para dotNetObject (nunca dotNetControl)
- NUNCA funciones inline `(fn s e = ...)` dentro de loops — usar funciones globales con s.Tag

## Rutas
- Trabajo (9-18hs ARG): C:\Users\Usuario\Documentos\3ds Max 2025\scripts\TEKTON\
- Casa: C:\Program Files\Autodesk\3ds Max 2025\scripts\TEKTON\
- Locales: subcarpeta locales\ dentro de cada ruta
- Rules.cfg: [escena]\TEKTON\config\
- Flujo: VS Code -> Commit/Push GitHub -> Copiar manual a carpeta Max

## Modulos core completados
```
tekton_core.ms    loader + struct global
tkn_log.ms        log INFO/WARN/ERROR
tkn_properties.ms read/write/validate propiedades BIM
tkn_levels.ms     niveles + capas Max + planos referencia
tkn_files.ms      CFG read/write + backup + callbacks
tkn_project.ms    wizard + init + save/load proyecto
tkn_queries.ms    filtros de escena + select viewport
tkn_undo.ms       theHold wrapper
tkn_colors.ms     colores por sistema + BIM mode toggle
tkn_tag.ms        tagObject + untag + tagSelection + tagMultiple
tkn_extended.ms   propiedades tkn_x_
tkn_geometry.ms   bbox + medidas + intersect
tkn_locale.ms     i18n ES/EN desde .cfg
tkn_checker.ms    clash detection HARD/SOFT + report + CSV
tkn_compute.ms    computos por sistema + exportacion CSV
```

## Modulos UI completados
```
tkn_ui.ms           panel principal flotante 600px
tkn_ui_systems.ms   tab SYSTEMS (ver detalle abajo)
tkn_ui_levels.ms    tab LEVELS
tkn_ui_checker.ms   tab CHECKER
tkn_ui_compute.ms   tab COMPUTE
tkn_ui_log.ms       tab LOG
tkn_ui_settings.ms  tab SETTINGS
```

## Orden del loader en tekton_core.ms
```
fileIn (core_path + "tkn_log.ms")
fileIn (core_path + "tkn_properties.ms")
fileIn (core_path + "tkn_levels.ms")
fileIn (core_path + "tkn_files.ms")
fileIn (core_path + "tkn_project.ms")
fileIn (core_path + "tkn_queries.ms")
fileIn (core_path + "tkn_undo.ms")
fileIn (core_path + "tkn_colors.ms")
fileIn (core_path + "tkn_tag.ms")
fileIn (core_path + "tkn_extended.ms")
fileIn (core_path + "tkn_geometry.ms")
fileIn (core_path + "tkn_locale.ms")
fileIn (core_path + "tkn_checker.ms")
fileIn (core_path + "tkn_compute.ms")
fileIn (core_path + "tkn_ui.ms")
fileIn (core_path + "tkn_ui_systems.ms")
fileIn (core_path + "tkn_ui_levels.ms")
fileIn (core_path + "tkn_ui_checker.ms")
fileIn (core_path + "tkn_ui_compute.ms")
fileIn (core_path + "tkn_ui_log.ms")
fileIn (core_path + "tkn_ui_settings.ms")
```

## Tab SYSTEMS - detalle
- Panel izquierdo (340px):
  - Systems Overview con [V/H] y [U/L] por fila (hide/lock toggle)
  - Tag Selection: dropdowns SYSTEM/FAMILY/LEVEL/FINISH
  - Botones: [TAG] [TAG BY NAME] [EXISTING]
  - Inspector: propiedades del objeto seleccionado
  - Action buttons: SELECT / FREEZE / ISOLATE / HIDE / COLOR / UNHIDE ALL
- Panel derecho (238px): grilla 3x7 launcher por sistema con colores

## Arquitectura de datos
- Propiedades estandar: tkn_id, tkn_system, tkn_family, tkn_level,
  tkn_finish, tkn_phase, tkn_status, tkn_material, tkn_description, tkn_version
- Propiedades extendidas: tkn_x_[nombre]
- ID format: SYSCOD-FAMCOD-NNN  ex: CST-BEM-001
- Clash format: #(id, type, priority, obj_a, obj_b, sys_a, sys_b, desc, status)

## Fixes criticos MAXScript 3ds Max 2025
- units.SystemType  = #meters  (no #metric)
- units.DisplayType = #metric  (no #meters)
- layer.Lock        (no isLocked)
- getNodeTM obj     (no getNodeTM obj 0)
- include           -> palabra reservada -> usar do_include
- local en top level -> prohibido
- inputBox          -> no existe -> usar rollout con globals
- dialogs.isOpen    -> no existe -> usar on close event
- TEKTON.fn = fn    -> no funciona en struct -> funciones globales tkn_
- return desnudo en event handlers -> prohibido -> usar guard if not
- separator fuera de group en rollout -> error de parser
- backColor en buttons -> no existe
- exit solo valido dentro de loops for/while
- arrays multilinea con \ -> riesgoso -> una sola linea
- LF puro sin CRLF ni BOM
- Solo ASCII-127 en archivos .ms
- dotNet.addEventHandler NO funciona con dotNetControl del rollout
- on btn click do -> eventos nativos para dotNetControl en rollout
- by -> palabra reservada en MAXScript
- fn inline (fn s e = ...) dentro de loops -> NO permitido -> usar fn global + s.Tag
- CLASH_RESOLVED etc como globals -> pueden ser undefined -> usar strings literales

## Colores UI
```
TKN_C_BG     = FromArgb 19  27  69   (#131b45 azul oscuro)
TKN_C_BG2    = FromArgb 28  38  90   (#1b2660 azul medio)
TKN_C_BORDER = FromArgb 17  35  79
TKN_C_TEXT   = FromArgb 224 224 224
TKN_C_TEXT2  = FromArgb 136 136 136
TKN_C_ACCENT = FromArgb 39  168 242  (#27a8f2 azul claro)
TKN_C_BLUE   = FromArgb 10  127 194
TKN_C_YELLOW = FromArgb 255 184 0
TKN_C_GREEN  = FromArgb 61  170 92
TKN_C_RED    = FromArgb 204 51  0
TKN_C_WHITE  = FromArgb 255 255 255
```

## Sistemas validos
foundations, concrete_structure, steel_structure, masonry, insulation,
flooring, plastering, cladding, roofing, openings, metalwork, plumbing,
drainage, electrical, gas, site_works, equipment, vegetation, generic

## Comando para abrir la UI
```maxscript
tkn_showUI()
```

## Comando para recargar desde cero
```maxscript
fileIn "C:\\Users\\Usuario\\Documents\\3ds Max 2025\\scripts\\TEKTON\\core\\tekton_core.ms"
```
(En casa reemplazar con C:\\Program Files\\Autodesk\\3ds Max 2025\\scripts\\TEKTON\\core\\tekton_core.ms)

## Pendiente
- FASE 5: Modeladores parametricos (generadores de muros, vigas, canos, etc.)
- FASE 6: Catalogos fabricantes argentinos
- Fix: tkn_createLevelPlane undefined al recargar Max en frio
- Fix: callback seleccion #TKN_UI_sel no siempre se registra al abrir UI
- Conectar filtro de nivel en tab COMPUTE al calculo real
- Probar e iterar tabs: LEVELS, CHECKER, COMPUTE, LOG, SETTINGS

## Proximo paso sugerido
Probar los 5 tabs nuevos e iterar bugs. Luego arrancar FASE 5 modeladores.

# TEKTON — Contexto de Proyecto

## Descripción
Sistema BIM para 3ds Max en MAXScript. Open source. i18n ES/EN.
Repo: github.com/pablochoa-cpu/TEKTON

## Protocolo TOKEN-SAVER
- Sin saludos ni introducciones
- Solo el bloque de código modificado, nunca el script completo
- Sin explicaciones salvo palabra clave "EXPLICAR"
- Solo mostrar línea/bloque cambiado con comentario -- CAMBIO ACA
- try/catch y print para debugging siempre
- Para UI solo eventos, no diseño visual completo

## Rutas
- Trabajo: C:\Users\Usuario\Documentos\3ds Max 2025\scripts\TEKTON\
- Casa: C:\Program Files\Autodesk\3ds Max 2025\scripts\TEKTON\
- Locales: subcarpeta locales\ dentro de cada ruta
- Rules.cfg: [escena]\TEKTON\config\
- Flujo: VS Code -> Commit/Push GitHub -> Copiar manual a carpeta Max
- Horario oficina: 9-18hs ARG

## Módulos completados
- tekton_core.ms    loader + struct global
- tkn_log.ms        log INFO/WARN/ERROR
- tkn_properties.ms read/write/validate propiedades BIM
- tkn_levels.ms     niveles + capas Max + planos referencia
- tkn_files.ms      CFG read/write + backup + callbacks
- tkn_project.ms    wizard + init + save/load proyecto
- tkn_queries.ms    filtros de escena + select viewport
- tkn_undo.ms       theHold wrapper
- tkn_colors.ms     colores por sistema + BIM mode toggle
- tkn_tag.ms        tagObject + untag + tagSelection
- tkn_extended.ms   propiedades tkn_x_
- tkn_geometry.ms   bbox + medidas + intersect
- tkn_locale.ms     i18n ES/EN desde .cfg
- tkn_checker.ms    clash detection HARD/SOFT + report + CSV

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

## Sistemas validos
foundations, concrete_structure, steel_structure, masonry, insulation,
flooring, plastering, cladding, roofing, openings, metalwork, plumbing,
drainage, electrical, gas, site_works, equipment, vegetation, generic

## Fases pendientes
- FASE 3: tkn_compute.ms   computos + exportacion CSV
- FASE 4: UI panel principal
- FASE 5: Modeladores parametricos
- FASE 6: Catalogos fabricantes argentinos

## Proximo paso
tkn_compute.ms — computos por sistema, area, volumen, longitud, exportacion CSV
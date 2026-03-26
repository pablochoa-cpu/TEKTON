-- =============================================================================
-- TEKTON Module: Geometry
-- File: tkn_geometry.ms
-- Depends on: tekton_core.ms, tkn_log.ms
-- Block: 11e
-- =============================================================================

-- -----------------------------------------------------------------------------
-- tkn_getWorldBBox
-- Returns the world-space bounding box of an object.
-- Result: #(min_point, max_point) as Point3 values.
-- -----------------------------------------------------------------------------

fn tkn_getWorldBBox obj = (

    if obj == undefined then (
        tkn_logError "getWorldBBox: invalid object."
        return undefined
    )

    local bbox = nodeGetBoundingBox obj (getNodeTM obj)
    return #(bbox[1], bbox[2])
)

-- -----------------------------------------------------------------------------
-- tkn_doBBoxesOverlap
-- Checks if two bounding boxes overlap in 3D space.
-- Fast pre-filter for collision detection.
-- Returns true if they overlap.
-- -----------------------------------------------------------------------------

fn tkn_doBBoxesOverlap bbox_a bbox_b = (

    local a_min = bbox_a[1]
    local a_max = bbox_a[2]
    local b_min = bbox_b[1]
    local b_max = bbox_b[2]

    if a_max.x < b_min.x then return false
    if b_max.x < a_min.x then return false
    if a_max.y < b_min.y then return false
    if b_max.y < a_min.y then return false
    if a_max.z < b_min.z then return false
    if b_max.z < a_min.z then return false

    return true
)

-- -----------------------------------------------------------------------------
-- tkn_getBBoxCenter
-- Returns the center point of a bounding box.
-- -----------------------------------------------------------------------------

fn tkn_getBBoxCenter bbox = (
    return ((bbox[1] + bbox[2]) / 2.0)
)

-- -----------------------------------------------------------------------------
-- tkn_getBBoxDimensions
-- Returns dimensions of a bounding box as #(x, y, z).
-- Values in meters.
-- -----------------------------------------------------------------------------

fn tkn_getBBoxDimensions bbox = (

    local dims = bbox[2] - bbox[1]
    return #(dims.x, dims.y, dims.z)
)

-- -----------------------------------------------------------------------------
-- tkn_getObjectVolume
-- Estimates object volume from bounding box.
-- Returns volume in cubic meters.
-- Note: approximate for non-box shapes.
-- -----------------------------------------------------------------------------

fn tkn_getObjectVolume obj = (

    if obj == undefined then return 0.0

    local bbox = tkn_getWorldBBox obj
    local dims = tkn_getBBoxDimensions bbox

    return (dims[1] * dims[2] * dims[3])
)

-- -----------------------------------------------------------------------------
-- tkn_getObjectLength
-- Returns the longest dimension of an object.
-- Used for beams, pipes, columns -- elements measured in ml.
-- Returns length in meters.
-- -----------------------------------------------------------------------------

fn tkn_getObjectLength obj = (

    if obj == undefined then return 0.0

    local bbox = tkn_getWorldBBox obj
    local dims = tkn_getBBoxDimensions bbox

    local max_dim = dims[1]
    if dims[2] > max_dim then max_dim = dims[2]
    if dims[3] > max_dim then max_dim = dims[3]

    return max_dim
)

-- -----------------------------------------------------------------------------
-- tkn_getObjectArea
-- Returns the largest face area of an object.
-- Used for walls, slabs, floors -- elements measured in m2.
-- Returns area in square meters.
-- -----------------------------------------------------------------------------

fn tkn_getObjectArea obj = (

    if obj == undefined then return 0.0

    local bbox = tkn_getWorldBBox obj
    local dims = tkn_getBBoxDimensions bbox

    local area_xy = dims[1] * dims[2]
    local area_xz = dims[1] * dims[3]
    local area_yz = dims[2] * dims[3]

    local max_area = area_xy
    if area_xz > max_area then max_area = area_xz
    if area_yz > max_area then max_area = area_yz

    return max_area
)

-- -----------------------------------------------------------------------------
-- tkn_getDistanceBetween
-- Returns the distance between the centers of two objects.
-- Used for soft collision detection.
-- Returns distance in meters.
-- -----------------------------------------------------------------------------

fn tkn_getDistanceBetween obj_a obj_b = (

    if obj_a == undefined or obj_b == undefined then return 0.0

    local center_a = tkn_getBBoxCenter (tkn_getWorldBBox obj_a)
    local center_b = tkn_getBBoxCenter (tkn_getWorldBBox obj_b)

    return (distance center_a center_b)
)

-- -----------------------------------------------------------------------------
-- tkn_doObjectsIntersect
-- Full intersection check.
-- Uses bbox pre-filter then Max native intersects function.
-- Returns true if objects physically intersect.
-- -----------------------------------------------------------------------------

fn tkn_doObjectsIntersect obj_a obj_b = (

    if obj_a == undefined or obj_b == undefined then return false

    local bbox_a = tkn_getWorldBBox obj_a
    local bbox_b = tkn_getWorldBBox obj_b

    -- Fast pre-check
    if not (tkn_doBBoxesOverlap bbox_a bbox_b) then (
        return false
    )

    -- Detailed check
    return (intersects obj_a obj_b)
)

-- -----------------------------------------------------------------------------
-- tkn_getObjectDimensions
-- Returns a formatted string with object dimensions.
-- Useful for the UI inspector and reports.
--
-- Example output: "L=4.50m W=0.20m H=0.40m"
-- -----------------------------------------------------------------------------

fn tkn_getObjectDimensions obj = (

    if obj == undefined then return ""

    local bbox = tkn_getWorldBBox obj
    local dims = tkn_getBBoxDimensions bbox

    -- Round to 2 decimals
    local x = (floor (dims[1] * 100 + 0.5)) / 100.0
    local y = (floor (dims[2] * 100 + 0.5)) / 100.0
    local z = (floor (dims[3] * 100 + 0.5)) / 100.0

    return ("L=" + x as string + "m W=" + y as string + "m H=" + z as string + "m")
)

-- =============================================================================

tkn_logInfo "Module loaded: tkn_geometry.ms"
"""
Constants - Global project constants and utility functions

Purpose:
    Provides resolution-independent grid system and coordinate conversions.
    This autoload ensures consistent spatial logic regardless of art style changes.

Architectural Pattern:
    - TILE_SIZE = 16 is the LOGICAL grid size, never changes
    - Visual tile size can be any resolution (16x16, 64x64, 128x128)
    - All gameplay logic uses TILE_SIZE for grid calculations
    - Sprites scale independently to match visual needs

Why This Matters:
    Separating logical grid from visual resolution allows art style changes
    (pixel art → high-res) without refactoring game logic.
    
    Example: Planting a crop at grid position (5, 10) works identically
    whether rendering 16x16 or 128x128 sprites.

Usage:
    # Convert world position to grid coordinates
    var grid_pos: Vector2i = Constants.world_to_grid(player.position)
    
    # Convert grid coordinates to world position (tile center)
    var world_pos: Vector2 = Constants.grid_to_world(Vector2i(5, 10))
    
    # Check if position is aligned to grid
    if Constants.is_grid_aligned(position):
        plant_crop()
        
Transfers to 3D:
    - 3D equivalent uses Vector3i and 3D grid coordinates
    - Same separation of logical grid vs visual mesh size
    - TileMap3D (GridMap) works identically to TileMap2D
"""

extends Node

# ============================================================================
# CORE CONSTANTS - DO NOT MODIFY AFTER PROJECT START
# ============================================================================

## Logical tile size for grid calculations
## This value NEVER changes, even when swapping art styles
## All gameplay logic (planting crops, collision, pathfinding) uses this
const TILE_SIZE: int = 16

## Visual scale factor for art
## Modify this when changing art style:
## - 1.0 = 16x16 pixel art (Sprout Lands)
## - 4.0 = 64x64 sprites
## - 8.0 = 128x128 high-res (Coral Island style)
const VISUAL_SCALE: float = 1.0

# ============================================================================
# COORDINATE CONVERSION FUNCTIONS
# ============================================================================

## Convert world position (pixels) to grid coordinates
## 
## World space: Position in pixels (e.g., player.position)
## Grid space: Discrete tile coordinates (e.g., Vector2i(5, 10))
## 
## Example:
##     world_pos = Vector2(80, 160)  # 80 pixels right, 160 pixels down
##     grid_pos = world_to_grid(world_pos)  # Returns Vector2i(5, 10)
##     
## Mathematical basis:
##     grid_x = floor(world_x / TILE_SIZE)
##     grid_y = floor(world_y / TILE_SIZE)
##     
## Returns:
##     Vector2i with integer grid coordinates
static func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		int(floor(world_pos.x / TILE_SIZE)),
		int(floor(world_pos.y / TILE_SIZE))
	)


## Convert grid coordinates to world position (center of tile)
## 
## Grid space: Discrete tile coordinates (e.g., Vector2i(5, 10))
## World space: Position in pixels at the CENTER of the tile
## 
## Why center? Most game logic (spawning, collision) expects centered positions.
## 
## Example:
##     grid_pos = Vector2i(5, 10)
##     world_pos = grid_to_world(grid_pos)  # Returns Vector2(88, 168)
##     # That's (5*16 + 8, 10*16 + 8) - center of 16x16 tile
##     
## Mathematical basis:
##     world_x = (grid_x * TILE_SIZE) + (TILE_SIZE / 2.0)
##     world_y = (grid_y * TILE_SIZE) + (TILE_SIZE / 2.0)
##     
## Returns:
##     Vector2 with floating point world coordinates (center of tile)
static func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		(grid_pos.x * TILE_SIZE) + (TILE_SIZE / 2.0),
		(grid_pos.y * TILE_SIZE) + (TILE_SIZE / 2.0)
	)


## Get the world-space rectangle (bounding box) for a tile
## 
## Returns the Rect2 defining the tile's position and size in world space.
## Useful for:
##     - Collision detection ("is this entity inside this tile?")
##     - Debug visualization (drawing tile boundaries)
##     - Area queries ("what tiles overlap this region?")
##     
## Example:
##     var tile_rect: Rect2 = Constants.get_tile_rect(Vector2i(5, 10))
##     # Returns Rect2(80, 160, 16, 16)
##     #          position: (80, 160)
##     #          size: (16, 16)
##     
##     if tile_rect.has_point(mouse_position):
##         print("Mouse is over tile (5, 10)")
##         
## Returns:
##     Rect2 with position (top-left corner) and size (TILE_SIZE x TILE_SIZE)
static func get_tile_rect(grid_pos: Vector2i) -> Rect2:
	return Rect2(
		grid_pos.x * TILE_SIZE,
		grid_pos.y * TILE_SIZE,
		TILE_SIZE,
		TILE_SIZE
	)


## Check if a world position is grid-aligned (centered on a tile)
## 
## Grid-aligned: Position is at the center of a tile (within tolerance)
## Tolerance: Small epsilon (0.1 pixels) allows for floating-point imprecision
## 
## Useful for:
##     - Movement systems ("stop when aligned to grid")
##     - Action validation ("can only plant when standing on tile center")
##     - Pathfinding endpoints ("snap to nearest grid position")
##     
## Example:
##     # Player moving towards Vector2(88, 168)
##     if Constants.is_grid_aligned(player.position):
##         player.velocity = Vector2.ZERO  # Stop moving
##         
## Returns:
##     true if position is within 0.1 pixels of a tile center
static func is_grid_aligned(world_pos: Vector2, tolerance: float = 0.1) -> bool:
	var grid_pos: Vector2i = world_to_grid(world_pos)
	var expected_center: Vector2 = grid_to_world(grid_pos)
	return world_pos.distance_to(expected_center) < tolerance


## Snap world position to nearest grid center
## 
## Takes any arbitrary world position and returns the center of the nearest tile.
## Useful for:
##     - Spawning entities ("place chest at nearest tile")
##     - Mouse cursor snapping ("place building at clicked tile")
##     - Movement correction ("after collision, snap to grid")
##     
## Example:
##     var mouse_world_pos: Vector2 = get_global_mouse_position()
##     var snap_pos: Vector2 = Constants.snap_to_grid(mouse_world_pos)
##     # Now snap_pos is guaranteed to be at a tile center
##     
## Returns:
##     Vector2 at the center of the nearest tile
static func snap_to_grid(world_pos: Vector2) -> Vector2:
	return grid_to_world(world_to_grid(world_pos))


# ============================================================================
# DEBUGGING UTILITIES
# ============================================================================

## Print grid information for a world position (debug helper)
## 
## Useful during development to understand coordinate conversions.
## Prints to console: grid coordinates, world center, and whether aligned.
## 
## Example:
##     Constants.debug_print_grid_info(player.position)
##     # Output:
##     # World Pos: (87.5, 168.2)
##     # Grid Pos: (5, 10)
##     # Grid Center: (88, 168)
##     # Aligned: false
static func debug_print_grid_info(world_pos: Vector2) -> void:
	var grid_pos: Vector2i = world_to_grid(world_pos)
	var grid_center: Vector2 = grid_to_world(grid_pos)
	var aligned: bool = is_grid_aligned(world_pos)
	
	print("=== Grid Debug Info ===")
	print("World Pos: ", world_pos)
	print("Grid Pos: ", grid_pos)
	print("Grid Center: ", grid_center)
	print("Aligned: ", aligned)
	print("=====================")

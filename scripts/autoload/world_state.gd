"""
WorldState - Central game state manager (data-driven architecture)

Purpose:
    Stores all persistent world state in data structures (not scene nodes).
    This enables:
    - Save/load system (serialize data to JSON)
    - Chunk loading (load/unload entities based on player position)
    - Time-delta catchup (entities update when re-entering area)
    - Scene-independent state (data persists across scene changes)

Architectural Pattern:
    - State stored in Dictionary/Array (NOT in scene nodes)
    - Data classes (CropData, NPCData) are pure data (no visuals)
    - Rendering layer is SEPARATE (reads from WorldState, creates sprites)
    - Updates happen in _process() (continuous time, not tick-based)

Why This Matters (Data vs Nodes):
    Traditional approach:
        for crop_node in get_tree().get_nodes_in_group("crops"):
            crop_node.grow(delta)
        Problem: Can't save/load easily, can't do chunk loading, state tied to scenes
        
    Data-driven approach:
        for crop_data in WorldState.crops.values():
            crop_data.grow(delta)
        Then renderer creates sprites from data
        Benefit: Can save crops as JSON, load/unload without scene changes
        
    Example: 100 crops planted. Player walks away (chunk unloads). Crops are
    still in WorldState.crops{} dictionary, still growing. Player returns
    (chunk reloads), renderer creates sprites for visible crops.

Current State (Session 1):
    - Minimal structure (placeholders for future data)
    - Ready for player reference
    - Will expand in Sessions 6-10 with crop/NPC systems
    
Future State (Session 10+):
    - crops: Dictionary[Vector2i, CropData] (planted crops by grid position)
    - npcs: Array[NPCData] (all NPCs with AI state)
    - objects: Dictionary[Vector2i, ObjectData] (chests, machines, etc.)
    - tilled_soil: Array[Vector2i] (which tiles are farmable)
    
Usage Pattern (Future):
    # Plant crop
    WorldState.add_crop(grid_pos, "wheat")
    
    # Get crop at position
    var crop: CropData = WorldState.get_crop(grid_pos)
    if crop and crop.is_harvestable():
        WorldState.remove_crop(grid_pos)
        
    # Update all entities (automatic in _process)
    # Renderer separately creates sprites from data
    
Transfers to 3D:
    - Identical pattern (data-driven design is dimension-agnostic)
    - 3D uses Vector3i instead of Vector2i for grid positions
    - Same separation of data layer and rendering layer
"""

extends Node

# ============================================================================
# PLAYER STATE
# ============================================================================

## Player's current grid position
## Updated by player script, read by systems that need player location
## Used for: Chunk loading, NPC interactions, UI updates
var player_grid_position: Vector2i = Vector2i(0, 0)

## Player's world position (pixel coordinates)
## Kept in sync with player node for systems that don't have direct reference
var player_world_position: Vector2 = Vector2.ZERO

# ============================================================================
# WORLD DATA (PLACEHOLDER - EXPAND IN FUTURE SESSIONS)
# ============================================================================

## Planted crops indexed by grid position
## Key: Vector2i (grid coordinates)
## Value: CropData (growth stage, watering, etc.)
## 
## Future structure (Session 6+):
##     crops[Vector2i(5, 10)] = CropData {
##         crop_type: "wheat",
##         growth_stage: 2.5,
##         is_watered: true,
##         planted_at: 86400.0  # 1 day into game
##     }
var crops: Dictionary = {}  # Vector2i → CropData (implemented later)

## NPCs with AI and schedules
## Array of NPCData containing position, schedule, state machine, dialogue
## 
## Future structure (Session 20+):
##     npcs = [
##         NPCData { name: "Farmer Joe", position: Vector2i(10, 15), ... },
##         NPCData { name: "Shopkeeper", position: Vector2i(30, 25), ... }
##     ]
var npcs: Array = []  # NPCData instances (implemented later)

## Placed objects (chests, machines, furniture)
## Key: Vector2i (grid coordinates)
## Value: ObjectData (type, contents, state)
## 
## Future structure (Session 12+):
##     objects[Vector2i(8, 12)] = ObjectData {
##         object_type: "chest",
##         inventory: [...items...],
##         is_open: false
##     }
var objects: Dictionary = {}  # Vector2i → ObjectData (implemented later)

## Tilled soil tiles (farmable ground)
## Simple array of grid positions that have been tilled
## Used to persist which tiles are farmable
## 
## Future structure (Session 7+):
##     tilled_soil = [Vector2i(5, 10), Vector2i(6, 10), Vector2i(5, 11)]
var tilled_soil: Array[Vector2i] = []

# ============================================================================
# WORLD UPDATES
# ============================================================================

## Update all world entities
## Called automatically each frame by Godot engine
## 
## Current: Does nothing (no entities yet)
## Future: Updates crops, NPCs, time-based events
## 
## Example future logic:
##     func _process(delta: float) -> void:
##         # Update crops (growth)
##         for crop in crops.values():
##             crop.grow(delta)
##             
##         # Update NPCs (AI, movement)
##         for npc in npcs:
##             npc.update_ai(delta)
##             
##         # Check time-based events (shop opening/closing, etc.)
##         check_time_events()
func _process(_delta: float) -> void:
	# Placeholder - will implement entity updates in future sessions
	pass


# ============================================================================
# PLAYER STATE UPDATES
# ============================================================================

## Update player position tracking
## Called by player script each frame
## 
## Parameters:
##     world_pos: Player's position in world space (pixels)
##     
## This allows systems without player reference to know player location
## Used for: Chunk loading, NPC aggro, interaction detection
func update_player_position(world_pos: Vector2) -> void:
	player_world_position = world_pos
	player_grid_position = Constants.world_to_grid(world_pos)


# ============================================================================
# PLACEHOLDER FUNCTIONS (IMPLEMENT IN FUTURE SESSIONS)
# ============================================================================

## Add a crop at grid position
## To be implemented in Session 6-7
func add_crop(grid_pos: Vector2i, crop_type: String) -> void:
	push_warning("WorldState.add_crop() not yet implemented - placeholder")
	# Future implementation:
	# var crop = CropData.new()
	# crop.crop_type = crop_type
	# crop.planted_at = GameTime.total_seconds
	# crops[grid_pos] = crop


## Remove crop at grid position (harvest)
## To be implemented in Session 6-7
func remove_crop(grid_pos: Vector2i) -> void:
	push_warning("WorldState.remove_crop() not yet implemented - placeholder")
	# Future implementation:
	# if grid_pos in crops:
	#     var crop = crops[grid_pos]
	#     crops.erase(grid_pos)
	#     return crop


## Get crop data at position (null if none)
## To be implemented in Session 6-7
func get_crop(grid_pos: Vector2i) -> Variant:
	# Future implementation:
	# return crops.get(grid_pos)
	return null


## Mark a tile as tilled (farmable)
## To be implemented in Session 7
func till_soil(grid_pos: Vector2i) -> void:
	push_warning("WorldState.till_soil() not yet implemented - placeholder")
	# Future implementation:
	# if grid_pos not in tilled_soil:
	#     tilled_soil.append(grid_pos)


## Check if a tile is tilled
## To be implemented in Session 7
func is_soil_tilled(grid_pos: Vector2i) -> bool:
	# Future implementation:
	# return grid_pos in tilled_soil
	return false


# ============================================================================
# DEBUG UTILITIES
# ============================================================================

## Print current world state (for debugging)
func debug_print_state() -> void:
	print("=== WorldState Debug ===")
	print("Player Grid Pos: ", player_grid_position)
	print("Player World Pos: ", player_world_position)
	print("Crops Count: ", crops.size())
	print("NPCs Count: ", npcs.size())
	print("Objects Count: ", objects.size())
	print("Tilled Soil Count: ", tilled_soil.size())
	print("=======================")

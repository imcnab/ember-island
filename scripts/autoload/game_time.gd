"""
GameTime - In-game time management system

Purpose:
    Manages game time separately from real-world time, enabling:
    - Time scaling (60 seconds real time = 1 day game time)
    - Save/load support (persist time state)
    - Time-delta catchup (crops grow while game is closed)
    - Exploits prevention (can't cheat by changing system clock)

Architectural Pattern:
    - Game time is ADDITIVE (continuously increments)
    - Stored as total_seconds (float) for precision
    - Independent of OS clock (uses delta time from _process())
    - Time scale adjustable (60x = 1 real second = 1 game minute)

Why This Matters:
    Farming games need crops to grow over time. Using OS clock would allow
    players to exploit (change system time, reload game). Using game time
    ensures deterministic, save-compatible progression.
    
    Example: Player plants wheat (takes 4 days). They play for 5 real minutes,
    then quit. On reload, we calculate: "4 days * time_scale = X real seconds
    have passed" and apply growth catch-up.

Typical Time Scales:
    - Real-time: time_scale = 1.0 (1 second real = 1 second game)
    - Stardew Valley: time_scale = 60.0 (1 second real = 1 minute game)
    - Faster: time_scale = 120.0 (1 second real = 2 minutes game)
    - Debug: time_scale = 1000.0 (fast-forward for testing)

Usage:
    # Get current game time
    var current_time: float = GameTime.total_seconds
    
    # Record event time (for later delta calculations)
    crop.planted_at = GameTime.total_seconds
    
    # Calculate elapsed time
    var elapsed: float = GameTime.total_seconds - crop.planted_at
    if elapsed >= 345600.0:  # 4 days in seconds (4 * 86400)
        crop.set_harvestable()
        
    # Change time speed (for debug or game events)
    GameTime.set_time_scale(120.0)  # 2x speed
    
Transfers to 3D:
    - Identical system (time management is dimension-agnostic)
    - Any game with persistent state needs this pattern
"""

extends Node

# ============================================================================
# TIME STATE
# ============================================================================

## Total elapsed game time in seconds
## This continuously increments and is the source of truth for all time calculations
## Persists across save/load
## Example: 345600.0 = 4 in-game days (4 * 24 * 60 * 60)
var total_seconds: float = 0.0

## Time scale multiplier (real seconds → game seconds)
## How fast game time passes relative to real time
## Default 60.0 = 1 real second = 1 game minute (Stardew-like pacing)
## Modify for gameplay feel or debug speed
var time_scale: float = 60.0

## Whether time is currently flowing
## Pause during menus, dialogues, or when player pauses
## Note: Does NOT affect physics (use get_tree().paused for that)
var is_paused: bool = false

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when time scale changes
## Listeners: UI elements showing time speed, debug overlays
signal time_scale_changed(new_scale: float)

## Emitted when time is paused/unpaused
## Listeners: UI pause indicators, game systems that need pause notification
signal time_paused(paused: bool)

# ============================================================================
# TIME PROGRESSION
# ============================================================================

## Update game time each frame
## Called automatically by Godot engine (autoload _process)
## 
## Delta time: Time since last frame (typically ~0.016s at 60 FPS)
## Game time increments by: delta * time_scale (when not paused)
## 
## Example:
##     delta = 0.016 (60 FPS)
##     time_scale = 60.0
##     increment = 0.016 * 60.0 = 0.96 game seconds per frame
##     At 60 FPS: 0.96 * 60 = 57.6 game seconds per real second ≈ 1 game minute
func _process(delta: float) -> void:
	if not is_paused:
		total_seconds += delta * time_scale


# ============================================================================
# TIME CONTROL
# ============================================================================

## Set time scale (how fast game time flows)
## 
## Parameters:
##     new_scale: Multiplier for time flow (1.0 = real-time, 60.0 = 1min/sec)
##     
## Constraints:
##     - Clamped to minimum 0.1 (prevent negative/zero time)
##     - Maximum not enforced (can go extremely fast for debug)
##     
## Example:
##     GameTime.set_time_scale(120.0)  # Double speed (2 game minutes per real second)
##     GameTime.set_time_scale(1.0)    # Real-time (for cutscenes)
func set_time_scale(new_scale: float) -> void:
	# Clamp to prevent invalid scales
	# Minimum 0.1 prevents division by zero in calculations
	# Maximum not set - allow arbitrarily fast time for debugging
	time_scale = max(0.1, new_scale)
	time_scale_changed.emit(time_scale)


## Pause/unpause game time
## 
## Parameters:
##     paused: true to pause, false to resume
##     
## Note: This only pauses GAME TIME, not physics
## For full pause (time + physics), use: get_tree().paused = true
## 
## Use cases:
##     - Pause during dialogue (time stops, player can't move)
##     - Pause during menus (time stops, world visible in background)
##     - Don't use for player death (might want time to continue)
##     
## Example:
##     # Show pause menu
##     GameTime.set_paused(true)
##     get_tree().paused = true  # Also pause physics
##     pause_menu.show()
func set_paused(paused: bool) -> void:
	is_paused = paused
	time_paused.emit(is_paused)


## Set total game time directly (used by save/load system)
## 
## Parameters:
##     seconds: New total game time
##     
## Warning: Only call from save system - don't use for gameplay logic
## Using this during gameplay will break time-delta calculations for crops/NPCs
## 
## Example (from SaveManager):
##     var save_data = load_save_file()
##     GameTime.set_total_seconds(save_data.game_time)
func set_total_seconds(seconds: float) -> void:
	total_seconds = max(0.0, seconds)  # Can't have negative time


# ============================================================================
# TIME FORMATTING & QUERIES
# ============================================================================

## Convert total seconds to in-game day number
## 
## Day 1 = seconds 0 to 86399
## Day 2 = seconds 86400 to 172799
## etc.
## 
## Returns:
##     Integer day number (1-indexed)
##     
## Example:
##     var day: int = GameTime.get_current_day()  # Returns 1, 2, 3...
##     ui_label.text = "Day %d" % day
func get_current_day() -> int:
	return int(floor(total_seconds / 86400.0)) + 1  # +1 for 1-indexed


## Convert total seconds to time of day
## 
## Returns:
##     Dictionary with keys: hour (0-23), minute (0-59), second (0-59)
##     
## Example:
##     var time_dict: Dictionary = GameTime.get_time_of_day()
##     var formatted: String = "%02d:%02d" % [time_dict.hour, time_dict.minute]
##     # formatted = "14:35" for 2:35 PM
func get_time_of_day() -> Dictionary:
	var day_seconds: float = fmod(total_seconds, 86400.0)  # Seconds within current day
	var hour: int = int(floor(day_seconds / 3600.0))  # 3600 seconds per hour
	var minute: int = int(floor((day_seconds - (hour * 3600.0)) / 60.0))
	var second: int = int(floor(day_seconds)) % 60
	
	return {
		"hour": hour,
		"minute": minute,
		"second": second
	}


## Format current time as human-readable string
## 
## Formats:
##     - "simple": "Day 3, 14:35"
##     - "full": "Day 3, 14:35:42"
##     - "day_only": "Day 3"
##     - "time_only": "14:35"
##     
## Returns:
##     String formatted time
##     
## Example:
##     ui_label.text = GameTime.format_time("simple")
##     # Output: "Day 3, 14:35"
func format_time(format_type: String = "simple") -> String:
	var day: int = get_current_day()
	var time: Dictionary = get_time_of_day()
	
	match format_type:
		"simple":
			return "Day %d, %02d:%02d" % [day, time.hour, time.minute]
		"full":
			return "Day %d, %02d:%02d:%02d" % [day, time.hour, time.minute, time.second]
		"day_only":
			return "Day %d" % day
		"time_only":
			return "%02d:%02d" % [time.hour, time.minute]
		_:
			push_warning("Unknown time format: %s" % format_type)
			return "Day %d, %02d:%02d" % [day, time.hour, time.minute]


# ============================================================================
# DEBUGGING
# ============================================================================

## Print current time state to console
## Useful for debugging time-related issues
func debug_print_time() -> void:
	print("=== GameTime Debug ===")
	print("Total Seconds: ", total_seconds)
	print("Current Day: ", get_current_day())
	print("Time of Day: ", get_time_of_day())
	print("Time Scale: ", time_scale)
	print("Is Paused: ", is_paused)
	print("Formatted: ", format_time("full"))
	print("=====================")

extends CharacterBody2D
## Player character with 8-directional movement.
##
## Handles keyboard/gamepad input and applies movement with collision detection.
## Movement is normalized for consistent speed in all directions.

## Movement speed in pixels per second
const SPEED: float = 100.0

## Handle player movement each physics frame.
func _physics_process(delta: float) -> void:
	
	# Get input direction from action mappings
	# Returns normalized Vector2 combining all 4 directional inputs
	var input_direction: Vector2 = Input.get_vector(
		"move_left",   # Negative X (A key or Left Arrow)
		"move_right",  # Positive X (D key or Right Arrow)
		"move_up",     # Negative Y (W key or Up Arrow)
		"move_down"    # Positive Y (S key or Down Arrow)
	)
	
	# Set velocity based on input direction and speed
	# velocity is inherited from CharacterBody2D
	velocity = input_direction * SPEED
	
	# Apply movement and handle collisions
	# Automatically slides along obstacles instead of stopping
	move_and_slide()

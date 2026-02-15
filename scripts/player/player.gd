extends CharacterBody2D
## Player character with 8-directional movement.
##
## Handles keyboard/gamepad input and applies movement with collision detection.
## Movement is normalized for consistent speed in all directions.

## Movement speed in pixels per second
const SPEED: float = 100.0

## Last movement direction (for idle animation facing)
## Stored as string: "down", "up", "left", "right"
var last_direction: String = "down"

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
	
	# Update animation based on movement direction
	update_animation(input_direction)
	
## Update character animation based on movement direction.
##
## Plays walk animations when moving, idle animations when stopped.
## Tracks last facing direction to maintain correct idle pose.
func update_animation(direction: Vector2) -> void:
	# Check if player is moving (direction vector has magnitude)
	if direction.length() > 0:
		# Player is moving - determine which direction
		# Prioritize horizontal movement for diagonals
		if abs(direction.y) > abs(direction.x):
			# Moving more vertically than horizontally
			if direction.y > 0:
				$AnimationPlayer.play("walk_down")
				last_direction = "down"
			else:
				$AnimationPlayer.play("walk_up")
				last_direction = "up"
		else:
			# Moving more horizontally than vertically
			if direction.x > 0:
				$AnimationPlayer.play("walk_right")
				last_direction = "right"
			else:
				$AnimationPlayer.play("walk_left")
				last_direction = "left"
	else:
		# Player is not moving - play idle animation facing last direction
		match last_direction:
			"down":
				$AnimationPlayer.play("idle_down")
			"up":
				$AnimationPlayer.play("idle_up")
			"right":
				$AnimationPlayer.play("idle_right")
			"left":
				$AnimationPlayer.play("idle_left")

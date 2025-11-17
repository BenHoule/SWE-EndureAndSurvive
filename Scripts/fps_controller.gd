extends CharacterBody3D
## First-Person Controller
## A production-ready FPS controller with WASD movement, jumping, crouching, sprinting, and mouselook
## Easy to modify - all parameters are exposed and clearly commented

# ============================================================================
# MOVEMENT PARAMETERS - Modify these to change movement feel
# ============================================================================

## Base walking speed (units per second)
@export var walk_speed: float = 5.0

## Sprinting speed multiplier (hold Shift to sprint)
@export var sprint_speed_multiplier: float = 1.5

## Crouching speed multiplier (slower when crouched)
@export var crouch_speed_multiplier: float = 0.5

## Jump velocity (higher = jump higher)
@export var jump_velocity: float = 4.5

## Movement acceleration (higher = faster speed changes)
@export var acceleration: float = 10.0

## Movement deceleration when no input (higher = faster stops)
@export var deceleration: float = 10.0

## Air control multiplier (how much control you have while airborne, 0-1)
@export var air_control: float = 0.3

# ============================================================================
# CROUCH PARAMETERS
# ============================================================================

## Standing height of the collision shape
@export var standing_height: float = 2.0

## Crouched height of the collision shape
@export var crouched_height: float = 1.0

## How fast the player transitions between standing and crouching
@export var crouch_transition_speed: float = 10.0

# ============================================================================
# CAMERA/MOUSE LOOK PARAMETERS
# ============================================================================

## Mouse sensitivity (higher = faster look)
@export var mouse_sensitivity: float = 0.003

## Minimum vertical look angle (in degrees, looking up)
@export var min_look_angle: float = -89.0

## Maximum vertical look angle (in degrees, looking down)
@export var max_look_angle: float = 89.0

## Enable/disable head bobbing effect
@export var enable_head_bob: bool = true

## Head bob frequency (how fast the bob cycles)
@export var head_bob_frequency: float = 2.0

## Head bob amplitude (how much the camera moves)
@export var head_bob_amplitude: float = 0.08

# ============================================================================
# REFERENCES - These are set automatically in _ready()
# ============================================================================

@onready var camera: Camera3D = $Head/Camera3D
@onready var head: Node3D = $Head
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var ray_cast: RayCast3D = $CrouchRayCast

# ============================================================================
# INTERNAL STATE - You generally won't need to modify these
# ============================================================================

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_crouching: bool = false
var head_bob_time: float = 0.0
var camera_origin_y: float = 0.0


# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	# Capture the mouse cursor
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Store the initial camera Y position for head bobbing
	camera_origin_y = camera.position.y
	
	# Set initial collision shape height
	if collision_shape and collision_shape.shape:
		collision_shape.shape.height = standing_height


# ============================================================================
# INPUT HANDLING
# ============================================================================

func _input(event: InputEvent) -> void:
	# Handle mouse look
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		handle_mouse_look(event)
	
	# Toggle mouse capture with ESC (useful for testing)
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# ============================================================================
# MOUSE LOOK
# ============================================================================

func handle_mouse_look(event: InputEventMouseMotion) -> void:
	# Rotate player body left/right
	rotate_y(-event.relative.x * mouse_sensitivity)
	
	# Rotate head/camera up/down
	head.rotate_x(-event.relative.y * mouse_sensitivity)
	
	# Clamp vertical rotation to prevent over-rotation
	head.rotation.x = clamp(
		head.rotation.x,
		deg_to_rad(min_look_angle),
		deg_to_rad(max_look_angle)
	)


# ============================================================================
# PHYSICS PROCESS - Called every physics frame
# ============================================================================

func _physics_process(delta: float) -> void:
	# Handle crouching
	handle_crouch(delta)
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		# Can't jump while crouching
		if not is_crouching:
			velocity.y = jump_velocity
	
	# Get input direction
	var input_dir := get_input_direction()
	
	# Calculate movement
	handle_movement(input_dir, delta)
	
	# Apply head bobbing
	if enable_head_bob:
		handle_head_bob(delta)
	
	# Move the character
	move_and_slide()


# ============================================================================
# MOVEMENT LOGIC
# ============================================================================

func get_input_direction() -> Vector2:
	"""Get the normalized input direction from WASD keys"""
	return Input.get_vector("move_left", "move_right", "move_forward", "move_backward")


func handle_movement(input_dir: Vector2, delta: float) -> void:
	"""Handle player movement with acceleration and different speeds"""
	
	# Calculate current speed based on state
	var current_speed := walk_speed
	
	if Input.is_action_pressed("sprint") and not is_crouching:
		current_speed *= sprint_speed_multiplier
	
	if is_crouching:
		current_speed *= crouch_speed_multiplier
	
	# Get movement direction relative to where player is looking
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Determine acceleration/deceleration rate
	var accel := acceleration
	if not is_on_floor():
		accel *= air_control
	
	# Apply acceleration or deceleration
	if direction:
		# Moving - accelerate toward target speed
		velocity.x = move_toward(velocity.x, direction.x * current_speed, accel * delta)
		velocity.z = move_toward(velocity.z, direction.z * current_speed, accel * delta)
	else:
		# Not moving - decelerate to stop
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		velocity.z = move_toward(velocity.z, 0, deceleration * delta)


# ============================================================================
# CROUCH LOGIC
# ============================================================================

func handle_crouch(delta: float) -> void:
	"""Handle crouching and standing up with smooth transitions"""
	
	# Toggle crouch state
	if Input.is_action_pressed("crouch"):
		is_crouching = true
	elif Input.is_action_just_released("crouch"):
		# Check if there's room to stand up
		if can_stand_up():
			is_crouching = false
	
	# Smoothly interpolate collision shape height
	var target_height: float = crouched_height if is_crouching else standing_height
	if collision_shape and collision_shape.shape:
		collision_shape.shape.height = lerp(
			collision_shape.shape.height,
			target_height,
			crouch_transition_speed * delta
		)
		
		# Adjust collision shape position (keeps feet on ground)
		var height_diff: float = standing_height - collision_shape.shape.height
		collision_shape.position.y = standing_height / 2.0 - height_diff / 2.0
	
	# Smoothly interpolate head position
	var target_head_y: float = standing_height - 0.3 if not is_crouching else crouched_height - 0.3
	head.position.y = lerp(head.position.y, target_head_y, crouch_transition_speed * delta)


func can_stand_up() -> bool:
	"""Check if there's enough space above the player to stand up"""
	if not ray_cast:
		return true
	
	# The raycast checks upward to see if anything is blocking
	return not ray_cast.is_colliding()


# ============================================================================
# HEAD BOB
# ============================================================================

func handle_head_bob(delta: float) -> void:
	"""Apply subtle head bobbing when moving"""
	
	# Only bob when moving on the ground
	if is_on_floor() and (abs(velocity.x) > 0.1 or abs(velocity.z) > 0.1):
		head_bob_time += delta * head_bob_frequency
		
		# Apply sinusoidal bob motion
		camera.position.y = camera_origin_y + sin(head_bob_time * 2.0) * head_bob_amplitude
	else:
		# Reset to origin when not moving
		head_bob_time = 0.0
		camera.position.y = lerp(camera.position.y, camera_origin_y, delta * 10.0)


# ============================================================================
# UTILITY FUNCTIONS (Optional - for extending functionality)
# ============================================================================

func get_current_speed() -> float:
	"""Returns the current horizontal speed of the player"""
	return Vector2(velocity.x, velocity.z).length()


func is_sprinting() -> bool:
	"""Returns true if the player is currently sprinting"""
	return Input.is_action_pressed("sprint") and not is_crouching and is_on_floor()


func get_look_direction() -> Vector3:
	"""Returns the forward direction the camera is looking"""
	return -camera.global_transform.basis.z

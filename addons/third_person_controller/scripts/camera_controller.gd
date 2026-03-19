extends Node3D

# Camera properties
@export var camera_distance: float = 4.0
@export var camera_height: float = 1.5
@export var camera_smoothness: float = 8.0
@export var look_sensitivity: float = 2.0

# Internal properties
var player: CharacterBody3D
var target_rotation_x: float = 0.0
var target_rotation_y: float = 0.0
var camera: Camera3D
var raycast: RayCast3D

func _ready() -> void:
	player = get_parent()
	camera = $Camera3D
	raycast = $Camera3D/RayCast3D
	
	# Set initial camera position
	update_camera_position()

func _physics_process(delta: float) -> void:
	# Get mouse input
	if Input.is_action_pressed("ui_right_click"):
		var mouse_motion = Input.get_last_mouse_velocity()
		target_rotation_y -= mouse_motion.x * look_sensitivity * 0.01
		target_rotation_x -= mouse_motion.y * look_sensitivity * 0.01
		target_rotation_x = clamp(target_rotation_x, -PI/2, PI/2)
		
	# Smooth camera rotation
	rotation.x = lerp(rotation.x, target_rotation_x, camera_smoothness * delta)
	rotation.y = lerp(rotation.y, target_rotation_y, camera_smoothness * delta)
	
	# Update camera position
	update_camera_position()
	
	# Make player face camera direction
	player.rotation.y = rotation.y

func update_camera_position() -> void:
	if not player:
		return
	 
	# Calculate desired camera position
	var desired_pos = player.global_position
	desired_pos += Vector3.UP * camera_height
	desired_pos -= global_transform.basis.z * camera_distance
	 
	# Check for collisions and adjust distance if needed
	if raycast and raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		var distance_to_collision = player.global_position.distance_to(collision_point)
		if distance_to_collision < camera_distance:
			desired_pos = player.global_position + Vector3.UP * camera_height
			desired_pos -= global_transform.basis.z * (distance_to_collision - 0.5)
	 
	# Smoothly move camera
	global_position = global_position.lerp(desired_pos, camera_smoothness * get_physics_process_delta_time())
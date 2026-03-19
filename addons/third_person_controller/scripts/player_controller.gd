extends CharacterBody3D

# Movement properties
@export var walk_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var acceleration: float = 15.0
@export var friction: float = 12.0
@export var jump_force: float = 6.0
@export var gravity: float = 9.8

# Animation properties
@export var animation_player: AnimationPlayer
@export var model: Node3D

var current_speed: float = 0.0
var is_sprinting: bool = false
var is_jumping: bool = false

func _physics_process(delta: float) -> void:
	# Handle input
	var input_vector = get_input_vector()
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		is_jumping = false
	
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force
		is_jumping = true
	
	# Handle sprint
	is_sprinting = Input.is_action_pressed("ui_shift")
	var target_speed = sprint_speed if is_sprinting else walk_speed
	
	# Calculate movement
	if input_vector != Vector2.ZERO:
		# Rotate model toward movement direction
		var direction = Vector3(input_vector.x, 0, input_vector.y).normalized()
		if direction != Vector3.ZERO:
			model.look_at(global_position + direction, Vector3.UP)
			
		# Accelerate
		current_speed = move_toward(current_speed, target_speed, acceleration * delta)
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		# Update animation
		update_animation(is_sprinting)
	else:
		# Decelerate
		current_speed = move_toward(current_speed, 0.0, friction * delta)
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		velocity.z = move_toward(velocity.z, 0.0, friction * delta)
		
		# Update animation
		update_animation(false)
	
	# Move the character
	move_and_slide()

func get_input_vector() -> Vector2:
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	return input.normalized()

func update_animation(is_running: bool) -> void:
	if not animation_player:
		return
	
	if is_jumping:
		animation_player.play("jump")
	elif current_speed > 0.1:
		if is_running:
			animation_player.play("run")
		else:
			animation_player.play("walk")
	else:
		animation_player.play("idle")
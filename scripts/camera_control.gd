extends Camera3D

@export var movement_speed : float = 50.0
@export var rotation_speed : float = 0.5
@export var mouse_sensitivity : float = 0.01

var current_rotation = Vector2.ZERO
var velocity = Vector3.ZERO

# The camera will only move when the right mouse button is held.

func _process(delta):
	var direction = Vector3.ZERO
	
	if Input.is_key_pressed(KEY_A):
		for car in Car.CARS:
			car.add_to_group("selected_car")

	if Input.is_key_pressed(KEY_Z):
		for car in get_tree().get_nodes_in_group("selected_car"):
			car.remove_from_group("selected_car")

	if Input.is_key_pressed(KEY_R):
		for car in get_tree().get_nodes_in_group("highlighted_car"):
			car.remove_from_group("highlighted_car")

	# Only move the camera if the right mouse button is pressed.
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		# Camera movement based on WASD keys.
		if Input.is_action_pressed("ui_up"):
			direction -= transform.basis.z
		if Input.is_action_pressed("ui_down"):
			direction += transform.basis.z
		if Input.is_action_pressed("ui_left"):
			direction -= transform.basis.x
		if Input.is_action_pressed("ui_right"):
			direction += transform.basis.x
		if Input.is_action_pressed("ui_backward"):
			direction -= transform.basis.y
		if Input.is_action_pressed("ui_forward"):
			direction += transform.basis.y
		
		if Input.is_key_pressed(KEY_SHIFT):
			direction = direction.normalized() * movement_speed * delta
		else:
			direction = direction.normalized() * movement_speed * delta * 2
		
		# Normalize and move the camera.
		velocity = direction
		global_transform.origin += velocity

		# Handle mouse movement for camera rotation.
		var mouse_delta = Input.get_last_mouse_velocity()
		current_rotation.x -= mouse_delta.x * mouse_sensitivity
		current_rotation.y -= mouse_delta.y * mouse_sensitivity
		current_rotation.y = clamp(current_rotation.y, -180, 180)  # Limit vertical rotation

		# Apply rotation to the camera.
		rotation_degrees.y = current_rotation.x * rotation_speed
		rotation_degrees.x = current_rotation.y * rotation_speed
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

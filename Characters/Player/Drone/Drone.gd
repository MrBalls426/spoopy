extends CharacterBody3D


@export_category("Drone Data")
@export var Drone_position: Vector3
@export var camera_speed := 5.0
@export var horizontalSensitivity : float = 0.002
@export var verticalSensitivity : float = 0.002
@export var fall_speed: float = 2.3
@export var free_cam_toggle: bool

var mouse_motion := Vector2.ZERO

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_category("Nodes")
@export var player_character: CharacterBody3D 
@export var camera: Node3D


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			mouse_motion = -event.relative * 0.001
			
	if event.is_action_pressed("FreeCam"):
		free_cam_toggle = !free_cam_toggle


func handle_camera_rotation() -> void:
	rotate_y(mouse_motion.x)
	camera.rotate_x(-mouse_motion.y)
	camera.rotation_degrees.x = clampf(camera.rotation_degrees.x, -90.0, 90.0)
	mouse_motion = Vector2.ZERO


func handle_free_cam() -> void:
	if free_cam_toggle == true:
		
		var drone_direction := Input.get_vector("fly_forward", "fly_back", "fly_left", "fly_right")
		var flight_path := (transform.basis * Vector3(-drone_direction.y, 0, -drone_direction.x)).normalized()
		
		if flight_path:
			velocity.x = flight_path.x * camera_speed
			velocity.z = flight_path.z * camera_speed
		else:
			velocity.x = move_toward(velocity.x, 0, camera_speed)
			velocity.z = move_toward(velocity.z, 0, camera_speed)
		move_and_slide()


func handle_camera_position(penis: float) -> void:
	#global_position = lerp(global_position, character_body_3d.global_position + (Drone_position).rotated(Vector3.UP, rotation.y), penis * camera_speed)
	var target = player_character.global_position + (Drone_position).rotated(Vector3.UP, rotation.y)
	var direction = global_position.direction_to(target)
	#using move_towards for slow acceleration
	velocity.x = lerp(velocity.x, direction.x * camera_speed, penis)
	velocity.z = lerp(velocity.z, direction.z * camera_speed, penis)
	velocity.y = lerp(velocity.y, direction.y * camera_speed / 2, penis)
	move_and_slide()
	## PHYSICSBODY3D AXIS LOCK LINEAR Y LATER

	
func _physics_process(delta: float) -> void:
	handle_camera_rotation()
	
	if Input.is_action_pressed("fly_up") and free_cam_toggle:
		velocity.y += gravity * delta * 2
		
	if Input.is_action_pressed("fly_down") and free_cam_toggle:
		velocity.y -= gravity * delta * 2
		
	if free_cam_toggle:
		handle_free_cam()
	else:
		handle_camera_position(delta)









		



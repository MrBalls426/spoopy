extends CharacterBody3D


@export_category("Drone Data")
@export var Drone_position: Vector3
@export var camera_speed := 5.0
@export var camera_sensitivity := 0.002
@export var fall_speed: float = 2.3
@export var free_cam_toggle: bool


var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@export_category("Nodes")
@export var player_character: CharacterBody3D 
@export var camera: Node3D
@export var drone_light: SpotLight3D
@onready var drone_camera: Camera3D = $DroneCamera

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			handle_camera_rotation(event.relative * camera_sensitivity)
			
	if event.is_action_pressed("FreeCam"):
		free_cam_toggle = !free_cam_toggle

	if event.is_action_pressed("Drone_light"):
		drone_light.visible = !drone_light.visible

func handle_camera_rotation(mouse_motion) -> void:
	#basis = basis.rotated(basis.y,-mouse_motion.x)
	camera.basis = camera.basis.rotated(basis.x,mouse_motion.y)
	camera.rotation_degrees.x = clampf(camera.rotation_degrees.x, -75.0, 75.0)
	mouse_motion = Vector2.ZERO

func handle_free_cam(delta: float) -> void:
	if free_cam_toggle == true:
		
		var drone_direction := Input.get_vector("fly_forward", "fly_back", "fly_left", "fly_right")
		var flight_path := (transform.basis * Vector3(-drone_direction.y, 0, -drone_direction.x)).normalized()
		
		if flight_path:
			velocity.x = lerp(velocity.x, flight_path.x * camera_speed, delta)
			velocity.z = lerp(velocity.z, flight_path.z * camera_speed, delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, delta)
			velocity.z = lerp(velocity.z, 0.0, delta)
		move_and_slide()

func handle_camera_position(delta: float) -> void:
	#global_position = lerp(global_position, character_body_3d.global_position + (Drone_position).rotated(Vector3.UP, rotation.y), penis * camera_speed)
	var target = player_character.global_position + (Drone_position).rotated(Vector3.UP, rotation.y)
	var direction = global_position.direction_to(target)
	#using move_towards for slow acceleration
	velocity.x = lerp(velocity.x, direction.x * camera_speed, delta)
	velocity.z = lerp(velocity.z, direction.z * camera_speed, delta)
	velocity.y = lerp(velocity.y, direction.y * camera_speed / 2, delta)
	move_and_slide()
	## PHYSICSBODY3D AXIS LOCK LINEAR Y LATER
	
func _physics_process(delta: float) -> void:
	if free_cam_toggle:
		velocity.y += Input.get_axis("fly_down", "fly_up") * camera_speed * delta

	if Input.is_action_just_pressed("toggle_perspective"):
		if drone_camera.is_current():
			drone_camera.clear_current(true)
		else:
			player_character.player_camera.clear_current()

	if Input.get_axis("fly_down", "fly_up") == 0:
		velocity.y = lerp(velocity.y, 0.0, delta)
	
	#if Input.is_action_pressed("fly_up") and free_cam_toggle:
		#velocity.y += gravity * delta * 2
		
	#if Input.is_action_pressed("fly_down") and free_cam_toggle:
		#velocity.y -= gravity * delta * 2
	
	if free_cam_toggle:
		handle_free_cam(delta)
	else:
		handle_camera_position(delta)










extends CharacterBody3D


@export_category("Drone Data")
@export var Drone_position: Vector3			## intended position of drone in third person camera
@export var auto_drone_postion_range := 1.0 ## range for drone to lerp to position instead of adjusting velocity
@export var max_drone_distance := 100		## max distance in meters that the drone will work with freecam
@export var camera_speed := 5.0				## camera move speed
@export var camera_sensitivity := 0.002		
@export var recon_toggle: bool			## toggles freecam behavior
@export var drone_return: bool

@export_category("Nodes")
@export var player_character: CharacterBody3D 
@export var camera: Node3D
@export var drone_light: SpotLight3D
@export var drone_camera: Camera3D



## USED FOR BUTTON PRESSING AND MOUSE CAMERA ROTATION
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_perspective"):
		drone_return = !drone_return
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			handle_drone_rotation(event.relative * camera_sensitivity)
			
	if event.is_action_pressed("FreeCam"):
		recon_toggle = !recon_toggle

	if event.is_action_pressed("Drone_light"):
		drone_light.visible = !drone_light.visible
		
	if event.is_action_pressed("toggle_perspective") and recon_toggle:
		!recon_toggle
		if drone_camera.is_current():
			drone_camera.clear_current(true)
		else:
			player_character.player_camera.clear_current()

## ROTATES CAMERA, ROTATION.x CLAMPED TO PREVENT CAMERA WRAPPING
func handle_drone_rotation(mouse_motion) -> void:
		if !Input.is_action_just_pressed("toggle_perspective"):
			rotate_object_local(basis.y,-mouse_motion.x)
			camera.rotate_object_local(camera.basis.x,mouse_motion.y)
			camera.rotation_degrees.x = clampf(camera.rotation_degrees.x, -60.0, 40.0)
	

## HANDLES MOVEMENT FOR FREECAM
func handle_free_cam(delta: float) -> void:
	if recon_toggle == true and not drone_return:
		var input_direction := Input.get_vector("fly_forward", "fly_back", "fly_left", "fly_right")
		var flight_path := (transform.basis * Vector3(-input_direction.y, 0, -input_direction.x)).normalized()
		
		if flight_path:
			velocity.x = lerp(velocity.x, flight_path.x * camera_speed, delta)
			velocity.z = lerp(velocity.z, flight_path.z * camera_speed, delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, delta)
			velocity.z = lerp(velocity.z, 0.0, delta)
		
		if Input.get_axis("fly_down", "fly_up"): # if pressing fly up or down
			velocity.y += Input.get_axis("fly_down", "fly_up") * camera_speed * delta
		else:	# if not pressing either fly up or down
			velocity.y = lerp(velocity.y, 0.0, delta)
	
		
		move_and_slide()


## HANDLES MOVEMENT FOR THIRD PERSON CAMERA
func handle_drone_position(delta: float) -> void:
	#global_position = lerp(global_position, character_body_3d.global_position + (Drone_position).rotated(Vector3.UP, rotation.y), penis * camera_speed)
	var target = player_character.global_position + (Drone_position).rotated(Vector3.UP, rotation.y)
	var direction = global_position.direction_to(target)
	var distance = global_position.distance_to(target)
	
	if distance >= auto_drone_postion_range:
		#using move_towards for slow acceleration
		velocity.x = lerp(velocity.x, direction.x * camera_speed, delta)
		velocity.z = lerp(velocity.z, direction.z * camera_speed, delta)
		velocity.y = lerp(velocity.y, direction.y * camera_speed / 2.0, delta)
	else:
		velocity.x = lerp(velocity.x, direction.x * 0.0, delta)
		velocity.z = lerp(velocity.z, direction.z * 0.0, delta)
		velocity.y = lerp(velocity.y, direction.y * 0.0, delta)
	move_and_slide()

	
	
func _physics_process(delta: float) -> void:
	# if in freecam  mode
	if recon_toggle:
		handle_free_cam(delta)
	else:
		handle_drone_position(delta)










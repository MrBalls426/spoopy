extends CharacterBody3D
const SPEED = 4.0
var mouse_motion := Vector2.ZERO

@export_category("PlayerCharacter Data")
@export var jump_height := 1.5
@export var fall_multiplier := 2.3
@export var FreeCamToggle := false
@export var sprint_speed := 2.0

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("FreeCam"):
		FreeCamToggle = !FreeCamToggle
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			mouse_motion = -event.relative * 0.001


func handle_camera_rotation() -> void:
	rotate_y(mouse_motion.x)
	mouse_motion = Vector2.ZERO


func _physics_process(delta: float) -> void:
	handle_camera_rotation()
	var input_dir : Vector2
	if !FreeCamToggle:
		input_dir = Input.get_vector("forward", "back", "left", "right")
	var direction := (transform.basis * Vector3(-input_dir.y, 0, -input_dir.x)).normalized()
		
	if not is_on_floor():
		if velocity.y >= 0:
			velocity.y -= gravity * delta
		else:
			velocity.y -= gravity * delta * fall_multiplier
	if !Input.is_action_pressed("sprint") or not is_on_floor():
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

	if Input.is_action_just_pressed("jump") and is_on_floor() and not FreeCamToggle:
		velocity.y = sqrt(jump_height * 2.0 * gravity)
		
	if Input.is_action_pressed("sprint") and is_on_floor() and not FreeCamToggle:
		velocity.x = direction.x * SPEED * sprint_speed
		velocity.z = direction.z * SPEED * sprint_speed

	print(true and false)
	move_and_slide()






extends Node3D

@export var camera: Node3D 
@export var Drone_position: Vector3
@export var camera_speed := 5.0
@export var horizontalSensitivity : float = 0.002
@export var verticalSensitivity : float = 0.002
@export var minPitchDeg : float = -45
@export var maxPitchDeg : float = 45

@onready var character_body_3d: CharacterBody3D = $"../CharacterBody3D"

var mouse_motion := Vector2.ZERO

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	handle_camera_rotation()
	handle_camera_position(delta)

func handle_camera_position(penis: float) -> void:
	global_position = lerp(global_position, character_body_3d.global_position + (Drone_position).rotated(Vector3.UP, rotation.y), penis * camera_speed)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			mouse_motion = -event.relative * 0.001
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func handle_camera_rotation() -> void:
	rotate_y(mouse_motion.x)
	camera.rotate_x(-mouse_motion.y)
	camera.rotation_degrees.x = clampf(camera.rotation_degrees.x, -90.0, 90.0)
	mouse_motion = Vector2.ZERO

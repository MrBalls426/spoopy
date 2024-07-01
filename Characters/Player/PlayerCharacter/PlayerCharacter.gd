extends CharacterBody3D
class_name Protag

const SPEED = 4.0
var mouse_motion := Vector2.ZERO

@export var Gadget: PackedScene

@export_category("PlayerCharacter Data")
@export var max_health := 100
@export var current_health = max_health
@export var jump_height := 1.5
@export var fall_multiplier := 2.3
#@export var ReconToggle := false
@export var sprint_speed := 2.0
@export var input_enabled := true 			## Input disabled when in third person, drone locked into current state
@export var sensitivity := 0.002
@export var crouch_height := 0.9
@export var height := 2.0
@export var camera_height: float 

@export_category("Nodes")
@export var player_camera: Camera3D
@export var mesh_instance: MeshInstance3D
@export var collision_shape: CollisionShape3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("FreeCam"):
		input_enabled = !input_enabled
	if event.is_action_pressed("toggle_perspective"):
		if event is InputEventMouseMotion:
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				mouse_motion = -event.relative * sensitivity
				
		if event.is_action_pressed("gadget"):
			var throwgadget = Gadget.instantiate()
			get_tree().get_first_node_in_group("gadget").add_child(throwgadget)
			throwgadget.apply_impulse(Vector3(0.0, 5.0, 3.2).rotated(Vector3.UP, rotation.y), Vector3.ZERO)
			throwgadget.global_position = global_position

func handle_camera_rotation() -> void:
	rotate_y(mouse_motion.x)
	mouse_motion = Vector2.ZERO


func _physics_process(delta: float) -> void:
	handle_camera_rotation()
	var input_dir : Vector2
	if input_enabled: 
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

	if Input.is_action_just_pressed("jump") and is_on_floor() and input_enabled:
		velocity.y = sqrt(jump_height * 2.0 * gravity)
		
	if !Input.is_action_pressed("crouch"):
		if Input.is_action_pressed("sprint") and is_on_floor() and input_enabled:
			velocity.x = direction.x * SPEED * sprint_speed
			velocity.z = direction.z * SPEED * sprint_speed
	
	if !Input.is_action_pressed("sprint"):
		if Input.is_action_pressed("crouch") and input_enabled:
			mesh_instance.mesh.height = lerp(mesh_instance.mesh.height, crouch_height, delta * 2.0)
			collision_shape.shape.height = lerp(collision_shape.shape.height, crouch_height, delta * 2.0)
		else:
			mesh_instance.mesh.height = lerp(mesh_instance.mesh.height, height, delta * 2.0)
			collision_shape.shape.height = lerp(collision_shape.shape.height, height, delta * 2.0)
		
			player_camera.position.y = lerp(player_camera.position.y, mesh_instance.mesh.height / 2.0 - camera_height, delta * 2.0)
	
	
	move_and_slide()





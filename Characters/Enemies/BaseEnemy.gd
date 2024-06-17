extends CharacterBody3D


## ENEMY BEHAVIOR IS AS FOLLOWS
# POSSIBLE TARGETS STORED IN TARGET LIST ARRAY
# ENEMY WILL SEARCH FOR TARGET WITHIN MAX TARGET LOCATION RANGE
# IF LINE OF SIGHT IS REQUIRED, WILL CHECK LINE OF SIGHT
# IF PLAYER FOUND, PLAYER WILL NOT BE LOST UNLESS OUT OF RANGE
# IF LINE OF SIGHT REQUIRED, AND IS LOST, PLAYER WILL BE LOST
# IF WANDERING IS ENABLED ENEMY WILL WANDER IF NOT TARGETTING PLAYER


@export_category("Behaviors")
@export var detection_enabled: = true 			## is enemy detection enabled 
@export var within_range_required := true		## Line of sight required to target player
@export var line_of_sight_required := true		## is line of sight required to target player
@export var wander_toggle := false				## Enemy will wander when not targetting player
@export var turn_and_face_toggle := true 		## Enemy facing movement direction
@export var movement_override := false			## stops normal movement behavior temporarily to allow for special behaviors

@export_category("Enemy Data")
@export var move_speed := 2.0	
@export var rotation_speed := 8.0				## speed of enemy rotation 
@export var target_list : Array					## list of targettable entities that will be detected 

@export_category("Detection")
@export var max_target_location_range := 50		## max distance target can be found
@export var max_target_distance := 200 			## max distance target can be followed after being found without being lost
@export var locate_player_check_interval := 1.0 ## time interval between raycasts to discover player
@export var lose_player_check_interval := 10.0	## time interval between raycasts to lose player if line of sight is lost
@export var check_targets := false				## check for new potential targets  
@export var checK_target_interval := 1.0		## interval for new target checks

@export_category("Wander")
@export var wander_strength: float				## distance enemy will try to wander
@export var wander_region_toggle: bool			## enemy will try to stay within radius of wander centerpoint
@export var wander_centerpoint : Node3D			## centerpoint of wander behavior
@export var wander_tendency_curve : Curve		## strength of wander tendency to move towards centerpoint
@export var max_wander_distance : float			## max intended radius of wander region
@export var wander_angle_toggle: bool 			## Enemy will try to wander forwards within given angle 
@export var wander_angle: float					## angle along y axis in both directions that can be targetted for wandering


@export_category("Enemy Nodes")
@export var nav_agent :NavigationAgent3D
@export var ray_cast : RayCast3D
@export var timer : Timer



#target stored globally to allow timer timeout function to have access to it

var target_found := false


func wander():
	pass


## checks if target is within range
func within_range(target_found, target_position:Vector3) -> bool:
	if target_found:
		if abs(abs(global_position) - abs(target_position)).length() <= max_target_distance:
				return true
	elif abs(abs(global_position) - abs(target_position)).length() <= max_target_location_range:
		return true
		
	# if no early return, return false
	return false
	
	
## checks if target is visible from raycast
func within_line_of_sight(target:Object) -> bool:
	ray_cast.target_position = target.global_position- ray_cast.global_position
	if ray_cast.is_colliding():
		if ray_cast.get_collider() in target_list:
			return true
	return false


## rotates enemy to face movement direction
func turn_amd_face(delta:float,next_pos:Vector3) -> void:
	var y_axis_rotation = transform.looking_at(Vector3(next_pos.x,global_position.y,next_pos.z))
	transform = transform.interpolate_with(y_axis_rotation,delta * rotation_speed)


func _ready() -> void:
	#timer.wait_time = locate_player_check_interval
	pass


func _physics_process(delta: float) -> void:
	var target : Node3D
	if target_list and check_targets:
		var potential_targets = get_tree().get_nodes_in_group("Targettable")
		var closest_target: Node3D
		for obj in potential_targets:
			if not closest_target:
				closest_target = obj
				continue
			if obj in target_list:
				if global_position.distance_to(closest_target.global_position) > global_position.distance_to(obj.global_position):
					closest_target = obj
		target = closest_target
				
	if target and detection_enabled: # if target is found and detection is enabled
		if line_of_sight_required and within_range_required:
			if within_range(target_found,target.global_position): # performs range check first because its cheaper than raycasts
				target_found = within_line_of_sight(target)
		elif line_of_sight_required:
			target_found = within_line_of_sight(target)
		elif within_range_required:
			target_found = within_range(target_found,target.global_position)

		# movement towards target
		if target_found and not movement_override: # if player within range and player spotted
			nav_agent.set_target_position(target.global_position) #player is targetted
			var next_pos = nav_agent.get_next_path_position()
			var direction = global_position.direction_to(next_pos)
			turn_amd_face(delta,next_pos)
			#using move_towards for slow acceleration
			
			velocity.x = move_toward(velocity.x, direction.x * move_speed, delta)
			velocity.z = move_toward(velocity.z, direction.z * move_speed, delta)
			
	elif not movement_override: #cant find player
		#using lerp for faster deceleration
		if wander_toggle:
			wander()
		else:
			velocity.x = lerp(velocity.x,0.0,delta)
			velocity.z = lerp(velocity.z,0.0,delta)
		
	
	
	# apply gravity
	velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
	# required to send velocity in this func for nav agent to handle properly
	nav_agent.set_velocity(velocity)
	move_and_slide()




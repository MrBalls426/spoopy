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
@export var lose_player_timer_duration := 6.0	## time interval between raycasts to lose player if line of sight is lost

@export_category("Wander")
@export var wander_strength: float				## distance enemy will try to wander
@export var wander_region_toggle: bool			## enemy will try to stay within radius of wander centerpoint
@export var wander_centerpoint : Node3D			## centerpoint of wander behavior
@export var wander_tendency_curve : Curve		## strength of wander tendency to move towards centerpoint
@export var max_wander_distance : float			## max intended radius of wander region
@export var wander_angle_toggle: bool 			## Enemy will try to wander forwards within given angle 
@export var wander_angle: float					## angle along y axis in both directions that can be targetted for wandering
@export var wander_interval : float 			## amount of time in seconds between wander attemtps
@export var wander_interval_randomization:float	## amount of randomization for time in seconds betweem wander attempts


@export_category("Enemy Nodes")
@export var nav_agent :NavigationAgent3D
@export var ray_cast : RayCast3D
@onready var mesh_instance_3d_2: MeshInstance3D = $MeshInstance3D2



#target stored globally to allow timer timeout function to have access to it



func wander():
	pass



## performs checks on line of sight, and range. handles various interactions between having them toggled on or off
func target_finder(potential_targets:Array) -> void:
	var target_found := false # determines if target has been found
	for check in potential_targets:
		if line_of_sight_required and within_range_required: # if range and line of sight required
			if within_range(check == target,check.global_position) and within_line_of_sight(check): 
				target = check
				target_found = true
				break
		elif line_of_sight_required:	# if only line of sight required
			if within_line_of_sight(check):
				target = check
				target_found = true
				break
		elif within_range_required:		# if only range required
			if within_range(check == target,check.global_position):
				target = check
				target_found = true
				break
		elif not line_of_sight_required and within_range_required and check:	# if neither range or line of sight required
			target = check	#
			target_found = true
		target_is_suitable = target_found # if not targets are found, current target will not change but it is unsuitable



## checks if target is within range
func within_range(target_already_found, target_position:Vector3) -> bool:
	if target_already_found: # if target_aleady_found, will use larger max_target_distance
		if abs(abs(global_position) - abs(target_position)).length() <= max_target_distance:
				return true
	elif abs(abs(global_position) - abs(target_position)).length() <= max_target_location_range:
		return true
		
	# if no early return, return false
	return false
	
	
## checks if target is visible from raycast
func within_line_of_sight(check:Object) -> bool:
	ray_cast.target_position = ray_cast.to_local(check.global_position)
	if ray_cast.is_colliding():
		if check_groups(ray_cast.get_collider()):
			return true
	return false


## rotates enemy to face movement direction
func turn_and_face(delta:float,next_pos:Vector3) -> void:
	var y_axis_rotation = transform.looking_at(Vector3(next_pos.x,global_position.y,next_pos.z))
	transform = transform.interpolate_with(y_axis_rotation,delta * rotation_speed)


func _physics_process(delta: float) -> void: 
	var potential_targets = get_targets() 	# Targettable entities within target list ordered by distance
	if potential_targets and detection_enabled: # if targets exist, and detection enabled
		target_finder(potential_targets)
		
	# movement towards target
	if nav_agent: # if nav agent exists movement code will execute
		if target and not movement_override: # if suitable target is found and movement is not overridden
			nav_agent.set_target_position(target.global_position) # target is targetted
			var next_pos = nav_agent.get_next_path_position()
			var direction = global_position.direction_to(next_pos)
			turn_and_face(delta,next_pos)

			#using move_towards for slow acceleration		
			velocity.x = move_toward(velocity.x, direction.x * move_speed, delta)
			velocity.z = move_toward(velocity.z, direction.z * move_speed, delta)
			
			
		elif not movement_override: # no suitable target found and movement is not overridden
			#using lerp for faster deceleration
			if wander_toggle:
				wander()
			else:
				velocity.x = lerp(velocity.x,0.0,delta)
				velocity.z = lerp(velocity.z,0.0,delta)		
		# required to send velocity in this func for nav agent to handle properly
		nav_agent.set_velocity(velocity)
		move_and_slide()
		
	elif turn_and_face_toggle and target: # if no nav agent, default to just doing turn and face behavior
		turn_and_face(delta,target.global_position)
		
	# apply gravity
	velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	



## after lose_player_timer_duration amount of time of the target being unsuitable, target will be lost
func _on_player_lose_timer_timeout() -> void:
	target = null # target is lost

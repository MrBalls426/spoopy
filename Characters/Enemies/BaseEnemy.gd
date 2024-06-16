extends CharacterBody3D


## ENEMY BEHAVIOR IS AS FOLLOWS
# ENEMY WILL SEARCH FOR PLAYER WITHIN MAX LOCATE DISTANCE
# IF LINE OF SIGHT IS REQUIRED, WILL CHECK LINE OF SIGHT
# IF PLAYER FOUND, PLAYER WILL NOT BE LOST UNLESS OUT OF RANGE
# IF LINE OF SIGHT REQUIRED, AND IS LOST, PLAYER WILL BE LOST




enum SearchBehavior {LOCATE,FOUND}
@export_category("Behaviors")
@export var line_of_sight_required := true		## is line of sight required to target player
@export var wander_toggle := false				## Enemy will wander when not targetting player
@export var turn_and_face_toggle := true 		## Enemy facing movement direction
@export var within_range_required := true		## Line of sight required to target player

@export_category("Enemy Data")
@export var speed := 2.0	
@export var rotation_speed := 8.0				## speed of enemy rotation 
@export var max_target_location_range := 50		## max distance target can be found
@export var max_target_distance := 200 			## max distance target can be followed after being found without being lost
@export var locate_player_check_interval := 1.0 ## time interval between raycasts to discover player
@export var lose_player_check_interval := 10.0	## time interval between raycasts to lose player if line of sight is lost


@export_category("Enemy Nodes")
@export var nav_agent :NavigationAgent3D
@export var ray_cast : RayCast3D
@export var timer : Timer


#target stored globally to allow timer timeout function to have access to it
var target # player 


var found_player := false:
	set(val):
		found_player = val


## checks if target is within locate or max distance
func within_range(search, target_position:Vector3) -> bool:
	match search: 
		SearchBehavior.LOCATE:
			if abs(abs(global_position) - abs(target_position)).length() <= max_target_location_range:
				return true
		SearchBehavior.FOUND:
			if abs(abs(global_position) - abs(target_position)).length() <= max_target_distance:
				return true
	# if no early return, return false
	return false
	
	
## checks if target is visible from raycast
func within_line_of_sight(target) :
	ray_cast.target_position = target.global_position- ray_cast.global_position
	if line_of_sight_required:
		if ray_cast.is_colliding():
			if ray_cast.get_collider().is_in_group("Player") and within_range(SearchBehavior.LOCATE,target.global_position) :
				found_player = true
				timer.wait_time = lose_player_check_interval
			else:
				if found_player:
					found_player = false
					timer.wait_time = locate_player_check_interval
	else: 
		if found_player:
			found_player = within_range(SearchBehavior.FOUND,target.global_position)
		else:
			found_player = within_range(SearchBehavior.LOCATE,target.global_position)


## rotates enemy to face movement direction
func turn_amd_face(delta:float,next_pos:Vector3) -> void:
	var y_axis_rotation = transform.looking_at(Vector3(next_pos.x,global_position.y,next_pos.z))
	transform = transform.interpolate_with(y_axis_rotation,delta * rotation_speed)

func _ready() -> void:
	timer.wait_time = locate_player_check_interval

func _physics_process(delta: float) -> void:
	target = get_tree().get_first_node_in_group("Player")
	if target: # if player exists
		if found_player: # if player within range and player spotted
				nav_agent.set_target_position(target.global_position) #player is targetted
				var next_pos = nav_agent.get_next_path_position()
				var direction = global_position.direction_to(next_pos)
				
				turn_amd_face(delta,next_pos)
				#using move_towards for slow acceleration
			
				velocity.x = move_toward(velocity.x, direction.x * speed, delta)
				velocity.z = move_toward(velocity.z, direction.z * speed, delta)
	else: #cant find player
		#using lerp for faster deceleration
		velocity.x = lerp(velocity.x,0.0,delta)
		velocity.z = lerp(velocity.z,0.0,delta)
		
		# player is lost if out of range
		if found_player:
			found_player = false
			timer.wait_time = locate_player_check_interval
	
	velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
	# required to send velocity in this func for nav agent to handle properly
	nav_agent.set_velocity(velocity)
	move_and_slide()


## checks every second if player is spotted. If player spotted, wait 10 secs before checking if line of sight is broken
func _on_player_detection_timer_timeout() -> void:
	within_line_of_sight(target)
	timer.start()

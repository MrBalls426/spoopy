extends CharacterBody3D


## ENEMY BEHAVIOR IS AS FOLLOWS
# ENEMY WILL SEARCH FOR PLAYER WITHIN MAX LOCATE DISTANCE
# IF LINE OF SIGHT IS REQUIRED, WILL CHECK LINE OF SIGHT
# IF PLAYER FOUND, PLAYER WILL NOT BE LOST UNLESS OUT OF RANGE
# IF LINE OF SIGHT REQUIRED, AND IS LOST, PLAYER WILL BE LOST




enum SearchBehavior {LOCATE,FOUND}

@export_category("Enemy Data")
@export var speed := 2.0
@export var max_target_locate_distance := 50 ## max distance target can be found
@export var max_target_distance := 200 ## max distance target can be followed
## seconds until raycast is performed to check if mosnter has line of sight of player
@export var locate_player_check_interval := 1.0
@export var lose_player_check_interval := 10.0
@export var line_of_sight_required := true
@export var max_rotation_speed_degrees := 30.0


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
			if abs(abs(global_position) - abs(target_position)).length() <= max_target_locate_distance:
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


func _ready() -> void:
	timer.wait_time = locate_player_check_interval


func _physics_process(delta: float) -> void:
	target = get_tree().get_first_node_in_group("Player")
	if target: # if player exists
		if found_player: # if player within range and player spotted
				nav_agent.set_target_position(target.global_position) #player is targetted
				var next_pos = nav_agent.get_next_path_position()
				var direction = global_position.direction_to(next_pos)
				var y_axis_rotation = transform.basis.looking_at(next_pos,Vector3.UP).get_euler().y
				print(transform.basis.looking_at(next_pos).get_euler())
				print(transform.basis.get_euler())
				#using move_towards for slow acceleration
				transform = transform.in
				
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

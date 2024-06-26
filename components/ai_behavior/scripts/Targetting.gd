extends Node


@export_category("Nodes")
@export var lose_timer:Timer

@onready var parent = get_parent()


var target:					# targetted object
	set(val):
		target = val
		if not target and target_is_suitable: # ensures target_is_suitable is false if target is null
			target_is_suitable = false


var target_is_suitable:		# target satisfies line of sight and/or distance requirements 
	set(val):
		target_is_suitable = val
		if not val and lose_timer.is_stopped(): # if target unsuitable start player lose timer
			lose_timer.start(parent.lose_player_timer_duration)
		if val and not lose_timer.is_stopped(): # if target is made suitable stop lose timer if it was running
			lose_timer.stop()


## checks if targets are within list of targetted groups
func check_groups(obj:Object) -> bool:
	for group in obj.get_groups():
		if group in parent.target_list:
			return true
	return false


## get targets in array ordered by distance to self
func get_targets() -> Array:
	var targettable = get_tree().get_nodes_in_group("Targettable")
	var targettable_in_list: Array = []
	if targettable.size() > 1: #only perform sorting if more than one targettable
		for tar in targettable:
			if check_groups(tar):
				targettable_in_list.push_front(tar) # adds each target to array of targets
		targettable_in_list.sort_custom(_sort_targets) # sorts list by distance
	return targettable_in_list

## custom sorter to order targettable nodes in get_targets()
func _sort_targets(target1,target2) -> bool:
	if parent.global_position.distance_to(target2.global_position) > parent.global_position.distance_to(target1.global_position):
		return true
	else:
		return false



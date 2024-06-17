@tool
extends RayCast3D

func check_groups(obj:Object) -> bool:
	for group in obj.get_groups():
		if group in ["Drone", "PlayerCharacter"]:
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
	if global_position.distance_to(target1.global_position) > global_position.distance_to(target2.global_position):
		return true
	else:
		return false
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var targets = get_targets()
	var target = targets[0]
	if target:
		#target_position = to_local(target.global_position)
		pass

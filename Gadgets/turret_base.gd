extends Node3D

@export var target_list : Array
@export var max_target_distance := 200
@export var max_target_location_range := 50
@export var line_of_sight_required := true
@export var within_range_required := true
@export var player: CharacterBody3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	look_at(player.global_position)

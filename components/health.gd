extends Node


@export var max_health: float
@export var current_health : float

@onready var parent := get_parent()
@onready var parent_colliders = parent.get_children()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

extends RayCast3D
var parent: Node3D
var health_component

@export_category("enemy data")
@export var enemy_damage := 25.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	parent = get_parent()
	health_component = parent.get_children()
	
	for item in health_component:
		if item.is_in_group("health_component"):
			health_component = item
			break
	
func _attack() -> void:
	parent.get_child_node("health")
	health_component.current_health -= enemy_damage
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_collider() is Protag:
		animation_player.play("Attack")

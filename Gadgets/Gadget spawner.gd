extends RigidBody3D

@export var Gadget: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node) -> void:
	var spawngadget = Gadget.instantiate()
	Gadget.global_position = global_position
	queue_free()

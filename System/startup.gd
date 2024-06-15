extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

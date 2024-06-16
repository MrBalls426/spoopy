extends Control


@onready var label: Label = $Panel/VBoxContainer/Label


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		visible = !visible

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible:
		label.text = "FPS: " + str(Engine.get_frames_per_second())

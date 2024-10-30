extends Node2D


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("_debug_reload"):
		get_tree().reload_current_scene()

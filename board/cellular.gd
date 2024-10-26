class_name Cellular extends Node2D

@export var cpos: Vector2i:
	set(value):
		cpos = value
		refresh()


var _board: Board2D


func refresh() -> void:
	if _board:
		global_transform = _board.global_transform.translated_local(_board.cell_centre(cpos))


func _enter_tree() -> void:
	_board = Board2D.find_parent_board(self)

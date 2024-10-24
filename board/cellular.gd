class_name Cellular extends Node2D


@export var cpos: Vector2i:
	set(value):
		cpos = value
		_dirty = true

var _board: Board2D
var _dirty: bool = true


func _enter_tree() -> void:
	_board = Board2D.find_parent_board(self)


func _process(_delta: float) -> void:
	if _dirty && _board:
		global_transform = _board.global_transform.translated_local(_board.cell_centre(cpos))
		_dirty = false

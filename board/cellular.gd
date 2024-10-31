class_name Cellular extends Node2D

@export var cpos: Vector3i:
	set(value):
		cpos = value
		refresh()
@export var ghost: bool = false

var _board: Board2D


func refresh() -> void:
	if _board:
		global_transform = _board.pose_global(cpos)


func _enter_tree() -> void:
	_board = Board2D.find_parent_board(self)
	if _board:
		_board.register(self)


func _exit_tree() -> void:
	if _board:
		_board.deregister(self)

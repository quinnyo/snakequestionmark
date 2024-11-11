class_name Cellular extends Node2D

@export var cpos: Vector3i:
	set(value):
		cpos = value
		refresh()
@export var cdir: Vector3i = Vector3i(1, 0, 0):
	set(value):
		cdir = value
		refresh()
@export var ghost: bool = false

@export var offset_position: Vector2:
	set(value):
		offset_position = value
		refresh()
@export var offset_rotation: float:
	set(value):
		offset_rotation = value
		refresh()

## Set true to enable board pose override.
## If enabled, the node's transform will not be modified, and [method _custom_pose_update] will be called.
@export var custom_pose_control: bool = false:
	set(value):
		custom_pose_control = value
		refresh()

var _board: Board2D


func refresh() -> void:
	if not _board:
		return
	var xf := _board.pose_global(cpos, cdir, offset_position, offset_rotation)
	if custom_pose_control:
		_custom_pose_update(xf)
	else:
		global_transform = xf


## Override this method to apply custom pose transform.
## This method is only called if [member custom_pose_control] is set to [code]true[/code].
## The default board pose is provided as [param xf].
func _custom_pose_update(xf: Transform2D) -> void:
	var _no_unuse := xf
	push_error("PURE VIRTUAL")


func _enter_tree() -> void:
	_board = Board2D.find_parent_board(self)
	if _board:
		_board.register(self)
		refresh()


func _exit_tree() -> void:
	if _board:
		_board.deregister(self)
		refresh()

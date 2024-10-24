class_name DebugCamera2D extends Camera2D

enum CloneMode {
	## Never clone the current camera.
	NEVER,
	## Clone the current camera on the first activation.
	ONCE,
	## Clone the current camera every activation.
	ALWAYS
}


@export var clone_current: CloneMode = CloneMode.ONCE
@export var temporary: bool = true
@export var id: String = ""


var _activation_count: int = 0
var _zoom_orig := Vector2.ONE
var _scroll_mod := false
var _scroll_start: Vector2
var _scroll_delta: Vector2


func _debug_cam_activate() -> void:
	if _activation_count == 0:
		position = get_viewport_rect().size / 2.0
	_activation_count += 1
	get_parent().move_child(self, 0)
	_scroll_mod = false
	if !has_node("overlay"):
		var overlay := ViewFrameOverlay.new()
		overlay.name = "overlay"
		add_child(overlay)
		overlay.transform = Transform2D.IDENTITY


func clone(cam: Camera2D) -> void:
	anchor_mode = cam.anchor_mode
	global_transform = cam.global_transform.translated(cam.offset)
	ignore_rotation = cam.ignore_rotation
	zoom = cam.zoom
	_zoom_orig = zoom


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("uix_zoom_in"):
		zoom *= 1.2
	elif event.is_action_pressed("uix_zoom_out"):
		zoom /= 1.2
	elif event.is_action_pressed("uix_zoom_reset"):
		zoom = _zoom_orig
	elif event.is_action("uix_scroll_modifier"):
		_scroll_mod = event.is_pressed()
		if _scroll_mod:
			_scroll_start = position
			_scroll_delta = Vector2.ZERO
	elif _scroll_mod && event is InputEventMouseMotion:
		_scroll_delta -= event.relative / zoom
		position = _scroll_start + _scroll_delta
	else:
		return
	get_viewport().set_input_as_handled()

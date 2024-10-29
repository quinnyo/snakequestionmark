extends Node

# TODO:
# [ ] actually clone existing camera properties and have that work
# [ ] disable existing active camera/s when activating debug cam
# [ ] restore overridden camera state when deactivating debug cam


var _instance: DebugCamera2D
var _inactive: Dictionary = {}


func toggle(id: String = "", parent: Node = null) -> void:
	if is_active() && _instance.id == id:
		deactivate()
	else:
		activate(id, parent)


func activate(id: String, parent: Node = null) -> void:
	deactivate()

	if not parent:
		parent = self

	if _inactive.has(id):
		_instance = _inactive[id]
		_inactive.erase(id)
	else:
		_instance = DebugCamera2D.new()
		_instance.id = id
	debug_cam_activate(_instance, parent)


func deactivate() -> void:
	if _instance:
		debug_cam_deactivate(_instance)
		_instance = null


func is_active() -> bool:
	return _instance && _instance.enabled


## is active instance the current viewport camera
func is_current() -> bool:
	return is_active() && _instance.get_viewport().get_camera_2d() == _instance


func get_active_instance() -> DebugCamera2D:
	return _instance


func debug_cam_activate(cam: DebugCamera2D, parent: Node) -> void:
	print("DebugCamera2D '%s': ACTIVE" % [ cam.id ])
	var current_cam := get_viewport().get_camera_2d()
	if current_cam:
		if cam.clone_current == DebugCamera2D.CloneMode.ALWAYS:
			cam.clone(current_cam)
		elif cam.clone_current == DebugCamera2D.CloneMode.ONCE && cam._activation_count == 0:
			cam.clone(current_cam)
	cam.enabled = true
	parent.add_child(cam)
	cam._debug_cam_activate()


func debug_cam_deactivate(cam: DebugCamera2D) -> void:
	print("DebugCamera2D '%s': DEACTIVATED" % [ cam.id ])
	cam.enabled = false
	if cam.temporary:
		cam.queue_free()
	else:
		cam.get_parent().remove_child(cam)
		_inactive[cam.id] = cam


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("_debug_view"):
		toggle("DEFAULT", self)
	if event.is_action("_debug_view"):
		get_viewport().set_input_as_handled()

@tool
class_name Board2D extends Node2D

## Board configuration changed
signal changed()

@export var phield: Phield:
	set(value):
		if phield && phield.changed.is_connected(_refresh):
			phield.changed.disconnect(_refresh)
		phield = value
		phield.changed.connect(_refresh)
		_refresh()
@export var layout: PhieldLayout:
	set(value):
		if layout && layout.changed.is_connected(_refresh):
			layout.changed.disconnect(_refresh)
		layout = value
		layout.changed.connect(_refresh)
		_refresh()

## Bounding region low bound in phield coordinates.
@export var origin: Vector2i = Vector2i.ZERO:
	set(value):
		origin = value
		_refresh()
## Bounding region size in phield coordinates.
@export var size: Vector2i = Vector2i(10, 10):
	set(value):
		size = value
		_refresh()


var _bounds: Rect2i
var _entities: Array[Cellular]
var _config_id: int


func _refresh() -> void:
	_bounds = Rect2i(origin, size)
	_config_id = randi()
	changed.emit()


func _assert_config() -> bool:
	if not phield:
		push_error("Board2D phield is null")
		return false
	if not layout:
		push_error("Board2D layout is null")
		return false
	return true


## Return value changes every time board configuration changes.
func get_config_id() -> int:
	return _config_id


func get_bounds() -> Rect2i:
	return _bounds


func is_out_of_bounds(c: Vector3i) -> bool:
	return !_bounds.has_point(Vector2i(c.x, c.y))


func pose_global(c: Vector3i, d: Vector3i = Vector3i(1, 0, 0), offset_position: Vector2 = Vector2.ZERO, offset_rotation: float = 0.0) -> Transform2D:
	if !_assert_config():
		return Transform2D()
	d = d if d.x != 0 || d.y != 0 else Vector3i(1, 0, 0)
	var p0 := phield.layout_centre(c, layout)
	var p1 := phield.layout_centre(c + d, layout)
	var angle := (p1 - p0).angle()
	return global_transform * Transform2D(angle + offset_rotation, p0 + offset_position)


func get_layout_bounds() -> Rect2:
	if !_assert_config():
		return Rect2()
	var c0 := Vector3i(origin.x, origin.y, 0) - Vector3i.ONE
	var c1 := c0 + Vector3i(size.x, size.y, 0) + Vector3i.ONE
	var p0 := phield.layout_centre(c0, layout)
	var p1 := phield.layout_centre(c1, layout)
	return Rect2(p0, p1 - p0)


func cell_centre(c: Vector3i) -> Vector2:
	if !_assert_config():
		return Vector2()
	return phield.layout_centre(c, layout)


func layout_fc(fc: Vector3) -> Vector2:
	if !_assert_config():
		return Vector2()
	return phield.layout_fc(fc, layout)


func pick_cell(p: Vector2) -> Vector3i:
	var fc := phield.unlayout(p, layout)
	return Vector3i(roundi(fc.x), roundi(fc.y), 0)


func is_open(c: Vector3i) -> bool:
	if is_out_of_bounds(c):
		return false
	return occupant(c) == null


## Returns the first occupant found at `c`
func occupant(c: Vector3i, include_ghost: bool = false) -> Cellular:
	for ent in _entities:
		if (include_ghost || !ent.ghost) && ent.cpos == c:
			return ent
	return null


func register(node: Cellular) -> void:
	if _entities.has(node):
		return
	_entities.append(node)


func deregister(node: Cellular) -> void:
	var idx := _entities.find(node)
	if idx != -1:
		_entities[idx] = _entities[-1]
		_entities.pop_back()


func get_neighbours(c: Vector3i) -> Array[Vector3i]:
	return phield.get_neighbours(c)


func get_entities(ghosts: bool, out_of_bounds: bool) -> Array[Cellular]:
	return _entities.filter(func(ent: Cellular): return (ghosts || !ent.ghost) && (out_of_bounds || !is_out_of_bounds(ent.cpos)))


static func detect_cellular_children(node: Node, recursive: bool = true) -> Array[Cellular]:
	var entities: Array[Cellular] = []
	for child in node.get_children():
		if child is Cellular:
			entities.push_back(child)
		if recursive:
			entities.append_array(Board2D.detect_cellular_children(child, recursive))
	return entities


static func find_parent_board(node: Node) -> Board2D:
	var parent := node.get_parent()
	while parent && parent is not Board2D:
		parent = parent.get_parent()
	return parent


func _init() -> void:
	process_priority = -1


func _ready() -> void:
	_refresh()


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		var detected_entities := Board2D.detect_cellular_children(self)
		for ent in detected_entities:
			var xf := pose_global(ent.cpos, ent.cdir, ent.offset_position, ent.offset_rotation)
			ent.global_transform = xf

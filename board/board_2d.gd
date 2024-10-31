@tool
class_name Board2D extends Node2D

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


func _refresh() -> void:
	_bounds = Rect2i(origin, size)
	queue_redraw()


func _assert_config() -> bool:
	if not phield:
		push_error("Board2D phield is null")
		return false
	if not layout:
		push_error("Board2D layout is null")
		return false
	return true


func is_out_of_bounds(c: Vector3i) -> bool:
	return !_bounds.has_point(Vector2i(c.x, c.y))


func pose_global(c: Vector3i) -> Transform2D:
	if !_assert_config():
		return Transform2D()
	return global_transform.translated_local(phield.layout_centre(c, layout))


func cell_centre(c: Vector3i) -> Vector2:
	if !_assert_config():
		return Vector2()
	return phield.layout_centre(c, layout)


func is_open(c: Vector3i) -> bool:
	if is_out_of_bounds(c):
		return false
	return true


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


static func find_parent_board(node: Node) -> Board2D:
	var parent := node.get_parent()
	while parent && parent is not Board2D:
		parent = parent.get_parent()
	return parent


func _ready() -> void:
	_refresh()


func _draw() -> void:
	if not phield or not layout:
		return

	var cmin := _bounds.position
	var cmax := _bounds.end
	for y in range(cmin.y, cmax.y):
		for x in range(cmin.x, cmax.x):
			var c := Vector3i(x, y, 0)
			var color := Color.AQUA
			if phield.is_face(c):
				color = Color.STEEL_BLUE
			else:
				print("not face: %s" % [ c ])
			var points := phield.layout_vertices(c, layout)
			if points.size() < 3:
				continue
			draw_colored_polygon(points, color)

	_debug_draw()


func _debug_draw() -> void:
	var cmin := _bounds.position
	var cmax := _bounds.end
	for y in range(cmin.y, cmax.y):
		for x in range(cmin.x, cmax.x):
			var c := Vector3i(x, y, 0)
			_debug_draw_element(c)


func _debug_draw_element(c: Vector3i) -> void:
	var p := phield.layout_centre(c, layout)

	var points := phield.layout_vertices(c, layout)
	if points.size() >= 3:
		points.append(points[0])
		draw_polyline(points, Color(0.85, 0.95, 0.75, 0.5))
	else:
		draw_line(p, p + Vector2(10, 0), Color.RED)
		draw_line(p, p + Vector2(0, 10), Color.RED)

	var color := Color.RED
	var radius := 2.0
	var fill := false
	var width := 1.0
	if phield.is_face(c):
		color = Color.CORNSILK
		radius = 8.0
	elif phield.is_border(c):
		color = Color.CORAL
		radius = 4.0
	elif phield.is_corner(c):
		color = Color.AQUA
		radius = 3.0
	else:
		color = Color.MAGENTA

	draw_circle(p, radius + 0.5, Color.BLACK, false, width + 2.5, true)
	draw_circle(p, radius, color, fill, width, true)

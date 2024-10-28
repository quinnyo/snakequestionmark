class_name Board2D extends Node2D

@export var phield: PhieldSquare
@export var layout: PhieldLayout

## Bounding size in _cells_ (columns, rows).
@export var size: Vector2i = Vector2i(10, 10):
	set(value):
		size = value
		_refresh_bounds()
## If true, the border coordinates along the boundary will be considered in-bounds.
@export var boundary_includes_borders: bool = false:
	set(value):
		boundary_includes_borders = value
		_refresh_bounds()


var _bounds: Rect2i


func _refresh_bounds() -> void:
	var r := Rect2i(Vector2i.ONE, Vector2i(size * 2 - Vector2i.ONE))
	_bounds = r.grow(1) if boundary_includes_borders else r
	queue_redraw()


func is_out_of_bounds(c: Vector2i) -> bool:
	return !_bounds.has_point(c)


func cell_position(c: Vector2i) -> Vector2:
	return phield.origin(c, layout)


func cell_centre(c: Vector2i) -> Vector2:
	return phield.centre(c, layout)


func is_open(c: Vector2i) -> bool:
	if is_out_of_bounds(c):
		return false
	return true


static func find_parent_board(node: Node) -> Board2D:
	var parent := node.get_parent()
	while parent && parent is not Board2D:
		parent = parent.get_parent()
	return parent


func _ready() -> void:
	_refresh_bounds()


func _draw() -> void:
	if !phield:
		return

	var cmin := _bounds.position
	var cmax := _bounds.end
	for y in range(cmin.y, cmax.y):
		for x in range(cmin.x, cmax.x):
			var c := Vector2i(x, y)
			var color := Color.STEEL_BLUE
			if phield.c_is_border(c):
				color = Color.POWDER_BLUE
			elif phield.c_is_corner(c):
				color = Color.CADET_BLUE
			var points := phield.vertices(c, layout)
			draw_colored_polygon(points, color)

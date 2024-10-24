class_name PhieldSquare extends Phield
## A square grid with first-class borders and corners.

enum SquareBorder { E, S, W, N }
enum SquareCorner { SE, SW, NW, NE }

const ADJACENT := [Vector2i(2, 0), Vector2i(0, 2), Vector2i(-2, 0), Vector2i(0, -2)]
const DIAGONAL := [Vector2i(2, 2), Vector2i(-2, 2), Vector2i(-2, -2), Vector2i(2, -2)]

const BORDER := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]
const CORNER := [Vector2i(1, 1), Vector2i(-1, 1), Vector2i(-1, -1), Vector2i(1, -1)]


## enable coordinate bounds
@export var bounds_enabled: bool = false
## Bounding size in _cells_ (columns, rows).
@export var size: Vector2i = Vector2i(0, 0):
	set(value):
		size = value
		_refresh_bounds()
## If true, the border coordinates along the boundary will be considered in-bounds.
@export var boundary_includes_borders: bool = false:
	set(value):
		boundary_includes_borders = value
		_refresh_bounds()

var bounds_min: Vector2i:
	set(value):
		push_error("nah")
	get:
		return _bounds_min
var bounds_max: Vector2i:
	set(value):
		push_error("nah")
	get:
		return _bounds_max


var _bounds_min: Vector2i = Vector2i.MIN
var _bounds_max: Vector2i = Vector2i.MAX


func _refresh_bounds() -> void:
	_bounds_min = Vector2i(0, 0) if boundary_includes_borders else Vector2i(1, 1)
	_bounds_max = Vector2i(size * 2 + Vector2i.ONE) if boundary_includes_borders else Vector2i(size * 2)


func is_out_of_bounds(c: Vector2i) -> bool:
	if !bounds_enabled:
		return false
	elif c.x < _bounds_min.x || c.y < _bounds_min.y:
		return true
	elif c.x >= _bounds_max.x || c.y >= _bounds_max.y:
		return true
	return false


func c_is_face(c: Vector2i) -> bool:
	return c.x & 1 && c.y & 1


func c_is_border(c: Vector2i) -> bool:
	return c.x & 1 != c.y & 1


func c_is_corner(c: Vector2i) -> bool:
	return !(c.x & 1 || c.y & 1)


## Normalise c to face coordinate.
func c_face(c: Vector2i) -> Vector2i:
	return Vector2i(c.x | 1, c.y | 1)


func c_rface(c: Vector2i) -> Vector2i:
	return Vector2i(c.x - 1 | 1, c.y - 1 | 1)


#func c_border(c: Vector2i, dir: int) -> Vector2i:
	#return c + BORDER[dir % BORDER.size()]
#
#
#func c_corner(c: Vector2i, dir: int) -> Vector2i:
	#return c + CORNER[dir % CORNER.size()]
#
#
#func c_adjacent(c: Vector2i) -> Array[Vector2i]:
	#return [c + ADJACENT[0], c + ADJACENT[1], c + ADJACENT[2], c + ADJACENT[3]]
#
#
#func c_diagonal(c: Vector2i) -> Array[Vector2i]:
	#return [c + DIAGONAL[0], c + DIAGONAL[1], c + DIAGONAL[2], c + DIAGONAL[3]]


func origin(c: Vector2i, layout: LayoutSquare) -> Vector2:
	# as corner position initially
	var pos := Vector2(c / 2) * layout.unit
	# add border/margin if c is face coord
	if c.x & 1:
		pos.x += layout.border_width.x
	if c.y & 1:
		pos.y += layout.border_width.y
	return pos


func centre(c: Vector2i, layout: LayoutSquare) -> Vector2:
	var w := layout.unit.x - layout.border_width.x if c.x & 1 == 1 else layout.border_width.x
	var h := layout.unit.y - layout.border_width.y if c.y & 1 == 1 else layout.border_width.y
	var p := origin(c, layout)
	return p + Vector2(w, h) / 2.0


func vertices(c: Vector2i, layout: LayoutSquare) -> PackedVector2Array:
	var w := layout.unit.x - layout.border_width.x if c.x & 1 == 1 else layout.border_width.x
	var h := layout.unit.y - layout.border_width.y if c.y & 1 == 1 else layout.border_width.y
	var p := origin(c, layout)
	return PackedVector2Array([p + Vector2(w, h), p + Vector2(0, h), p, p + Vector2(w, 0)])

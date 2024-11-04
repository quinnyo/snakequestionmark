@tool
class_name PhieldSquare extends Phield


const DIRECTIONS: Array[Vector3i] = [
	Vector3i(1, 0, 0), Vector3i(0, 1, 0), Vector3i(-1, 0, 0), Vector3i(0, -1, 0)
]
const CORNERS: Array[Vector2] = [
	Vector2(+0.5, +0.5),
	Vector2(-0.5, +0.5),
	Vector2(-0.5, -0.5),
	Vector2(+0.5, -0.5)
]


@export var double_coords: bool = false:
	set(value):
		double_coords = value
		emit_changed()


func is_face(c: Vector3i) -> bool:
	if double_coords:
		return c.x & 1 && c.y & 1
	return true


func is_border(c: Vector3i) -> bool:
	if double_coords:
		return c.x & 1 != c.y & 1
	return false


func is_corner(c: Vector3i) -> bool:
	if double_coords:
		return !(c.x & 1 || c.y & 1)
	return false


func direction(dir: int) -> Vector3i:
	return DIRECTIONS[dir % DIRECTIONS.size()]


func get_neighbours(c: Vector3i) -> Array[Vector3i]:
	var neighbours: Array[Vector3i] = DIRECTIONS.duplicate()
	for i in range(neighbours.size()):
		neighbours[i] += c
	return neighbours


func layout_vertices(c: Vector3i, layout: PhieldLayout) -> PackedVector2Array:
	var vertices := PackedVector2Array()
	vertices.resize(4)
	var centre := layout_centre(c, layout)
	for i in range(4):
		var offset := corner_offset(i, layout)
		vertices[i] = centre + offset
	return vertices


func layout_centre(c: Vector3i, layout: PhieldLayout) -> Vector2:
	return layout.xform(Vector2(c.x, c.y))


func corner_offset(corner: int, layout: PhieldLayout) -> Vector2:
	return (layout.size - layout.border_width) * CORNERS[corner % CORNERS.size()]

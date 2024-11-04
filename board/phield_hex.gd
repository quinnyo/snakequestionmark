@tool
class_name PhieldHex extends Phield


func direction(dir: int) -> Vector3i:
	return Hex.DIRECTIONS[dir % Hex.DIRECTIONS.size()]


func get_neighbours(c: Vector3i) -> Array[Vector3i]:
	var neighbours: Array[Vector3i] = Hex.DIRECTIONS.duplicate()
	for i in range(neighbours.size()):
		var d := neighbours[i]
		neighbours[i] = Vector3i(c.x + d.x, c.y + d.y, 0)
	return neighbours


func layout_vertices(c: Vector3i, layout: PhieldLayout) -> PackedVector2Array:
	if !is_face(c):
		return PackedVector2Array()
	var vertices := PackedVector2Array()
	vertices.resize(6)
	var centre := layout_centre(c, layout)
	for i in range(6):
		var offset := Hex.corner_offset(i, layout)
		vertices[i] = centre + offset
	return vertices


func layout_centre(c: Vector3i, layout: PhieldLayout) -> Vector2:
	return layout.xform(Vector2(c.x, c.y))


func unlayout(p: Vector2, layout: PhieldLayout) -> Vector2:
	return layout.xform_inv(p)


func is_face(_c: Vector3i) -> bool:
	return true


func is_border(_c: Vector3i) -> bool:
	return false


func is_corner(_c: Vector3i) -> bool:
	return false


class Hex:
	const DIRECTIONS: Array[Vector3i] = [
		Vector3i(1, 0, -1), Vector3i(1, -1, 0), Vector3i(0, -1, 1),
		Vector3i(-1, 0, 1), Vector3i(-1, 1, 0), Vector3i(0, 1, -1)
	]

	static func axial_to_cube(c: Vector2i) -> Vector3i:
		return Vector3i(c.x, c.y, - c.x - c.y)


	static func corner_offset(corner: int, layout: PhieldLayout) -> Vector2:
		var angle := TAU * (layout.start_angle + float(corner)) / 6.0
		return (layout.size - layout.border_width) * Vector2.from_angle(angle)

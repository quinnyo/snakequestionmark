@tool
class_name Phield extends Resource


func direction(dir: int) -> Vector3i:
	push_error("not implemented", dir)
	return Vector3i.ZERO


func neighbour(c: Vector3i, dir: int) -> Vector3i:
	return c + direction(dir)


func layout_vertices(c: Vector3i, layout: PhieldLayout) -> PackedVector2Array:
	push_error("not implemented", c, layout)
	return PackedVector2Array()


func layout_centre(c: Vector3i, layout: PhieldLayout) -> Vector2:
	return layout.xform(Vector2(c.x, c.y))


func layout_fc(fc: Vector3, layout: PhieldLayout) -> Vector2:
	return layout.xform(Vector2(fc.x, fc.y))


func unlayout(p: Vector2, layout: PhieldLayout) -> Vector2:
	return layout.xform_inv(p)


func is_face(c: Vector3i) -> bool:
	push_error("not implemented", c)
	return false


func is_border(c: Vector3i) -> bool:
	push_error("not implemented", c)
	return false


func is_corner(c: Vector3i) -> bool:
	push_error("not implemented", c)
	return false

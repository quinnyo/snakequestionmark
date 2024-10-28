class_name PhieldSquare extends Phield
## A square grid with first-class borders and corners.


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


func origin(c: Vector2i, layout: PhieldLayout) -> Vector2:
	# as corner position initially
	var pos := Vector2(c / 2) * layout.size
	# add border/margin if c is face coord
	if c.x & 1:
		pos.x += layout.border_width.x
	if c.y & 1:
		pos.y += layout.border_width.y
	return pos


func centre(c: Vector2i, layout: PhieldLayout) -> Vector2:
	var w := layout.size.x - layout.border_width.x if c.x & 1 == 1 else layout.border_width.x
	var h := layout.size.y - layout.border_width.y if c.y & 1 == 1 else layout.border_width.y
	var p := origin(c, layout)
	return p + Vector2(w, h) / 2.0


func vertices(c: Vector2i, layout: PhieldLayout) -> PackedVector2Array:
	var w := layout.size.x - layout.border_width.x if c.x & 1 == 1 else layout.border_width.x
	var h := layout.size.y - layout.border_width.y if c.y & 1 == 1 else layout.border_width.y
	var p := origin(c, layout)
	return PackedVector2Array([p + Vector2(w, h), p + Vector2(0, h), p, p + Vector2(w, 0)])

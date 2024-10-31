class_name SnakeSegment extends Cellular


enum SegmentType { FACE, HEAD, BODY, TAIL }


@export var type: SegmentType = SegmentType.TAIL:
	set(value):
		type = value
		ghost = type == SegmentType.FACE
		queue_redraw()

var stone: bool = false:
	set(value):
		stone = value
		modulate = Color(0.4, 0.3, 0.5) if stone else Color.WHITE

var ahead: SnakeSegment:
	get:
		if not ahead:
			ahead = _find_ahead()
		return ahead
var atail: SnakeSegment:
	get:
		if not atail:
			atail = _find_atail()
		return atail


func heading() -> Vector3i:
	if ahead:
		return ahead.cpos - cpos
	elif atail:
		return cpos - atail.cpos
	else:
		return Vector3i.ZERO


func is_face() -> bool:
	return not ahead


func is_head() -> bool:
	return ahead && ahead.is_face()


func is_body() -> bool:
	return ahead && atail && !ahead.is_face()


func is_tail() -> bool:
	return not atail


func _find_ahead() -> SnakeSegment:
	var index := get_index() - 1
	while index >= 0:
		var sibling := get_parent().get_child(index)
		if sibling is SnakeSegment:
			return sibling
		index -= 1
	return null


func _find_atail() -> SnakeSegment:
	var index := get_index() + 1
	while index < get_parent().get_child_count():
		var sibling := get_parent().get_child(index)
		if sibling is SnakeSegment:
			return sibling
		index += 1
	return null


func _draw() -> void:
	if atail && type != SegmentType.FACE:
		draw_line(Vector2.ZERO, atail.position - position, Color.DARK_OLIVE_GREEN, 3.0, true)
		draw_line(Vector2.ZERO, atail.position - position, Color.YELLOW_GREEN, 2.0, true)

	match type:
		SegmentType.FACE:
			var ok := _board.is_open(cpos)
			var rect := Rect2(Vector2(-8,-8), Vector2(16, 16))
			draw_rect(rect, Color.BLACK, false, 2.0)
			draw_rect(rect.grow(-1), Color.WHITE if ok else Color.RED, false, 1.0)
		SegmentType.HEAD:
			var radius := 9.0
			var eye_radius := 5.0
			draw_circle(Vector2.ZERO, radius + 1, Color.DARK_OLIVE_GREEN, true, -1.0, true)
			draw_circle(Vector2.ZERO, radius - 1, Color.OLIVE, true, -1.0, true)

			# TODO: transform 'heading' via phield/layout
			var cdir := heading()
			var udir := Vector2(cdir.x, cdir.y).normalized()
			var angle := Vector2.DOWN.angle_to(udir)
			var d := udir * radius * 0.8
			var xf := Transform2D(angle, d).scaled_local(Vector2(0.8, 1.0))
			var right := Vector2(radius * 0.8, 0.0)
			var left := Vector2(-radius * 0.8, 0.0)
			draw_set_transform_matrix(xf)
			draw_circle(right, eye_radius + 0.5, Color.BLACK)
			draw_circle(left, eye_radius + 0.5, Color.BLACK)
			draw_set_transform_matrix(xf.translated(Vector2(-0.2, -0.5) * eye_radius).scaled_local(Vector2(1.0, 0.9)))
			draw_circle(right, eye_radius / 2.0, Color.WHITE, true, -1.0, true)
			draw_circle(left, eye_radius / 2.0, Color.WHITE, true, -1.0, true)
			draw_set_transform_matrix(xf.scaled_local(Vector2(1.0, 0.9)))
			draw_circle(right, eye_radius, Color.BLACK, false, 1.0, true)
			draw_circle(left, eye_radius, Color.BLACK, false, 1.0, true)
			draw_set_transform_matrix(Transform2D(angle, d * 0.1).scaled_local(Vector2(1.1, 1.0)))
			draw_circle(Vector2.ZERO, radius - eye_radius / 2.0, Color.OLIVE, true, -1.0, true)
		SegmentType.BODY:
			var radius := 7.0
			draw_circle(Vector2.ZERO, radius + 1, Color.OLIVE_DRAB, true, -1.0, true)
			draw_circle(Vector2.ZERO, radius - 1, Color.OLIVE, true, -1.0, true)
		SegmentType.TAIL:
			var radius := 4.0
			draw_circle(Vector2.ZERO, radius + 1, Color.OLIVE, true, -1.0, true)
			draw_circle(Vector2.ZERO, radius - 1, Color.DARK_OLIVE_GREEN, true, -1.0, true)

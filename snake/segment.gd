class_name SnakeSegment extends Cellular


enum SegmentType { HEAD, BODY, TAIL }


@export var type: SegmentType = SegmentType.TAIL:
	set(value):
		type = value
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
	else:
		return cdir


func _find_ahead() -> SnakeSegment:
	if type == SegmentType.HEAD:
		return null
	var index := get_index() - 1
	while index >= 0:
		var sibling := get_parent().get_child(index)
		if sibling is SnakeSegment:
			return sibling
		index -= 1
	return null


func _find_atail() -> SnakeSegment:
	if type == SegmentType.TAIL:
		return null
	var index := get_index() + 1
	while index < get_parent().get_child_count():
		var sibling := get_parent().get_child(index)
		if sibling is SnakeSegment:
			return sibling
		index += 1
	return null


func _draw_eye(offset: Vector2, eye_radius: float, base_colour: Color = Color.BLACK, line_width: float = 1.0, line_colour: Color = Color(0.2, 0.0, 0.0)) -> void:
	var xf := Transform2D(-signf(offset.y) * PI * 0.12, Vector2(offset.x, 0.0)).scaled_local(Vector2(1.0, 0.6))
	draw_set_transform_matrix(xf)
	draw_circle(Vector2(0.0, offset.y), eye_radius + 0.5, base_colour, true, -1.0, true)
	draw_circle(Vector2(0.0, offset.y), eye_radius * 0.75, line_colour, false, line_width, true)
	draw_set_transform(Vector2.ZERO)


func _draw() -> void:
	# links
	if ahead:
		var from := Vector2.ZERO
		var to := 0.75 * to_local(ahead.global_position)
		draw_line(from, to, Color.DARK_OLIVE_GREEN, 3.0, true)
		draw_line(from, to, Color.OLIVE, 2.0, true)
		draw_circle(to, 2.0, Color.OLIVE, true, -1.0, true)
	# segments
	match type:
		SegmentType.HEAD:
			var radius := 9.0
			var eye_radius := 5.0
			draw_circle(Vector2.ZERO, radius + 1, Color.DARK_OLIVE_GREEN, true, -1.0, true)
			draw_circle(Vector2.ZERO, radius - 1, Color.OLIVE, true, -1.0, true)
			# eyes
			var eye_right := Vector2(radius * 0.4, radius * 1.50)
			_draw_eye(eye_right, eye_radius, Color.BLACK)
			_draw_eye(eye_right * Vector2(1.0, -1.0), eye_radius, Color.BLACK)
			# hat
			draw_set_transform_matrix(Transform2D(0.0, Vector2(1.0, 1.3), 0.0, Vector2(-eye_radius * 0.1, 0.0)))
			draw_circle(Vector2.ZERO, radius - eye_radius / 2.0, Color.OLIVE, true, -1.0, true)
		SegmentType.BODY:
			var radius := 7.0
			draw_circle(Vector2.ZERO, radius + 1, Color.OLIVE_DRAB, true, -1.0, true)
			draw_circle(Vector2.ZERO, radius - 1, Color.OLIVE, true, -1.0, true)
		SegmentType.TAIL:
			var radius := 4.0
			draw_circle(Vector2.ZERO, radius + 1, Color.OLIVE, true, -1.0, true)
			draw_circle(Vector2.ZERO, radius - 1, Color.DARK_OLIVE_GREEN, true, -1.0, true)

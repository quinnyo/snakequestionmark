class_name SnakeSegment extends Cellular

#enum SegmentType { FACE, HEAD, BODY, TAIL }
#@export var type: SegmentType = SegmentType.BODY

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


func heading() -> Vector2i:
	if ahead:
		return ahead.cpos - cpos
	elif atail:
		return cpos - atail.cpos
	else:
		return Vector2i.ZERO


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
	if is_face():
		var ok := _board.is_open(cpos)
		var rect := Rect2(Vector2(-8,-8), Vector2(16, 16))
		draw_rect(rect, Color.BLACK, false, 2.0)
		draw_rect(rect.grow(-1), Color.WHITE if ok else Color.RED, false, 1.0)
	elif is_head():
		var radius := 8
		draw_circle(Vector2.ZERO, radius + 1, Color.BLACK)
		draw_circle(Vector2.ZERO, radius - 1, Color.ORANGE_RED)
	pass

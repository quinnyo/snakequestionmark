class_name ViewFrameOverlay extends Node2D


func draw_frame_rect(rect: Rect2, color: Color, width: float = -1.0) -> void:
	draw_rect(rect, color, false, width)
	var p := rect.position
	var sz := rect.size
	var corners := PackedVector2Array([p, p + Vector2(sz.x, 0.0), p + sz, p + Vector2(0.0, sz.y)])
	var corners_dir := PackedVector2Array([Vector2(-1,-1), Vector2(1,-1), Vector2(1,1), Vector2(-1,1)])
	for i in range(corners.size()):
		var c := corners[i]
		var dir := corners_dir[i]
		draw_line(c, c + dir * 40.0, color, width)


func _init() -> void:
	z_index = 128


func _draw() -> void:
	var vprect := get_viewport_rect()
	var rect := Rect2(vprect.position - vprect.size / 2.0, vprect.size).grow(-40.0)
	draw_frame_rect(rect, Color.DARK_SLATE_BLUE)
	draw_frame_rect(rect.grow(-1.0), Color.LAVENDER)
	pass

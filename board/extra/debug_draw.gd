@tool
class_name BoardDebugDraw2D extends Node2D


var board: Board2D
var _last_config_id: int


func _process(_delta: float) -> void:
	if not board or !board.is_ancestor_of(self):
		board = Board2D.find_parent_board(self)
		queue_redraw()
	elif board.get_config_id() != _last_config_id:
		queue_redraw()


func _draw() -> void:
	if not board or not board.phield or not board.layout:
		_last_config_id = 0
		return
	_last_config_id = board.get_config_id()

	var cbounds := board.get_bounds()
	var cmin := cbounds.position
	var cmax := cbounds.end
	for y in range(cmin.y, cmax.y):
		for x in range(cmin.x, cmax.x):
			var c := Vector3i(x, y, 0)
			var color := Color.AQUA
			if board.phield.is_face(c):
				color = Color.STEEL_BLUE
			else:
				print("not face: %s" % [ c ])
			var points := board.phield.layout_vertices(c, board.layout)
			if points.size() < 3:
				continue
			draw_colored_polygon(points, color)

	#_debug_draw(cbounds)


func _debug_draw(cbounds: Rect2i) -> void:
	var cmin := cbounds.position
	var cmax := cbounds.end
	for y in range(cmin.y, cmax.y):
		for x in range(cmin.x, cmax.x):
			var c := Vector3i(x, y, 0)
			_debug_draw_element(c)


func _debug_draw_element(c: Vector3i) -> void:
	var p := board.phield.layout_centre(c, board.layout)
	var points := board.phield.layout_vertices(c, board.layout)
	if points.size() >= 3:
		points.append(points[0])
		draw_polyline(points, Color(0.85, 0.95, 0.75, 0.5))
	else:
		draw_line(p, p + Vector2(10, 0), Color.RED)
		draw_line(p, p + Vector2(0, 10), Color.RED)

	var color := Color.RED
	var radius := 2.0
	var fill := false
	var width := 1.0
	if board.phield.is_face(c):
		color = Color.CORNSILK
		radius = 8.0
	elif board.phield.is_border(c):
		color = Color.CORAL
		radius = 4.0
	elif board.phield.is_corner(c):
		color = Color.AQUA
		radius = 3.0
	else:
		color = Color.MAGENTA
	draw_circle(p, radius + 0.5, Color.BLACK, false, width + 2.5, true)
	draw_circle(p, radius, color, fill, width, true)

@tool
class_name Agrid2D extends Node2D
## Displays a grid


@export var grid: Agrid:
	set(value):
		if grid && grid.changed.is_connected(_on_grid_changed):
			grid.changed.disconnect(_on_grid_changed)
		grid = value
		grid.changed.connect(_on_grid_changed)
		queue_redraw()
@export var clip_region: Rect2 = Rect2(Vector2.ZERO, Vector2.ONE * 2048.0):
	set(value):
		clip_region = value
		queue_redraw()


var _alpha := Vector2i.ZERO


func get_alpha() -> Vector2:
	return get_viewport_transform().get_scale().abs() - Vector2.ONE * 0.5


func get_alphaf() -> float:
	var a := get_alpha()
	return maxf(a.x, a.y)


func _process(_delta: float) -> void:
	if not grid:
		return

	var spalpha := get_alpha() * Vector2(grid.spacing_x, grid.spacing_y)
	var axy := Vector2i(1, 1)
	if spalpha.x > 1.0:
		axy.x = 2
	elif spalpha.x < 0.1:
		axy.x = 0
	if spalpha.y > 1.0:
		axy.y = 2
	elif spalpha.y < 0.1:
		axy.y = 0

	if _alpha != axy:
		queue_redraw()
		_alpha = axy

	self_modulate.a = get_alphaf()


func _draw() -> void:
	if not grid:
		return
	var line_colour := PackedColorArray([
		Color(0.2, 0.8, 0.4, 0.2),
		Color(0.9, 0.2, 0.4, 0.2),
		Color(0.05, 0.95, 0.15),
		Color(0.95, 0.1, 0.05),
	])
	var line_width := PackedFloat64Array([])
	var skip := 0
	if _alpha.x == 0 && _alpha.y == 0:
		return
	elif _alpha.x == 1 && _alpha.y == 1:
		skip = 2

	var gridlines := grid.get_lines(clip_region)
	for i in range(skip, gridlines.size()):
		var col := line_colour[i] if i < line_colour.size() else Color.WHITE
		var width := line_width[i] if i < line_width.size() else -1.0
		draw_multiline(gridlines[i], col, width)


func _on_grid_changed() -> void:
	queue_redraw()

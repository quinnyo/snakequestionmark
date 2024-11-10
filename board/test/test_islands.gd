extends Node2D

var shift := preload("res://board/extra/cell_shift.gd").new()
@onready var board: Board2D = $".." as Board2D

var tokens := {}
var mouse_cell: Vector3i:
	set(value):
		if mouse_cell != value:
			mouse_cell = value
			queue_redraw()


var islands2: Array[Island] = []


func unrectify(cr: Rect2i) -> PackedVector2Array:
	var a := Vector3(cr.position.x, cr.position.y, 0) - Vector3(0.45, 0.45, 0.0)
	var b := Vector3(cr.end.x, cr.end.y, 0) - Vector3(0.55, 0.55, 0.0)
	return PackedVector2Array([
		board.layout_fc(Vector3(b.x, b.y, 0)),
		board.layout_fc(Vector3(a.x, b.y, 0)),
		board.layout_fc(Vector3(a.x, a.y, 0)),
		board.layout_fc(Vector3(b.x, a.y, 0)),
	])


func toggle_cell(c: Vector3i) -> void:
	if tokens.has(c):
		var token := tokens[c] as Cellular
		token.ghost = !token.ghost
		token.queue_redraw()
	else:
		var token := Cellular.new()
		token.draw.connect(func():
			token.draw_circle(Vector2.ZERO, 10.0, Color.ORANGE_RED if not token.ghost else Color.GRAY)
		)
		token.cpos = c
		tokens[c] = token
		board.add_child(token)


func refresh() -> void:
	if !shift.has_work():
		var new_tokens := {}
		for token in tokens.values():
			new_tokens[token.cpos] = token
		tokens = new_tokens

		islands2 = Island.extract_islands(board)

	queue_redraw()


func start_shift(dir: Vector3i) -> void:
	if !shift.has_work():
		shift.board = board
		shift.shift_direction = dir
		shift.prepare()
	shift.perform()
	refresh()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		refresh()
	elif event.is_action_pressed("ui_right"):
		start_shift(Vector3i(1, 0, 0))
	elif event.is_action_pressed("ui_left"):
		start_shift(Vector3i(-1, 0, 0))
	elif event.is_action_pressed("ui_down"):
		start_shift(Vector3i(0, 1, 0))
	elif event.is_action_pressed("ui_up"):
		start_shift(Vector3i(0, -1, 0))
	elif event is InputEventMouseMotion:
		mouse_cell = board.pick_cell(board.get_local_mouse_position())
	elif event is InputEventMouseButton:
		mouse_cell = board.pick_cell(board.get_local_mouse_position())
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if !shift.has_work():
				toggle_cell(mouse_cell)
				refresh()
		elif event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			if !shift.has_work():
				shift.board = board
				shift.prepare()
			shift.perform()
			refresh()


func _draw() -> void:
	var hue := 0.1
	for island in islands2:
		var points := PackedVector2Array()
		for ent in island.get_entities():
			var p := board.cell_centre(ent.cpos)
			points.push_back(p)
			draw_circle(p, 12.0, Color.from_ok_hsl(hue, 0.9, 0.7, 0.5))
			draw_circle(p, 12.0, Color.from_ok_hsl(hue, 0.9, 0.7), false, 1.0)
		hue += 0.15

	var cursor_colour := Color.GREEN if board.is_open(mouse_cell) else Color.KHAKI
	if shift.has_work():
		cursor_colour = Color.RED
	var cursor_pos := board.cell_centre(mouse_cell)
	draw_circle(cursor_pos, 5.0, cursor_colour, false, 1.0)
	for c in board.get_neighbours(mouse_cell):
		var p := board.cell_centre(c).lerp(cursor_pos, 0.5)
		draw_circle(p, 2.0, Color.GOLD)

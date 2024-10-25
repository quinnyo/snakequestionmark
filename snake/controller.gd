class_name SnakeController extends Cellular

var _segs: Array[SnakeSegment] = []


func clear():
	for child in _segs:
		child.queue_free()
	_segs.clear()


func append_segment(s: SnakeSegment) -> void:
	add_child(s)
	_segs.append(s)


func start(head: Vector2i, length: int):
	var dir := Vector2i.DOWN
	clear()
	var face := SnakeSegment.new()
	#face.type = SnakeSegment.SegmentType.FACE
	face.cpos = head + dir
	append_segment(face)
	var c := head
	for i in range(length):
		var s := SnakeSegment.new()
		#s.type = SnakeSegment.SegmentType.HEAD if i == 0 else SnakeSegment.SegmentType.BODY
		s.cpos = c
		append_segment(s)
		c -= dir


func check() -> bool:
	if _segs.size() < 2:
		return false
	for seg in range(1, _segs.size()):
		var s0 := _segs[seg - 1]
		var s1 := _segs[seg]
		var d := s0.cpos - s1.cpos
		if absi(d.x) == 1 && d.y != 0:
			return false
		if absi(d.y) == 1 && d.x != 0:
			return false
	return true


func seg_cpos(seg: int) -> Vector2i:
	assert(seg >= 0 && seg < _segs.size())
	return _segs[seg].cpos


func seg_set_cpos(seg: int, c: Vector2i) -> void:
	assert(seg >= 0 && seg < _segs.size())
	_segs[seg].cpos = c
	_segs[seg].queue_redraw()


func seg_direction(seg: int) -> Vector2i:
	assert(seg >= 0 && seg < _segs.size())
	return _segs[seg].heading()


func try_face_direction(d: Vector2i) -> void:
	if absi(d.x) + absi(d.y) != 1:
		return
	if _segs.size() > 2:
		# can't go backwards into self
		if seg_direction(2) == -d:
			return
	if _segs.size() >= 2:
		seg_set_cpos(0, seg_cpos(1) + d)

	queue_redraw()


func step() -> void:
	if _segs.size() < 2:
		return

	# If forward position is not empty, STOP?
	var nextcpos := seg_cpos(0)
	if !_board.is_open(nextcpos):
		# ????: Try alternatives?
		# ????: If no open cells, STOP???
		return

	# MOVE
	var head_forward := seg_direction(1)
	for seg in range(_segs.size() - 1, 0, -1):
		seg_set_cpos(seg, seg_cpos(seg - 1))
	seg_set_cpos(0, nextcpos + head_forward)

	queue_redraw()


func _ready() -> void:
	start(Vector2i(7, 5), 5)


func _process(_delta: float) -> void:
	var dir := Vector2i.ZERO
	if Input.is_action_pressed("ui_right"):
		dir.x += 1
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1
	if Input.is_action_pressed("ui_down"):
		dir.y += 1
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1
	try_face_direction(dir)


func _draw() -> void:
	if !_board:
		return
	if _segs.size() < 2:
		return

	var points := PackedVector2Array()
	for seg in range(1, _segs.size()):
		var s0 := seg_cpos(seg - 1)
		var s1 := seg_cpos(seg)
		var d := Vector2(s0 - s1)
		var centre := _board.cell_centre(s1)
		points.append(centre)
		var radius := 9.0 if seg == 1 else 5.0
		var seg_pos := centre + d * radius / 3.0
		draw_circle(seg_pos, radius, Color.DARK_ORANGE)
		if seg == 1:
			var right := seg_pos + d.rotated(deg_to_rad(25.0)) * (radius * 0.8)
			var left := seg_pos + d.rotated(deg_to_rad(-25.0)) * (radius * 0.8)
			draw_circle(right, radius / 4.0, Color.BLACK)
			draw_circle(left, radius / 4.0, Color.BLACK)
	draw_polyline(points, Color.SPRING_GREEN, 2.0)


func _on_metronome_tick(_n: int) -> void:
	step()

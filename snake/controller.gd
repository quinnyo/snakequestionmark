class_name SnakeController extends Cellular

@export var allow_diagonals: bool = false
@export var step_size: int = 2

var _segs: Array[SnakeSegment] = []


func clear():
	for child in _segs:
		child.queue_free()
	_segs.clear()


func length() -> int:
	return _segs.size()


func append_segment(s: SnakeSegment) -> void:
	add_child(s)
	_segs.append(s)


func grow(dir: Vector2i = Vector2i.ZERO) -> void:
	if length() == 0:
		push_error("cannot grow() zero length snake")
		return
	var segahead := _segs[-1]
	var s := SnakeSegment.new()
	s.cpos = _segs[-1].cpos - dir
	if length() == 1:
		s.type = SnakeSegment.SegmentType.HEAD
	elif length() > 2:
		segahead.type = SnakeSegment.SegmentType.BODY
	append_segment(s)


func start(head: Vector2i, add_length: int = 0):
	var dir := Vector2i.DOWN * step_size
	clear()
	var segface := SnakeSegment.new()
	segface.cpos = head + dir
	segface.type = SnakeSegment.SegmentType.FACE
	append_segment(segface)
	grow(dir)
	for i in range(add_length):
		grow()


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
	if _segs.size() < 2:
		return
	if !allow_diagonals && d.x != 0 && d.y != 0:
		return
	d = d.sign() * step_size
	# prevent self intersection
	var newpos := seg_cpos(1) + d
	for seg in _segs:
		if seg.cpos == newpos:
			return
	if _board.is_open(newpos):
		seg_set_cpos(0, seg_cpos(1) + d)


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
	try_face_direction(dir * step_size)


func _on_metronome_tick(_n: int) -> void:
	step()

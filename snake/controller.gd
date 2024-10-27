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
	var s := SnakeSegment.new()
	s.cpos = _seg_cpos(-1) - dir
	if length() == 1:
		s.type = SnakeSegment.SegmentType.HEAD
	elif length() > 2:
		_segs[-1].type = SnakeSegment.SegmentType.BODY
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


func try_face_direction(d: Vector2i) -> void:
	if length() < 2:
		return
	if !allow_diagonals && d.x != 0 && d.y != 0:
		return
	d = d.sign() * step_size
	# prevent self intersection
	var newpos := _seg_cpos(1) + d
	for seg in _segs:
		if seg.cpos == newpos:
			return
	if _board.is_open(newpos):
		_seg_set_cpos(0, newpos)


func step() -> void:
	if length() < 2:
		return

	# If forward position is not empty, STOP?
	var nextcpos := _seg_cpos(0)
	if !_board.is_open(nextcpos):
		# ????: Try alternatives?
		# ????: If no open cells, STOP???
		return

	# MOVE
	var head_forward := _seg_heading(1)
	for seg in range(length() - 1, 0, -1):
		_seg_set_cpos(seg, _seg_cpos(seg - 1))
	_seg_set_cpos(0, nextcpos + head_forward)


func _seg_cpos(idx: int) -> Vector2i:
	return _segs[idx].cpos


func _seg_set_cpos(idx: int, c: Vector2i) -> void:
	_segs[idx].cpos = c
	_segs[idx].queue_redraw()


func _seg_heading(idx: int) -> Vector2i:
	return _segs[idx].heading()


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

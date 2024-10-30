class_name SnakeController extends Cellular

signal crashed()

enum Flag {
	STEER_DIAGONAL,
	STEER_180,
	STEER_AT_WALL,
	STEER_AT_SELF,

	_COUNT,
	STEERF_DEFAULT = (1 << STEER_AT_WALL) | (1 << STEER_AT_SELF),
	DEFAULT = STEERF_DEFAULT
}

@export_flags(
	"Steer Diagonal", "Steer 180", "Steer At Wall", "Steer At Self"
) var flags: int = Flag.DEFAULT

@export var step_size: int = 2

var _crashed: bool = false
var _segs: Array[SnakeSegment] = []


func flag(f: Flag) -> bool:
	return flags & (1 << f)


func flag_set(f: Flag) -> void:
	flags |= (1 << f)


func flag_clear(f: Flag) -> void:
	flags &= ~(1 << f)


func clear():
	_crashed = false
	for child in _segs:
		child.queue_free()
	_segs.clear()


func length() -> int:
	return _segs.size()


func append_segment(s: SnakeSegment) -> void:
	add_child(s)
	_segs.append(s)


func grow(dir: Vector3i = Vector3i.ZERO) -> void:
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


func start(head: Vector3i, add_length: int = 0):
	var dir := Vector3i(0, 1, 0) * step_size
	clear()
	var segface := SnakeSegment.new()
	segface.cpos = head + dir
	segface.type = SnakeSegment.SegmentType.FACE
	append_segment(segface)
	grow(dir)
	for i in range(add_length):
		grow()


func try_face_direction(d: Vector3i) -> void:
	if length() < 2:
		return
	if d.x == 0 && d.y == 0:
		return
	if !flag(Flag.STEER_DIAGONAL) && d.x != 0 && d.y != 0:
		return
	if !flag(Flag.STEER_180) && length() > 2:
		if d.sign() == -_seg_heading(2).sign():
			return
	d = d.sign() * step_size
	var newpos := _seg_cpos(1) + d
	if !flag(Flag.STEER_AT_SELF):
		for seg in _segs:
			if seg.cpos == newpos:
				return
	if !flag(Flag.STEER_AT_WALL) && !_board.is_open(newpos):
		return
	_seg_set_cpos(0, newpos)


func step() -> void:
	if _crashed:
		pass
	else:
		motion()


func motion() -> void:
	if length() < 2:
		return

	# If forward position is not empty, STOP?
	var nextcpos := _seg_cpos(0)
	if !can_move_to(nextcpos):
		# ????: Try alternatives?
		# ????: If no open cells, STOP???
		crash()
		return

	# MOVE
	var head_forward := _seg_heading(1)
	for seg in range(length() - 1, 0, -1):
		_seg_set_cpos(seg, _seg_cpos(seg - 1))
	_seg_set_cpos(0, nextcpos + head_forward)


func crash() -> void:
	_crashed = true
	crashed.emit()


func can_move_to(c: Vector3i) -> bool:
	if !_board.is_open(c):
		return false
	for i in range(1, length()):
		if _seg_cpos(i) == c:
			return false
	return true


func _seg_cpos(idx: int) -> Vector3i:
	return _segs[idx].cpos


func _seg_set_cpos(idx: int, c: Vector3i) -> void:
	_segs[idx].cpos = c
	_segs[idx].queue_redraw()


func _seg_heading(idx: int) -> Vector3i:
	return _segs[idx].heading()


func _ready() -> void:
	start(Vector3i(3, 3, 0), 5)


func _process(_delta: float) -> void:
	if _crashed:
		pass
	else:
		var dir := Vector3i.ZERO
		if Input.is_action_just_pressed("ui_right"):
			dir.x += 1
		if Input.is_action_just_pressed("ui_left"):
			dir.x -= 1
		if Input.is_action_just_pressed("ui_down"):
			dir.y += 1
		if Input.is_action_just_pressed("ui_up"):
			dir.y -= 1
		try_face_direction(dir * step_size)


func _on_metronome_tick(_n: int) -> void:
	step()

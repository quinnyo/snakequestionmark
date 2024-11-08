class_name SnakeController extends Cellular

signal crashed()

enum Status {
	NIL,
	ALIVE,
	CRASHED,
	DEAD,
	OBSTRUCTED,
}

enum Flag {
	STEER_DIAGONAL,
	STEER_180,
	STEER_AT_WALL,
	STEER_AT_SELF,

	MOTION_AUTO,
	MOTION_IMMEDIATE,

	_COUNT,
	STEERF_DEFAULT = (1 << STEER_AT_WALL) | (1 << STEER_AT_SELF),
	MOTIONF_DEFAULT = (1 << MOTION_AUTO),
	DEFAULT = STEERF_DEFAULT | MOTIONF_DEFAULT
}

@export_flags(
	"Steer Diagonal", "Steer 180", "Steer At Wall", "Steer At Self",
	"Motion Auto", "Motion Immediate"
) var flags: int = Flag.DEFAULT

@export var step_size: int = 1

var action_points: int = 0
var status: Status = Status.NIL:
	set(value):
		status = value
		BuggyG.say(self, "snake", Status.keys()[status])

var _segs: Array[SnakeSegment] = []

var _generation: int


func flag(f: Flag) -> bool:
	return flags & (1 << f)


func flag_set(f: Flag) -> void:
	flags |= (1 << f)


func flag_clear(f: Flag) -> void:
	flags &= ~(1 << f)


func clear():
	status = Status.NIL
	for child in _segs:
		child.queue_free()
	_segs.clear()
	_generation += 1


func length() -> int:
	return _segs.size()


func append_segment(s: SnakeSegment) -> void:
	s.name = "seg_%d-%d" % [ _generation, _segs.size() ]
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


func start(c: Vector3i, dir: Vector3i, add_length: int = 0) -> void:
	clear()
	dir = dir.sign() * step_size
	if !_board.is_open(c + dir):
		status = Status.OBSTRUCTED
		return
	var segface := SnakeSegment.new()
	segface.cpos = c + dir
	segface.type = SnakeSegment.SegmentType.FACE
	append_segment(segface)
	grow(dir)
	for i in range(add_length):
		grow()
	status = Status.ALIVE


func start_auto() -> void:
	var p := _board.origin - Vector2i(1, 0) # + _board.size / 2
	var d := Vector3i(1, 0, 0)
	start(Vector3i(p.x, p.y, 0), d, _get_next_length())


func try_set_heading(d: Vector3i) -> bool:
	if status != Status.ALIVE:
		return false
	d = d.sign() * step_size
	if !check_motion_delta(d):
		return false
	if !flag(Flag.STEER_180) && length() > 2:
		if d.sign() == -_seg_heading(2).sign():
			return false
	var newpos := _seg_cpos(1) + d
	if !flag(Flag.STEER_AT_SELF):
		for seg in _segs:
			if seg.cpos == newpos:
				return false
	if !flag(Flag.STEER_AT_WALL) && !_board.is_open(newpos):
		return false
	_seg_set_cpos(0, newpos)
	return true


func check_motion_delta(d: Vector3i) -> bool:
	if length() < 2:
		return false
	if d.x == 0 && d.y == 0:
		return false
	if d.z != 0:
		return false
	if !flag(Flag.STEER_DIAGONAL) && d.x != 0 && d.y != 0:
		return false
	if d.sign() * step_size != d:
		return false
	return true


func act() -> void:
	if status == Status.CRASHED:
		if length():
			var seg := _segs.pop_front() as SnakeSegment
			seg.stone = true
			seg.reparent(get_parent())
		else:
			status = Status.DEAD
	elif status == Status.ALIVE:
		motion()


## Move on current heading, if possible.
func motion() -> void:
	if length() < 2:
		return
	if action_points <= 0:
		return
	if check_motion_delta(_seg_heading(0)):
		motion_move()
		action_points -= 1


## Snake forward.
func motion_move() -> void:
	if !_board.is_open(_seg_cpos(0)):
		# ????: Try alternatives?
		crash()
		return
	var head_forward := _seg_heading(1)
	for seg in range(length() - 1, 0, -1):
		_seg_set_cpos(seg, _seg_cpos(seg - 1))
	if flag(Flag.MOTION_AUTO):
		try_set_heading(head_forward)


func crash() -> void:
	_segs[0].queue_free()
	_segs.pop_front()
	status = Status.CRASHED
	crashed.emit()


func _seg_cpos(idx: int) -> Vector3i:
	return _segs[idx].cpos


func _seg_set_cpos(idx: int, c: Vector3i) -> void:
	_segs[idx].cdir = c - _segs[idx].cpos
	_segs[idx].cpos = c
	_segs[idx].queue_redraw()


func _seg_heading(idx: int) -> Vector3i:
	return _segs[idx].heading()


func _get_next_length() -> int:
	return randi_range(2, 7)


func _init() -> void:
	ghost = true


func _ready() -> void:
	start_auto()

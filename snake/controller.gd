class_name SnakeController extends Cellular

signal crashed()

enum Status {
	NIL,
	ALIVE,
	CRASHED,
	STONE,
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

	GRAVITY_ENABLE,

	STEERF_DEFAULT = (1 << STEER_AT_WALL) | (1 << STEER_AT_SELF),
	MOTIONF_DEFAULT = (1 << MOTION_AUTO),
	DEFAULT = STEERF_DEFAULT | MOTIONF_DEFAULT | (1 << GRAVITY_ENABLE)
}

@export_flags(
	"Steer Diagonal", "Steer 180", "Steer At Wall", "Steer At Self",
	"Motion Auto", "Motion Immediate",
	"Gravity Enable",
) var flags: int = Flag.DEFAULT

@export var gravity := Vector3i(0, 1, 0)
@export var step_size: int = 1

var action_points: int = 0
var status: Status = Status.NIL:
	set(value):
		status = value
		BuggyG.say(self, "snake", Status.keys()[status])
## Next step vector -- consumed when applied.
var walk_step: Vector3i

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
	if _segs[-1].type == SnakeSegment.SegmentType.TAIL:
		_segs[-1].type = SnakeSegment.SegmentType.BODY
	append_segment(s)


func start(c: Vector3i, dir: Vector3i, add_length: int = 0) -> void:
	clear()
	if !_board.is_open(c):
		status = Status.OBSTRUCTED
		return
	dir = dir.sign()
	var head := SnakeSegment.new()
	head.cpos = c
	head.cdir = dir
	head.type = SnakeSegment.SegmentType.HEAD
	append_segment(head)
	for i in range(add_length):
		grow()
	status = Status.ALIVE


func start_auto() -> void:
	var p := _board.origin - Vector2i(1, 0)
	var d := Vector3i(1, 0, 0)
	start(Vector3i(p.x, p.y, 0), d, _get_next_length())


func try_set_heading(d: Vector3i) -> bool:
	if status != Status.ALIVE:
		return false
	d = d.sign() * step_size
	if !check_motion_delta(d):
		return false
	if !flag(Flag.STEER_180) && length() >= 2:
		if d.sign() == -_seg_heading(1).sign():
			return false
	var newpos := _seg_cpos(0) + d
	if !flag(Flag.STEER_AT_SELF):
		for seg in _segs:
			if seg.cpos == newpos:
				return false
	if !flag(Flag.STEER_AT_WALL) && !_board.is_open(newpos):
		return false
	_segs[0].cdir = d.sign()
	walk_step = d
	if flag(SnakeController.Flag.MOTION_IMMEDIATE):
		walk(_seg_heading(0))
	return true


func check_motion_delta(d: Vector3i) -> bool:
	if length() < 1:
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
		var all_stone := true
		for seg in _segs:
			if !seg.stone:
				seg.stone = true
				all_stone = false
				break
		if all_stone:
			status = Status.STONE
	elif status == Status.ALIVE:
		if action_points > 0:
			var d := Vector3i.ZERO
			if walk_step:
				d = walk_step
				walk_step = Vector3i.ZERO
			elif flag(Flag.MOTION_AUTO):
				d = _seg_heading(0)

			if d && walk(d):
				action_points = 0
				return

		if flag(Flag.GRAVITY_ENABLE) && gravity:
			if !rigid_move(gravity):
				crash()
	elif status == Status.STONE:
		if flag(Flag.GRAVITY_ENABLE) && gravity:
			if !rigid_move(gravity):
				for seg in _segs:
					seg.reparent(get_parent())
				_segs.clear()
				status = Status.DEAD


## Snake walk by offset [param d].
## The snake [i]crashes[/i] if completing the move would cause the head segment to collide.
## Returns [code]true[/code] if the move was performed successfully.
func walk(d: Vector3i) -> bool:
	if !check_motion_delta(d):
		return false
	if !_board.is_open(_seg_cpos(0) + d):
		# ????: Try alternatives?
		crash()
		return false
	for seg in range(length() - 1, 0, -1):
		_seg_set_cpos(seg, _seg_cpos(seg - 1))
	_seg_set_cpos(0, _seg_cpos(0) + d)
	return true


func crash() -> void:
	status = Status.CRASHED
	crashed.emit()


func pose_segments(pose: Array[Vector3i], origin: int) -> void:
	if status != Status.ALIVE || pose.size() != length():
		return
	var cpos_origin := _seg_cpos(origin)
	for segidx in range(length()):
		_seg_set_cpos(segidx, cpos_origin + pose[segidx])


## Move all segments by [param d], if moved position of [b]all[/b] segments is unobstructed.
## Returns [code]true[/code] if successful.
func rigid_move(d: Vector3i) -> bool:
	if not d:
		return false
	var coast := Island.get_coast_coords(get_cells(), d.sign())
	for c in coast:
		if !_board.is_open(c + d):
			return false
	for seg in _segs:
		seg.cpos += d
	return true


func get_cells() -> Array[Vector3i]:
	var cells: Array[Vector3i] = []
	cells.resize(length())
	for i in range(length()):
		cells[i] = _seg_cpos(i)
	return cells


func _seg_cpos(idx: int) -> Vector3i:
	return _segs[idx].cpos


func _seg_set_cpos(idx: int, c: Vector3i) -> void:
	var d := c - _segs[idx].cpos
	if d != Vector3i.ZERO:
		_segs[idx].cdir = d.sign()
	_segs[idx].cpos = c
	_segs[idx].queue_redraw()


func _seg_heading(idx: int) -> Vector3i:
	return _segs[idx].heading()


func _get_next_length() -> int:
	return randi_range(2, 7)


func _init() -> void:
	ghost = true

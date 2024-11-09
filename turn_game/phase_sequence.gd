class_name TgPhaseSequence extends TgPhase

@export var sequence: Array[TgPhase] = []

var _pc: int = -1


func restart() -> void:
	if activate():
		start()


func _get_pc_phase() -> TgPhase:
	if _pc < 0 || _pc >= sequence.size():
		return null
	return sequence[_pc]


func _pc_advance() -> void:
	_pc += 1
	# skip null entries
	while _pc < sequence.size() && not sequence[_pc]:
		_pc += 1
	if _pc >= sequence.size():
		status = Status.COMPLETE
		return

	var phase := _get_pc_phase()
	if phase:
		if phase.activate():
			phase.start()


func _tg_bind() -> void:
	for phase in sequence:
		if phase:
			phase.bind(_host)


func _tg_activate() -> bool:
	_pc = 0
	for phase in sequence:
		if phase != null && phase.activate():
			return true
		_pc += 1
	return false


func _tg_start() -> void:
	var phase := _get_pc_phase()
	if phase:
		phase.start()
	else:
		status = Status.COMPLETE


func _tg_tick() -> void:
	var phase := _get_pc_phase()
	if phase:
		if phase.status == Status.ACTIVE:
			phase.tick()
		elif phase.status == Status.COMPLETE:
			_pc_advance()
		elif phase.status == Status.BREAK:
			status = Status.COMPLETE
		elif phase.status == Status.ERROR:
			push_error("phase error @pc=%d: %s" % [ _pc, phase ])
			status = Status.ERROR
			return


func _tg_input(event: InputEvent) -> void:
	var phase := _get_pc_phase()
	if phase:
		phase._tg_input(event)

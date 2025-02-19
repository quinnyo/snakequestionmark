class_name Metronome extends Node

enum RunningState { IDLE, RUNNING, PAUSED, STOPPED, _INIT }

## Default value of `process_priority`.
const PROCESS_PRIORITY := -9

signal tick(t: int, bar: int, beat: int)


@export var autostart: bool = true
## time between ticks in seconds
@export var period: float = 0.3
@export var bar_div: int = 4
## scales (multiplies) the accumulated input time
@export var time_scale: float = 1.0
## maximum number of ticks to process at once
@export var max_ticks: int = 1
## limit the number of ticks able to be accumulated
@export var max_overs: int = -1
## if true, keep the configured (e.g. in scene) value of `process_priority`
@export var custom_process_priority: bool = false

@export_storage var _state: RunningState = RunningState._INIT
@export_storage var _t_accum: float = 0.0
@export_storage var _tick_count: int = 0
@export_storage var _bar_count: int = 0


func finish_tick() -> void:
	_t_accum = period


func start() -> void:
	if _state == RunningState.STOPPED:
		reset()
	_state = RunningState.RUNNING


func pause() -> void:
	_state = RunningState.PAUSED


func stop() -> void:
	_state = RunningState.STOPPED


func reset() -> void:
	_state = RunningState.IDLE
	_t_accum = 0.0
	_tick_count = 0
	_bar_count = 0


func _tick() -> void:
	var b := _tick_count % bar_div
	tick.emit(_tick_count, _bar_count, b)
	_tick_count += 1
	if _tick_count % bar_div == 0:
		_bar_count += 1


func _ready() -> void:
	if !custom_process_priority:
		process_priority = PROCESS_PRIORITY
	if _state == RunningState._INIT && autostart:
		start()


func _process(delta: float) -> void:
	if _state != RunningState.RUNNING:
		return

	var _beat_period := period / float(bar_div)
	_t_accum += delta * time_scale
	if max_overs >= 0:
		_t_accum = minf(float(1 + max_overs) * _beat_period, _t_accum)
	var ticks := floori(_t_accum / _beat_period)
	if max_ticks >= 0:
		ticks = mini(max_ticks, ticks)
	for _i in range(ticks):
		_t_accum -= _beat_period
		_tick()

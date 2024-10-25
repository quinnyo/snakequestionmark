class_name Metronome extends Node

## Default value of `process_priority`.
const PROCESS_PRIORITY := -9


signal tick(n: int)


## time between ticks in seconds
@export var period: float = 0.3
## scales (multiplies) the accumulated input time
@export var time_scale: float = 1.0
## maximum number of ticks to process at once
@export var max_ticks: int = 1
## limit the number of ticks able to be accumulated
@export var max_overs: int = -1
## if true, keep the configured (e.g. in scene) value of `process_priority`
@export var custom_process_priority: bool = false

@export_storage var _t_accum: float = 0.0
@export_storage var _tick_count: int = 0


func _ready() -> void:
	if !custom_process_priority:
		process_priority = PROCESS_PRIORITY


func _process(delta: float) -> void:
	_t_accum += delta * time_scale
	if max_overs >= 0:
		_t_accum = minf(float(1 + max_overs) * period, _t_accum)
	var ticks := floori(_t_accum / period)
	if max_ticks >= 0:
		ticks = mini(max_ticks, ticks)
	for _i in range(ticks):
		_t_accum -= period
		tick.emit(_tick_count)
		_tick_count += 1

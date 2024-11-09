class_name TgPhase extends Resource


enum Status { NIL, ACTIVE, COMPLETE, BREAK, REPEAT, ERROR }
func fmt_status(s: Status, short: bool = false) -> String:
	var sfmt := "%s" if short else "Status.%s"
	return sfmt % [ Status.keys()[s] if s >= 0 && s < Status.size() else s ]


@export var name: String = "Phase"

var status: Status = Status.NIL:
	set(value):
		#if status != value:
			#print("%s.status = %s (<-- %s)" % [ self,  fmt_status(value, true), fmt_status(status, true) ])
		status = value
var _host: TgGame


func _to_string() -> String:
	return "<TgPhase|%s>" % [ get_script().resource_path.get_file() ]


func bind(game: TgGame) -> void:
	_host = game
	_tg_bind()


func activate() -> bool:
	if _tg_activate():
		status = Status.ACTIVE
		return true
	return false


func start() -> void:
	_tg_start()


func tick() -> void:
	_tg_tick()


func _tg_bind() -> void:
	pass


func _tg_activate() -> bool:
	return false


func _tg_start() -> void:
	pass


func _tg_tick() -> void:
	pass


func _tg_input(event: InputEvent) -> void:
	var _not_unused = event

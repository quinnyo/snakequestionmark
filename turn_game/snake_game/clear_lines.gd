class_name XtgClearLines extends XtgPhase


func _tg_activate() -> bool:
	return true


func _tg_tick() -> void:
	status = Status.BREAK

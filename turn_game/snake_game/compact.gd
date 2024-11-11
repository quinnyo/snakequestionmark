class_name XtgCompact extends XtgPhase


func _tg_activate() -> bool:
	return true


func _tg_tick() -> void:
	status = Status.BREAK

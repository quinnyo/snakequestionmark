class_name XtgClearLines extends XtgPhase


var _lines: Dictionary


func _tg_activate() -> bool:
	return true


func _tg_start() -> void:
	var board := get_board()
	_lines = Lines.get_filled_lines(board)
	if _lines.size() == 0:
		# no work to do, skip further processing
		status = Status.BREAK


func _tg_tick() -> void:
	if _lines.size() == 0:
		status = Status.COMPLETE
		return

	var k: int = _lines.keys()[-1]
	while k in _lines:
		for ent in _lines[k]:
			ent.queue_free()
		_lines.erase(k)
		k -= 1

class_name XtgCompact extends XtgPhase


const CellShift := preload("res://board/extra/cell_shift.gd")

var cell_shift: CellShift


func _tg_activate() -> bool:
	return true


func _tg_start() -> void:
	var board := get_board()
	cell_shift = CellShift.new()
	cell_shift.board = board
	cell_shift.prepare()
	if !cell_shift.has_work():
		status = Status.BREAK


func _tg_tick() -> void:
	if cell_shift.has_work():
		cell_shift.perform()
	else:
		status = Status.COMPLETE

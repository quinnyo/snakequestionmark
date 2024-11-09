class_name XtgPhase extends TgPhase

var xtg_host: XtgGame:
	get:
		return _host as XtgGame


func get_board() -> Board2D:
	return xtg_host.board

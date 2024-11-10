class_name XtgRoundStart extends XtgPhase


func _tg_activate() -> bool:
	return true


func _tg_start() -> void:
	var board := get_board()
	if not board:
		push_error("expected board")
		status = Status.ERROR
		return
	var snake := SnakeController.new()
	snake.name = "SnakeController"
	snake.flag_clear(SnakeController.Flag.MOTION_AUTO)
	board.add_child(snake)
	var p := board.origin + Vector2i(board.size.x, 0) / 2
	var d := Vector3i(-1, 0, 0)
	snake.start(Vector3i(p.x, p.y, 0), d, 3)
	if snake.status == SnakeController.Status.OBSTRUCTED:
		status = Status.BREAK


func _tg_tick() -> void:
	status = Status.COMPLETE

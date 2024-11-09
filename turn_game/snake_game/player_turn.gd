class_name XtgPlayer extends XtgPhase


var snake: SnakeController


func _tg_activate() -> bool:
	var board := get_board()
	snake = board.get_node("SnakeController")
	return snake != null


func _tg_tick() -> void:
	snake.act()
	if snake.status == SnakeController.Status.DEAD:
		status = Status.COMPLETE
		snake.queue_free()
	elif snake.status != SnakeController.Status.ALIVE:
		snake.action_points = 1


func _tg_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_right"):
		snake.try_set_heading(Vector3i(1, 0, 0))
	elif event.is_action_pressed("ui_left"):
		snake.try_set_heading(Vector3i(-1, 0, 0))
	elif event.is_action_pressed("ui_down"):
		snake.try_set_heading(Vector3i(0, 1, 0))
	elif event.is_action_pressed("ui_up"):
		snake.try_set_heading(Vector3i(0, -1, 0))

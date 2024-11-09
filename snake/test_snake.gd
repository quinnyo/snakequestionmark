extends Node2D

var shift := preload("res://board/extra/cell_shift.gd").new()

@onready var metronome: Metronome = $Metronome as Metronome
@onready var snake: SnakeController = $Board2D/SnakeController as SnakeController
@onready var board: Board2D = $Board2D as Board2D

func tick(_t: int, bar: int, beat: int) -> void:
	BuggyG.say(self, "turn", "%d:%d" % [ bar, beat ])
	if beat == 0:
		if shift.has_work():
			shift.perform()
			if !shift.has_work():
				start_next_snake()
			return
		_action()
		_post_action()


func start_next_snake() -> void:
	var p := board.get_bounds().end - Vector2i(1, 1)
	var d := Vector3i(-1, 0, 0)
	snake.start(Vector3i(p.x, p.y, 0), d, 3)


func _action() -> void:
	snake.act()
	if snake.status == SnakeController.Status.DEAD:
		shift.board = board
		shift.prepare()


func _post_action() -> void:
	snake.action_points = 1


func _ready() -> void:
	start_next_snake()


func _process(_delta: float) -> void:
	var dir := Vector3i.ZERO
	if Input.is_action_just_pressed("ui_right"):
		dir.x += 1
	if Input.is_action_just_pressed("ui_left"):
		dir.x -= 1
	if Input.is_action_just_pressed("ui_down"):
		dir.y += 1
	if Input.is_action_just_pressed("ui_up"):
		dir.y -= 1
	if dir != Vector3i.ZERO:
		snake.try_set_heading(dir)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("_debug_reload"):
		get_tree().reload_current_scene()
	if event is InputEventKey && event.is_pressed():
		if event.keycode == KEY_1:
			snake.pose_segments([Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(2, 0, 0), Vector3i(3, 0, 0)], 0)
			snake.crash()
		elif event.keycode == KEY_2:
			snake.pose_segments([Vector3i(0, 0, 0), Vector3i(0, -1, 0), Vector3i(1, -1, 0), Vector3i(2, -1, 0)], 0)
			snake.crash()
		elif event.keycode == KEY_3:
			snake.pose_segments([Vector3i(0, -1, 0), Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(2, 0, 0)], 1)
			snake.crash()
		elif event.keycode == KEY_4:
			snake.pose_segments([Vector3i(0, 0, 0), Vector3i(0, -1, 0), Vector3i(1, -1, 0), Vector3i(1, 0, 0)], 0)
			snake.crash()
		elif event.keycode == KEY_5:
			snake.pose_segments([Vector3i(-2, -1, 0), Vector3i(-1, -1, 0), Vector3i(-1, 0, 0), Vector3i(0, 0, 0)], 3)
			snake.crash()
		elif event.keycode == KEY_6:
			snake.pose_segments([Vector3i(0, 0, 0), Vector3i(1, 0, 0), Vector3i(1, -1, 0), Vector3i(2, -1, 0)], 0)
			snake.crash()


func _on_metronome_tick(t: int, bar: int, beat: int) -> void:
	tick(t, bar, beat)

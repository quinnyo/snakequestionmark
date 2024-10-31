extends Node2D


@onready var metronome: Metronome = $Metronome as Metronome
@onready var snake: SnakeController = $Board2D/SnakeController as SnakeController


func tick(_t: int, bar: int, beat: int) -> void:
	BuggyG.say(self, "turn", "%d:%d" % [ bar, beat ])
	if beat == 0:
		_action()
		_post_action()


func _action() -> void:
	snake.act()


func _post_action() -> void:
	snake.action_points = 1


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
		if snake.try_set_heading(dir):
			if snake.flag(SnakeController.Flag.MOTION_IMMEDIATE):
				metronome.finish_tick()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("_debug_reload"):
		get_tree().reload_current_scene()


func _on_metronome_tick(t: int, bar: int, beat: int) -> void:
	tick(t, bar, beat)

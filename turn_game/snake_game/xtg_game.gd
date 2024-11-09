class_name XtgGame extends TgGame

@onready var metronome: Metronome = $Metronome as Metronome
@onready var board: Board2D = $Board2D as Board2D


func _ready() -> void:
	start()
	metronome.start()


func _on_metronome_tick(_t: int, _bar: int, beat: int) -> void:
	if beat == 0:
		tick()

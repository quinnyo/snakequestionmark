class_name TgGame extends Node

@export var sequence: TgPhaseSequence


func start() -> void:
	if not sequence:
		return
	sequence.bind(self, null)
	if !sequence.activate():
		push_error("root sequence cannot be activated.")
		return
	sequence.start()


func tick() -> void:
	if not sequence:
		return
	sequence.tick()
	if sequence.status == TgPhase.Status.COMPLETE:
		sequence.restart()


func _unhandled_input(event: InputEvent) -> void:
	if not sequence:
		return
	sequence._tg_input(event)

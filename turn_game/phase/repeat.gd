class_name TgPhaseRepeat extends TgPhase
## A flow control phase that causes the sequence that contains it to be repeated.

## Iteration count (number of times to repeat the sequence).
## A value of `0` means don't repeat (this phase won't be activated).
## A value of `-1` is means repeat an unlimited number of times.
@export var count: int = -1

# iters remaining
var _count: int = 0


func _tg_bind() -> void:
	# set remaining iter count -- sequence binds all its phases before first activation
	_count = count


func _tg_activate() -> bool:
	return true


func _tg_start() -> void:
	if _count < 0:
		status = Status.REPEAT
	elif _count == 0:
		status = Status.COMPLETE
	else:
		_count -= 1
		status = Status.REPEAT

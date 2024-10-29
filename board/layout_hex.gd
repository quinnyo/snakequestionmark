@tool
class_name PhieldLayoutHex extends PhieldLayout

enum HexOrientation { POINTY_TOP, FLAT_TOP, CUSTOM }

const ORIENT_XF: Array[Transform2D] = [
	Transform2D(Vector2(sqrt(3.0), 0.0), Vector2(sqrt(3.0) / 2.0, 3.0 / 2.0), Vector2.ZERO),
	Transform2D(Vector2(3.0 / 2.0, sqrt(3.0) / 2.0), Vector2(0.0, sqrt(3.0)), Vector2.ZERO),
]
const ORIENT_ANGLE: Array[float] = [
	0.5,
	0.0,
]


@export var orientation: HexOrientation:
	set(value):
		orientation = value
		var i := int(orientation)
		if i < HexOrientation.CUSTOM:
			xf = ORIENT_XF[i]
			start_angle = ORIENT_ANGLE[i]


func _init() -> void:
	orientation = HexOrientation.POINTY_TOP

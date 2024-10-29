@tool
class_name PhieldLayout extends Resource

@export var origin: Vector2 = Vector2.ZERO:
	set(value):
		origin = value
		emit_changed()
@export var size: Vector2 = Vector2(32, 32):
	set(value):
		size = value
		emit_changed()
@export var border_width: Vector2 = Vector2(8, 8):
	set(value):
		border_width = value
		emit_changed()
@export var start_angle: float = 0.0:
	set(value):
		start_angle = value
		emit_changed()
@export var xf: Transform2D = Transform2D.IDENTITY:
	set(value):
		xf = value
		xb = xf.affine_inverse()
		emit_changed()

var xb: Transform2D = Transform2D.IDENTITY


func xform(c: Vector2) -> Vector2:
	var p := xf * c * size
	return p + origin


func xform_inv(p: Vector2) -> Vector2:
	var pt := (p - origin) / size
	return xb * pt

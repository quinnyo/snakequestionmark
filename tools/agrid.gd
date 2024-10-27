@tool
class_name Agrid extends Resource

@export var offset_x: float = 0.0:
	set(value):
		offset_x = value
		emit_changed()
@export var offset_y: float = 0.0:
	set(value):
		offset_y = value
		emit_changed()
@export var spacing_x: float = 8.0:
	set(value):
		spacing_x = value
		emit_changed()
@export var spacing_y: float = 8.0:
	set(value):
		spacing_y = value
		emit_changed()


func get_lines(region: Rect2) -> Array[PackedVector2Array]:
	var offset := Vector2(offset_x, offset_y)
	region.position -= offset

	var cx0 := ceili(region.position.x / spacing_x)
	var columns := floori(region.size.x / spacing_x)
	var cx1 := cx0 + columns
	var cy0 := ceili(region.position.y / spacing_y)
	var rows := floori(region.size.y / spacing_y)
	var cy1 := cy0 + rows

	var vertical := PackedVector2Array()
	for cx in range(cx0, cx1):
		var a := Vector2(cx * spacing_x, cy0 * spacing_y)
		vertical.append(offset + a)
		var b := Vector2(cx * spacing_x, cy1 * spacing_y)
		vertical.append(offset + b)

	var horizontal := PackedVector2Array()
	for cy in range(cy0, cy1):
		var a := Vector2(cx0 * spacing_x, cy * spacing_y)
		horizontal.append(offset + a)
		var b := Vector2(cx1 * spacing_x, cy * spacing_y)
		horizontal.append(offset + b)

	return [ vertical, horizontal ]

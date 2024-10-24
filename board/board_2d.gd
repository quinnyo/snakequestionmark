class_name Board2D extends Node2D

@export var phield: PhieldSquare
@export var layout: LayoutSquare


func cell_position(c: Vector2i) -> Vector2:
	return phield.origin(c, layout)


func cell_centre(c: Vector2i) -> Vector2:
	return phield.centre(c, layout)


func is_open(c: Vector2i) -> bool:
	if phield.is_out_of_bounds(c):
		return false
	return true


static func find_parent_board(node: Node) -> Board2D:
	var parent := node.get_parent()
	while parent && parent is not Board2D:
		parent = parent.get_parent()
	return parent


func _draw() -> void:
	if !phield:
		return

	var cmin := phield.bounds_min
	var cmax := phield.bounds_max
	for y in range(cmin.y, cmax.y):
		for x in range(cmin.x, cmax.x):
			var c := Vector2i(x, y)
			var color := Color.STEEL_BLUE
			if phield.c_is_border(c):
				color = Color.POWDER_BLUE
			elif phield.c_is_corner(c):
				color = Color.AQUAMARINE
			var points := phield.vertices(c, layout)
			draw_colored_polygon(points, color)


	# a grid
	#for x in range(0, 2048, 16):
		#draw_line(Vector2(x, 0), Vector2(x, 2048), Color(0.4, 0.803922, 0.666667, 0.5))
	#for y in range(0, 2048, 16):
		#draw_line(Vector2(0, y), Vector2(2048, y), Color(1, 0.388235, 0.278431, 0.5))

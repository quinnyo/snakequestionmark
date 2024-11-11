class_name Lines extends RefCounted


static func get_filled_lines(board: Board2D) -> Dictionary:
	var lines := {}
	for dy in range(board.size.y):
		var y := board.origin.y + dy
		var cells: Array[Cellular] = []
		cells.resize(board.size.x)
		var filled := true
		for dx in range(board.size.x):
			var c := Vector3i(board.origin.x + dx, y, 0)
			var ent := board.occupant(c)
			if ent:
				cells[dx] = ent
			else:
				filled = false
				break
		if filled:
			lines[dy] = cells
	return lines

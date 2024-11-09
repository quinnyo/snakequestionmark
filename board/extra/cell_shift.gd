extends RefCounted

var board: Board2D
var shift_direction: Vector3i = Vector3i(0, 1, 0)
var island_entities := []
var island_bases := []


func has_work() -> bool:
	return island_entities.size() > 0


func cancel() -> void:
	island_entities.clear()
	island_bases.clear()


func prepare() -> void:
	island_entities.clear()
	island_bases.clear()
	for isl in Islands.go(board):
		island_entities.push_back(isl.get_entities())
		island_bases.push_back(isl.get_base(shift_direction))


func perform() -> void:
	var i := 0
	while i < island_entities.size():
		if !try_shift_island(island_entities[i], island_bases[i]):
			island_entities[i] = island_entities[-1]
			island_entities.pop_back()
			island_bases[i] = island_bases[-1]
			island_bases.pop_back()
		else:
			i += 1


func try_shift_island(entities: Array[Cellular], base: Array[Vector3i]) -> bool:
	for i in range(base.size()):
		var c := base[i] + shift_direction
		if !board.is_open(c):
			return false
		base[i] = c
	for ent in entities:
		ent.cpos += shift_direction
	return true

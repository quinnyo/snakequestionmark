class_name Islands extends RefCounted


# Entities are stored in a dictionary, keyed by coordinates -- `Map<Vector3i, Cellular>`.
# When an entity is inserted, unfilled cells adjacent to it are inserted alongside it.
# Empty cells are tracked by storing `null` entities.
# After the first item is added, items can only be inserted into empty cells.
class Island:
	var _items := {}
	var _board: Board2D

	func _init(board: Board2D) -> void:
		_board = board
		pass

	func has_empty(c: Vector3i) -> bool:
		return _items.has(c) && _items[c] == null

	func has_filled(c: Vector3i) -> bool:
		return _items.has(c) && _items[c] != null

	func can_insert(ent: Cellular) -> bool:
		if ent == null:
			return false
		if _items.size() == 0:
			return true
		return has_empty(ent.cpos)

	func insert(ent: Cellular) -> void:
		_items[ent.cpos] = ent
		# set adjacent empty cells to `null`
		for c in _board.get_neighbours(ent.cpos):
			if !_items.has(c):
				_items[c] = null
		return

	func get_entities() -> Array[Cellular]:
		var entities: Array[Cellular] = []
		for ent in _items.values():
			if ent == null:
				continue
			entities.push_back(ent)
		return entities

	func can_merge(other: Island) -> bool:
		if _items.size() == 0 || other._items.size() == 0:
			return true
		var found_empty := false
		for ent in other.get_entities():
			if _items.has(ent.cpos):
				if _items[ent.cpos] == null:
					found_empty = true
				else:
					return false
		return found_empty

	func merge(other: Island) -> void:
		for ent in other.get_entities():
			insert(ent)

	func get_base(dir: Vector3i) -> Array[Vector3i]:
		var base: Array[Vector3i] = []
		for ent in _items.values():
			if ent == null:
				continue
			if has_empty(ent.cpos + dir):
				base.push_back(ent.cpos)
		return base


## Extract the minimal set of islands from [param board].
static func go(board: Board2D) -> Array[Island]:
	var entities: Array[Cellular] = board.get_entities(false, false)
	var islands: Array[Island] = []
	for ent in entities:
		var success := false
		for island in islands:
			if island.can_insert(ent):
				island.insert(ent)
				success = true
				break
		if !success:
			var isl := Island.new(board)
			isl.insert(ent)
			islands.push_back(isl)

	if islands.size() < 2:
		return islands

	# merge islands
	while true:
		for i in range(islands.size()):
			if islands[i] == null:
				continue
			for j in range(i + 1, islands.size()):
				if islands[j] == null:
					continue
				if islands[i].can_merge(islands[j]):
					islands[i].merge(islands[j])
					islands[j] = null

		var island_count := islands.size()
		islands = islands.filter(func(isl: Island): return isl)
		if island_count == islands.size():
			break

	return islands


## Extract the [param dir]-facing [i]coast[/i] of the tiles in [param land].
## A [i]coast[/i] is the subset of land that has no land adjacent to it in a given direction.
static func get_coast(land: Array[Vector3i], dir: Vector3i) -> Array[Vector3i]:
	var asdf := {}
	for c in land:
		asdf[c] = 1
	return land.filter(func(c): return !asdf.has(c + dir))

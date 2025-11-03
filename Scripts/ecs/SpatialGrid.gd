extends Node
class_name SpatialGrid

var cell_size := 100.0
var grid := {}

func _cell_key(pos: Vector3) -> Vector2i:
	return Vector2i(floor(pos.x / cell_size), floor(pos.z / cell_size))

func clear():
	grid.clear()

func add_entity(id: int, pos: Vector3):
	var key = _cell_key(pos)
	if not grid.has(key):
		grid[key] = []
	grid[key].append(id)

func query(pos: Vector3, radius: float) -> Array:
	var results := []
	var min_cell = _cell_key(pos - Vector3(radius, 0, radius))
	var max_cell = _cell_key(pos + Vector3(radius, 0, radius))
	for x in range(min_cell.x, max_cell.x + 1):
		for z in range(min_cell.y, max_cell.y + 1):
			var key = Vector2i(x, z)
			if grid.has(key):
				results += grid[key]
	return results

extends BaseSystem
class_name CollisionSystem

var contact_cache := {}
var cell_size: float = 30.0 # подбирай под радиусы мобов/пуль

func update(_delta: float) -> void:
	
	var entities := get_entities_with(["TransformComponent", "CollisionComponent"], ["DeadComponent"])
	var count := entities.size()
	if count < 2:
		contact_cache.clear()
		return

	# Построение грида: ключ = Vector3i, значение = массив entity_id
	var grid := {}

	for id in entities:
		var tf = cs.get_component(id, "TransformComponent")
		if tf == null:
			continue
		var cell := _to_cell(tf.position)

		if not grid.has(cell):
			grid[cell] = []
		grid[cell].append(id)

	var new_cache := {}

	# перебор ячеек + соседей
	for cell in grid.keys():
		var list_a: Array = grid[cell]

		_check_pairs(list_a, new_cache) # внутри ячейки

		for x in range(-1, 2):
			for y in range(-1, 2):
				for z in range(-1, 2):
					var neigh: Vector3i = cell + Vector3i(x, y, z)
					if neigh == cell:
						continue
					if not grid.has(neigh):
						continue

					var list_b: Array = grid[neigh]
					_check_cross_pairs(list_a, list_b, new_cache)


	contact_cache = new_cache


# ======== ПАРНЫЕ ПРОВЕРКИ =========

func _check_pairs(list: Array, new_cache: Dictionary) -> void:
	var n := list.size()
	for i in range(n):
		var a = list[i]
		var a_tf = cs.get_component(a, "TransformComponent")
		var a_col = cs.get_component(a, "CollisionComponent")
		if not a_tf or not a_col:
			continue

		for j in range(i + 1, n):
			var b = list[j]
			_check_entities(a, b, a_tf, a_col, new_cache)


func _check_cross_pairs(list_a: Array, list_b: Array, new_cache: Dictionary) -> void:
	for a in list_a:
		var a_tf = cs.get_component(a, "TransformComponent")
		var a_col = cs.get_component(a, "CollisionComponent")
		if not a_tf or not a_col:
			continue

		for b in list_b:
			_check_entities(a, b, a_tf, a_col, new_cache)


func _check_entities(a:int, b:int, a_tf, a_col, new_cache: Dictionary) -> void:
	var b_tf = cs.get_component(b, "TransformComponent")
	var b_col = cs.get_component(b, "CollisionComponent")
	if not b_tf or not b_col:
		return

	if not _layers_match(a_col, b_col):
		return

	var radius_sum = a_col.radius + b_col.radius
	if a_tf.position.distance_squared_to(b_tf.position) <= radius_sum * radius_sum:
		_process_collision(a, b, new_cache)


# ======== СТАРАЯ ЛОГИКА БЕЗ ИЗМЕНЕНИЙ =========

func _layers_match(a_col, b_col) -> bool:
	return (
		(a_col.collision_mask & b_col.collision_layer) != 0 and
		(b_col.collision_mask & a_col.collision_layer) != 0
	)


func _process_collision(a:int, b:int, new_cache: Dictionary) -> void:
	var pairs = [[a, b], [b, a]]

	for pair in pairs:
		var source = pair[0]
		var target = pair[1]

		var s_col = cs.get_component(source, "CollisionComponent")
		var t_col = cs.get_component(target, "CollisionComponent")

		var key = Vector2(source, target)

		if s_col.is_player_projectile() and t_col.is_enemy():
			_register_hit(source, target, key, new_cache)
		elif s_col.is_enemy_projectile() and t_col.is_player():
			_register_hit(source, target, key, new_cache)
		elif s_col.is_enemy() and t_col.is_player():
			_register_hit(source, target, key, new_cache)
		elif s_col.is_projectile() and t_col.is_world():
			if not cs.has_component(source, "BounceComponent"):
				cs.add_component(source, "BounceComponent", BounceComponent.new())


func _register_hit(source:int, target:int, key: Vector2, new_cache: Dictionary) -> void:
	if contact_cache.has(key):
		new_cache[key] = true
		return

	if not cs.has_component(target, "HitComponent"):
		var hit_comp := HitComponent.new()
		hit_comp.source_id = source
		cs.add_component(target, "HitComponent", hit_comp)

	new_cache[key] = true


# ======== ГРИД ОПЕРАЦИИ =========

func _to_cell(pos: Vector3) -> Vector3i:
	return Vector3i(
		int(pos.x / cell_size),
		int(pos.y / cell_size),
		int(pos.z / cell_size)
	)

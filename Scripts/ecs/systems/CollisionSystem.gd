extends BaseSystem
class_name CollisionSystem

var contact_cache := {} # key:int -> true

var tf_cache := {}  
var col_cache := {} 

var cell_size: float = 0.3

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus ):
	super._init(_entity_manager, _component_store, _event_bus)
	
	arch = cs.register_archetype(["TransformComponent", "CollisionComponent"],
		["DeadComponent"])
	
func update(_delta: float) -> void:
	tf_cache.clear()
	col_cache.clear()

	
	
	var count := arch.entities.size()
	if count < 2:
		contact_cache.clear()
		return

	for id in arch.entities:
		tf_cache[id] = cs.get_component(id, "TransformComponent")
		col_cache[id] = cs.get_component(id, "CollisionComponent")


	var grid := {} # Vector3i -> Array[int]

	for id in arch.entities:
		var tf = tf_cache[id]
		if tf == null:
			continue

		var cell := _to_cell(tf.position)
		if not grid.has(cell):
			grid[cell] = []
		grid[cell].append(id)

	var new_cache := {}


	for cell in grid.keys():
		var list_a: Array = grid[cell]

		_check_pairs(list_a, new_cache)

		for x in range(-1,2):
			for y in range(-1,2):
				for z in range(-1,2):
					var neigh: Vector3i = cell + Vector3i(x, y, z)
					if neigh == cell:
						continue
					if not grid.has(neigh):
						continue

					if neigh < cell:
						continue

					_check_cross_pairs(list_a, grid[neigh], new_cache)

	contact_cache = new_cache
	
func _check_pairs(list: Array, new_cache: Dictionary) -> void:
	var n : int = list.size()
	for i in range(n):
		var a :int= list[i]
		var a_tf = tf_cache[a]
		var a_col = col_cache[a]
		if not a_tf or not a_col:
			continue

		for j in range(i + 1, n):
			var b :int = list[j]
			_check_entities(a, b, a_tf, a_col, new_cache)


func _check_cross_pairs(list_a: Array, list_b: Array, new_cache: Dictionary) -> void:
	for a in list_a:
		var a_tf = tf_cache[a]
		var a_col = col_cache[a]
		if not a_tf or not a_col:
			continue

		for b in list_b:
			if a >= b:
				continue
			_check_entities(a, b, a_tf, a_col, new_cache)
			
func _check_entities(
	a: int,
	b: int,
	a_tf,
	a_col,
	new_cache: Dictionary
	
) -> void:
	var b_tf = tf_cache[b]
	var b_col = col_cache[b]
	if not b_tf or not b_col:
		return

	if not _layers_match(a_col, b_col):
		return

	var r :float = a_col.radius + b_col.radius
	if a_tf.position.distance_squared_to(b_tf.position) <= r * r:
		_process_collision(a, b, new_cache)
func _process_collision(a: int, b: int, new_cache: Dictionary) -> void:
	_process_one_way(a, b, new_cache)
	_process_one_way(b, a, new_cache)



	##TODO изменить порядок вызова
func _process_one_way(source: int, target: int, new_cache: Dictionary) -> void:
	var s_col = col_cache[source]
	var t_col = col_cache[target]
	if not s_col or not t_col:
		return

	var key := _pair_key(source, target)

	if s_col.is_player_projectile() and t_col.is_enemy():
		_register_hit(source, target, key, new_cache)

	elif s_col.is_enemy() and t_col.is_enemy():
		var climber = _choose_climber_by_target(source, target)
		if climber != -1 and not cs.has_component(climber, "ClimbComponent"):
			cs.add_component(climber, "ClimbComponent", ClimbComponent.new())

	elif s_col.is_enemy_projectile() and t_col.is_player():
		_register_hit(source, target, key, new_cache)
	
	elif s_col.is_enemy() and t_col.is_player():
		_register_hit(source, target, key, new_cache)
		
func _register_hit(
	source: int,
	target: int,
	key: int,
	new_cache: Dictionary) -> void:
	if contact_cache.has(key):
		new_cache[key] = true
		return

	if not cs.has_component(target, "HitComponent"):
		var hit := HitComponent.new()
		hit.source_id = source
		cs.add_component(target, "HitComponent", hit)

	new_cache[key] = true
func _layers_match(a_col, b_col) -> bool:
	return (
		(a_col.collision_mask & b_col.collision_layer) != 0

	)


func _pair_key(a: int, b: int) -> int:
	return (a << 32) | (b & 0xffffffff)


func _to_cell(pos: Vector3) -> Vector3i:
	return Vector3i(
		int(pos.x / cell_size),
		int(pos.y / cell_size),
		int(pos.z / cell_size)
	)

func _choose_climber_by_target(a: int, b: int) -> int:
	var a_target: AimComponent = cs.get_component(a, "AimComponent")
	var b_target: AimComponent = cs.get_component(b, "AimComponent")

	var a_tf: TransformComponent = tf_cache[a]
	var b_tf: TransformComponent = tf_cache[b]

	var da := a_tf.position.distance_squared_to(a_target.position)
	var db := b_tf.position.distance_squared_to(b_target.position)

	# кто ДАЛЬШЕ от своей цели — тот и лезет
	if da > db:
		return a
	elif db > da:
		return b
	else:
		# детерминированный тайбрейк
		return a if a < b else b

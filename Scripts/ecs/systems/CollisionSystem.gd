extends BaseSystem
class_name CollisionSystem

# { (source_id, target_id) : true }
var contact_cache := {}

func update(_delta: float) -> void:
	var entities = get_entities_with(["TransformComponent", "CollisionComponent"], ["DeadComponent"])
	if entities.size() < 2:
		return

	var new_cache := {}

	for i in range(entities.size()):
		var a = entities[i]
		var a_tf = cs.get_component(a, "TransformComponent")
		var a_col = cs.get_component(a, "CollisionComponent")

		for j in range(i+1, entities.size()):
			var b = entities[j]
			var b_tf = cs.get_component(b, "TransformComponent")
			var b_col = cs.get_component(b, "CollisionComponent")

			if not _layers_match(a_col, b_col):
				continue

			if a_tf.position.distance_to(b_tf.position) < a_col.radius + b_col.radius:
				_process_collision(a, b, new_cache)

	# Обновляем кеш только после проверки всех коллизий
	contact_cache = new_cache


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

		var key = Vector2(source, target) # уникальный ключ для кеша

		# Игрок → враг
		if s_col.is_player_projectile() and t_col.is_enemy():
			_register_hit(source, target, key, new_cache)

		# Враг → игрок
		elif s_col.is_enemy_projectile() and t_col.is_player():
			_register_hit(source, target, key, new_cache)

		# Контактный урон враг → игрок
		elif s_col.is_enemy() and t_col.is_player():
			_register_hit(source, target, key, new_cache)

		# Пуля → стена (отскок)
		elif s_col.is_projectile() and t_col.is_world():
			if not cs.has_component(source, "BounceComponent"):
				cs.add_component(source, "BounceComponent", BounceComponent.new())


func _register_hit(source:int, target:int, key: Vector2, new_cache: Dictionary) -> void:
	# Проверяем кеш
	if contact_cache.has(key):
		# Уже зарегистрирован в предыдущем тике
		new_cache[key] = true
		return

	# Добавляем HitComponent если его ещё нет
	if not cs.has_component(target, "HitComponent"):
		var hit_comp := HitComponent.new()
		hit_comp.source_id = source
		cs.add_component(target, "HitComponent", hit_comp)

	# Добавляем в новый кеш
	new_cache[key] = true

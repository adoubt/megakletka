extends RefCounted
class_name ObjectPool

var root_node: Node3D

# ============================================================
# 🔹 Данные одного пула
class PoolData:
	var available: Array[Node3D] = []
	var active: int = 0
	var max_size: int
	var last_used: float = 0.0

	func _init(initial_cap: int):
		max_size = initial_cap


# ============================================================
# 🔹 Все пулы: { scene_path: PoolData }
var pools: Dictionary[String, PoolData] = {}

# 🔹 Кэш сцен
var _scene_cache: Dictionary[String, PackedScene] = {}

# ============================================================
# 🔹 Настройки
const INITIAL_CAP: int = 32
const GROW_RATE: float = 1.5
const SOFT_CAP: int = 200
const HARD_CAP: int = 2000
const SHRINK_DELAY: float = 10.0 # секунд до очистки неиспользуемого пула


# ============================================================
func _init(_root_node: Node3D) -> void:
	root_node = _root_node


# ============================================================
# 🔸 Получение кэшированной сцены
func _get_scene(scene_path: String) -> PackedScene:
	if _scene_cache.has(scene_path):
		return _scene_cache[scene_path]

	var res: Resource = load(scene_path)
	if res is PackedScene:
		_scene_cache[scene_path] = res
		return res

	push_error("❌ Invalid scene path in pool: %s" % scene_path)
	return null


# ============================================================
# 🔸 Получаем объект из пула
func get_from_pool(scene_path: String) -> Node3D:
	var pool: PoolData = pools.get(scene_path)
	if pool == null:
		pool = PoolData.new(INITIAL_CAP)
		pools[scene_path] = pool

	pool.last_used = Time.get_unix_time_from_system()

	# ✅ Есть свободные
	if pool.available.size() > 0:
		var node: Node3D = pool.available.pop_back()
		pool.active += 1
		_activate_node(node)
		return node  

	# ✅ Пул полный → расширяем (без рекурсии)
	if pool.active >= pool.max_size:
		if pool.max_size < HARD_CAP:
			pool.max_size = mini(int(pool.max_size * GROW_RATE), HARD_CAP)
		else:
			push_warning("⚠️ HARD_CAP reached for: %s" % scene_path)
			return null

	# ✅ Создаём новый объект
	var scene: PackedScene = _get_scene(scene_path)
	if scene == null:
		return null

	var node: Node3D = scene.instantiate()
	root_node.add_child(node, true)

	pool.active += 1
	_activate_node(node)
	return node


# ============================================================
# 🔸 Возврат объекта в пул
func return_to_pool(scene_path: String, node: Node3D) -> void:
	var pool: PoolData = pools.get(scene_path)
	if pool == null:
		push_warning("⚠️ Attempt to return node to non-existing pool: %s" % scene_path)
		return

	_deactivate_node(node)
	pool.available.append(node)
	pool.active = maxi(0, pool.active - 1)


# ============================================================
# 🔸 Очистка неиспользуемых объектов (безопасная)
func cleanup_unused() -> void:
	var now := Time.get_unix_time_from_system()

	for scene_path in pools.keys():
		var pool: PoolData = pools[scene_path]

		if now - pool.last_used > SHRINK_DELAY and pool.available.size() > SOFT_CAP:
			var target_size = SOFT_CAP
			while pool.available.size() > target_size:
				var old: Node3D = pool.available.pop_back()
				if is_instance_valid(old):
					old.queue_free()

			pool.max_size = maxi(INITIAL_CAP, int(pool.max_size / 2))


# ============================================================
# 🔸 Активация / деактивация узлов
func _activate_node(node: Node3D) -> void:
	node.show()
	node.set_process(true)
	node.set_physics_process(true)
	if node.has_method("set_monitoring"):
		node.set_deferred("monitoring", true)

	# 🔄 Если есть reset-метод — сбрасываем пользовательское состояние
	if node.has_method("reset_state"):
		node.reset_state()


func _deactivate_node(node: Node3D) -> void:
	node.hide()
	node.set_process(false)
	node.set_physics_process(false)
	if node.has_method("set_monitoring"):
		node.set_deferred("monitoring", false)

	# ✅ Сбрасываем только transform
	node.global_transform = Transform3D.IDENTITY

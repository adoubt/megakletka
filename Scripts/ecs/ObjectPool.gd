extends Node
class_name ObjectPool

# Универсальный Object Pool для ECS
# Работает по путям к сценам (String)

var _pools: Dictionary = {}      # { scene_path: [Node3D, ...] }
var _prefabs: Dictionary = {}    # { scene_path: PackedScene }
var _usage: Dictionary = {}      # { scene_path: int }
var _parent: Node = null         # куда добавлять объекты (опционально)

# ---------------------------
# Инициализация
# ---------------------------
func _init(parent: Node) -> void:
	_parent = parent

# ---------------------------
# Разогрев (создаёт заранее объекты)
# scenes_dict = { "res://scenes/enemy.tscn": 10, "res://scenes/effect.tscn": 5 }
# ---------------------------
func prewarm(scenes_dict: Dictionary) -> void:
	for scene_path in scenes_dict.keys():
		var count: int = int(scenes_dict[scene_path])
		if count <= 0:
			continue

		# Загружаем сцену, если ещё не загружена
		if not _prefabs.has(scene_path):
			var scene: PackedScene = load(scene_path)
			if not scene:
				push_error("ObjectPool: can't load scene at %s" % scene_path)
				continue
			_prefabs[scene_path] = scene
			_usage[scene_path] = 0
			_pools[scene_path] = []

		# Создаём N экземпляров
		var scene_ref: PackedScene = _prefabs[scene_path]
		for i in range(count):
			var node = scene_ref.instantiate() as Node3D
			if _parent:
				_parent.add_child(node)
			_disable(node)
			_pools[scene_path].append(node)

	print("ObjectPool: prewarmed %d scene types" % scenes_dict.size())

# ---------------------------
# Получить экземпляр
# ---------------------------
func get_instance(scene_path: String) -> Node3D:
	if scene_path == "":
		push_warning("ObjectPool: empty scene_path")
		return null

	if not _pools.has(scene_path):
		_pools[scene_path] = []
	if not _prefabs.has(scene_path):
		var scene: PackedScene = load(scene_path)
		if not scene:
			push_error("ObjectPool: can't load scene at %s" % scene_path)
			return null
		_prefabs[scene_path] = scene
		_usage[scene_path] = 0

	var pool = _pools[scene_path]
	var node: Node3D

	if pool.size() > 0:
		node = pool.pop_back()
	else:
		node = _prefabs[scene_path].instantiate()
		if _parent:
			_parent.add_child(node)

	_enable(node)
	_usage[scene_path] += 1
	return node

# ---------------------------
# Вернуть экземпляр в пул
# ---------------------------
func release_instance(scene_path: String, node: Node3D) -> void:
	if not is_instance_valid(node):
		return
	if not _pools.has(scene_path):
		_pools[scene_path] = []

	_disable(node)
	_pools[scene_path].append(node)
	_usage[scene_path] = max(0, _usage.get(scene_path, 0) - 1)

# ---------------------------
# Очистить все пулы
# ---------------------------
func clear_all() -> void:
	for arr in _pools.values():
		for node in arr:
			if is_instance_valid(node):
				node.queue_free()
	_pools.clear()
	_prefabs.clear()
	_usage.clear()

# ---------------------------
# Вспомогательные
# ---------------------------
func _disable(node: Node3D) -> void:
	node.visible = false
	node.process_mode = Node.PROCESS_MODE_DISABLED
	node.global_position = Vector3.ZERO

	if node.has_meta("shape_ref"):
		var shape = node.get_meta("shape_ref")
		if is_instance_valid(shape):
			shape.disabled = true

	if node.has_meta("anim_ref"):
		var anim = node.get_meta("anim_ref")
		if is_instance_valid(anim):
			anim.stop()

func _enable(node: Node3D) -> void:
	node.visible = true
	node.process_mode = Node.PROCESS_MODE_INHERIT

	if node.has_meta("shape_ref"):
		var shape = node.get_meta("shape_ref")
		if is_instance_valid(shape):
			shape.disabled = false

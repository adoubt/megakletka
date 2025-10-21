extends Node
class_name EnemyManager

@export var enemies_handler_path: NodePath
@export var initial_node_pool := 10

# Регистрируем типы врагов (ключ = тип, значение = EnemyData)
@export var enemies_tres: Dictionary = {
	"aboba": preload("uid://cm1r7mrmtqyc5"),
	 "fuflan" : preload("uid://dwoa40eyph4sc")
	
}

# ECS-данные
var enemies: Array[Enemy] = []
var enemy_nodes: Array[Node3D] = []

# Отдельные пулы по типам
var enemy_pools: Dictionary = {}  # ключ: String (тип), значение: Array[Node3D]
var enemy_killed : int= 0 
@onready var enemies_handler: Node3D = get_node(enemies_handler_path)
var _usage_stats := {}
# ---------------------------
# _ready: инициализация пулов
# ---------------------------
func _ready() -> void:
	# Инициализируем пулы для всех типов
	for enemy_name in enemies_tres.keys():
		enemy_pools[enemy_name] = []
		var data: EnemyData = enemies_tres[enemy_name]
		# в месте, где создаются ноды (ready)
		for i in range(initial_node_pool):
			var node = data.packed_scene.instantiate() as Node3D

			# кешируем shape
			var shape = node.find_child("Shape", true, false)
			if shape and shape is CollisionShape3D:
				node.set_meta("shape_ref", shape)

			# кешируем анимации (если есть)
			var anim = node.find_child("AnimationPlayer", true, false)
			if anim and anim is AnimationPlayer:
				node.set_meta("anim_ref", anim)

			
			enemies_handler.add_child(node)
			_disable_enemy_node(node)
			enemy_pools[enemy_name].append(node)

	add_to_group("enemy_manager")

# ---------------------------
# spawn_enemy: создать врага
# ---------------------------
func spawn_enemy(enemy_name: String, pos: Vector3) -> int:
	var data: EnemyData = enemies_tres.get(enemy_name)
	if not data:
		push_error("Unknown enemy type: " + enemy_name)
		return -1
	
	# создаём Enemy сущность
	var e = Enemy.new()
	
	e.init_from_data(data, pos)
	e.stats.current_hp = e.stats.max_hp
	enemies.append(e)

	# берём ноду из пула или создаём новую
	var pool = enemy_pools.get(enemy_name, [])
	var node: Node3D
	if pool.size() > 0:
		node = pool.pop_back()
	else:
		node = data.packed_scene.instantiate()
		enemies_handler.add_child(node)
	_enable_enemy_node(node)
	node.global_position = pos
	

	enemy_nodes.append(node)
	node.set_meta("entity_index", enemies.size() - 1)
	node.set_meta("enemy_name", enemy_name)
	_usage_stats[enemy_name] = _usage_stats.get(enemy_name, 0) + 1
	return enemies.size() - 1
	
# ---------------------------
# update: проверяем смерть
# ---------------------------
func update(_delta: float) -> void:
	for i in range(enemies.size() - 1, -1, -1):
		if not enemies[i].alive:
			handle_death_by_index(i)

# ---------------------------
# handle_death_by_index: убрать в пул
# ---------------------------
func handle_death_by_index(index: int) -> void:
	if index < 0 or index >= enemies.size():
		return

	var node_to_pool: Node3D = enemy_nodes[index]
	var enemy_name: String = node_to_pool.get_meta("enemy_name", "aboba")

	var last_idx = enemies.size() - 1
	if index != last_idx:
		enemies[index] = enemies[last_idx]
		enemy_nodes[index] = enemy_nodes[last_idx]
		var moved_node: Node3D = enemy_nodes[index]
		if is_instance_valid(moved_node):
			moved_node.set_meta("entity_index", index)
	
	enemies.pop_back()
	enemy_nodes.pop_back()
	enemy_killed +=1
	_usage_stats[enemy_name] = max(0, _usage_stats.get(enemy_name, 0) - 1)
	if is_instance_valid(node_to_pool):
		_disable_enemy_node(node_to_pool)
		node_to_pool.global_position = Vector3.ZERO
		if enemy_pools.has(enemy_name):
			enemy_pools[enemy_name].append(node_to_pool)
	

# Оптимизированные версии для пула врагов

func _disable_enemy_node(node: Node3D) -> void:
	node.visible = false
	node.global_rotation = Vector3.ZERO
	node.process_mode = Node.PROCESS_MODE_DISABLED

	# отключаем коллизию, если есть кешированная ссылка
	if node.has_meta("shape_ref"):
		var shape: CollisionShape3D = node.get_meta("shape_ref")
		if is_instance_valid(shape):
			shape.disabled = true

	# сброс визуальных/анимационных эффектов (если есть)
	if node.has_meta("anim_ref"):
		var anim: AnimationPlayer = node.get_meta("anim_ref")
		if is_instance_valid(anim):
			anim.stop()

	


func _enable_enemy_node(node: Node3D) -> void:
	node.visible = true
	node.process_mode = Node.PROCESS_MODE_INHERIT

	if node.has_meta("shape_ref"):
		var shape: CollisionShape3D = node.get_meta("shape_ref")
		if is_instance_valid(shape):
			shape.disabled = false


# ---------------------------
# Вспомогательные функции
# ---------------------------
func get_enemy_count() -> int:
	return enemies.size()

func get_enemy_node_by_index(i: int) -> Node3D:
	return enemy_nodes[i] if i >= 0 and i < enemy_nodes.size() else null

func get_enemy_index_for_node(node: Node) -> int:
	if not is_instance_valid(node):
		return -1
	return node.get_meta("entity_index") if node.has_meta("entity_index") else -1

func despawn_all() -> void:
	for node in enemy_nodes:
		if is_instance_valid(node):
			_disable_enemy_node(node)
			node.global_position = Vector3.ZERO
			var t = node.get_meta("enemy_type", "aboba")
			if enemy_pools.has(t):
				enemy_pools[t].append(node)
	enemies.clear()
	enemy_nodes.clear()

func _try_shrink_pools():
	for enemy_type in enemy_pools.keys():
		var active = _usage_stats.get(enemy_type, 0)
		var pool = enemy_pools[enemy_type]
		var target_size = clamp(int(active * 1.5), 100, 1000)
		while pool.size() > target_size:
			var node = pool.pop_back()
			if is_instance_valid(node):
				node.queue_free()

extends Node
class_name WeaponSystem

@export var projectiles_handler_path: NodePath = NodePath("../../Entities/Projectiles")
# Контейнер для визуалов снарядов (укажи в инспекторе или оставь путь по умолчанию)
@onready var projectiles_handler: Node3D = get_node_or_null(projectiles_handler_path)

# Активные снаряды
var active_projectiles: Array = []
@export var weapon_tres: Dictionary = {
	"Aura": preload("uid://dmc21j6xlk0a"),
	"Bone": preload("uid://dw8x6ls8m71sd")
}

func update(player: Entity, enemies: Array[Enemy], enemy_nodes: Array[Node3D], delta: float) -> void:
	# === Обновляем проджектайлы (итерируем по копии для безопасности при удалении) ===
	for p in active_projectiles.duplicate():
		# если нода уничтожена — удаляем запись
		if not is_instance_valid(p["node"]):
			active_projectiles.erase(p)
			continue
		_update_projectile(p, delta)

	# === Обработка оружий игрока ===
	for weapon in player.weapons:
		weapon.cooldown_timer = max(weapon.cooldown_timer - delta, 0.0)
		if weapon.cooldown_timer > 0.0:
			continue

		if weapon is AOEWeapon:
			_perform_aoe(weapon, player, enemies)
		elif weapon is ProjectileWeapon:
			_perform_projectile(weapon, player, enemies, enemy_nodes)
		elif weapon is MeleeWeapon:
			_perform_melee(weapon, player, enemies)

		weapon.cooldown_timer = weapon.stats.cooldown / max(player.stats.attack_speed, 0.001)
	


func _perform_aoe(weapon : Weapon, player :Entity, enemies : Array[Enemy]):

	for e in enemies:
		if not e.alive:
			continue
		if player.position.distance_to(e.position) <= weapon.radius * player.stats.size * weapon.stats.size:
			e.stats.current_hp -= weapon.stats.damage * player.stats.damage
			if e.stats.current_hp <= 0:
				e.alive = false
	

func _perform_melee(weapon, player, enemies):
	for e in enemies:
		if not e.alive:
			continue
		if player.position.distance_to(e.position) <= weapon.radius * player.stats.size * weapon.stats.size:
			e.stats.current_hp -=  weapon.stats.damage * player.stats.damage
			if e.stats.current_hp <= 0:
				e.alive = false


# -----------------------
# Projectile — безопасное создание визуала и запись в active_projectiles
# -----------------------
func _perform_projectile(weapon, player, enemies, enemy_nodes):
	var nearest_index := -1
	var nearest_dist := INF

	for i in enemies.size():
		var e = enemies[i]
		if not e.alive:
			continue
		var d = player.position.distance_to(e.position)
		if d < nearest_dist:
			nearest_dist = d
			nearest_index = i

	if nearest_index == -1:
		return

	var enemy = enemies[nearest_index]
	var enemy_node = enemy_nodes[nearest_index] if nearest_index < enemy_nodes.size() else null

	# --- instantiate ---
	var node = weapon.data.packed_scene.instantiate() as Node3D

	# 1) добавляем в контейнер первым делом (теперь node.is_inside_tree() станет true)
	projectiles_handler.add_child(node)
	

	# 2) устанавливаем глобальную позицию
	node.global_position = player.position

	# 3) ориентируем корректно: используем look_at_from_position (без требования быть в дереве)
	#    или, если node уже в дереве, можно вызвать normal look_at; здесь используем безопасный вариант
	var target_pos = enemy_node.global_position if is_instance_valid(enemy_node) else enemy.position
	node.look_at_from_position(node.global_position, target_pos, Vector3.UP)

	# 4) записываем в активные снаряды
	active_projectiles.append({
		"node": node,
		"target_entity": enemy,       # Entity (логика)
		"target_node": enemy_node,    # Node3D (визуал) — может быть null
		"speed": weapon.projectile_speed,
		"damage":weapon.stats.damage * player.stats.damage ,
		"duration": weapon.stats.duration
	})


# -----------------------
# Обновление одного проджектайла
# -----------------------
func _update_projectile(p:Dictionary, delta: float) -> void:
	var node : Node3D = p.get("node")
	var target_entity : Entity = p.get("target_entity", null)
	var target_node : Node3D = p.get("target_node", null)

	# безопасность
	if not is_instance_valid(node):
		# уже удалён
		if p in active_projectiles:
			active_projectiles.erase(p)
		return

	# если цель умерла — убираем визуал
	if target_entity == null or not target_entity.alive:
		_remove_projectile(p)
		return

	# получаем текущую цельную позицию (предпочтение — визуальная нода, если есть)
	var target_pos: Vector3
	if is_instance_valid(target_node):
		target_pos = target_node.global_position
	else:
		target_pos = target_entity.position

	var dir = target_pos - node.global_position
	var dist = dir.length()

	# попадание
	if dist <= 0.5:
		# наносим урон через Entity
		target_entity.stats.current_hp -= p["damage"]
		if target_entity.stats.current_hp <= 0:
			target_entity.alive = false
			# (вся логика смерти — в EnemyManager.handle_death_by_entity или другом)
		_remove_projectile(p)
		return

	# движение
	node.global_position += dir.normalized() * p["speed"] * delta

	# безопасная ориентация (look_at_from_position не требует, чтобы нода была в дереве)
	node.look_at_from_position(node.global_position, target_pos, Vector3.UP)

	# lifetime
	p["duration"] -= delta
	if p["duration"] <= 0.0:
		_remove_projectile(p)


# -----------------------
# Удаление проджектайла (безопасно)
# -----------------------
func _remove_projectile(p: Dictionary) -> void:
	if p in active_projectiles:
		var node = p.get("node", null)
		if is_instance_valid(node):
			# лучше clear visual (particles etc) и queue_free
			node.queue_free()
		active_projectiles.erase(p)

func equip(player: Entity, player_node: Node3D, weapon_name: String):
	var data: WeaponData = weapon_tres.get(weapon_name)
	if not data:
		push_error("Unknown weapon type: " + weapon_name)
		return -1
	
	var weapon: Weapon
	
	# создаём соответствующий класс по типу ресурса
	if data is ProjectileWeaponData:
		weapon = ProjectileWeapon.new()
	elif data is AOEWeaponData:
		weapon = AOEWeapon.new()
	elif data is MeleeWeaponData:
		weapon = MeleeWeapon.new()
	else:
		push_error("Unsupported weapon data type for: " + weapon_name)
		return -1

	# инициализация оружия из ресурса
	weapon.init_from_data(data)

	# добавляем в список игрока
	player.weapons.append(weapon)

	# создаём визуал оружия, если есть PackedScene
	if data.packed_scene:
		var instance: Node3D = data.packed_scene.instantiate()

		# определяем контейнер по типу оружия
		var container: Node = null
		if weapon is AOEWeapon:
			container = player_node.find_child("AOEContainer", true, false)
		elif weapon is MeleeWeapon:
			container = player_node.find_child("MeleeContainer", true, false)
		elif weapon is ProjectileWeapon:
			container = player_node.find_child("ProjectileContainer", true, false)

		# добавляем в контейнер
		if container:
			container.add_child(instance)
		else:
			player_node.add_child(instance)

		# сохраняем мету, чтобы потом обновлять, прятать и т.д.
		weapon.set_meta("instance", instance)
	
	return weapon


func unequip(player: Entity, player_node: Node3D, weapon: Weapon):
	if not player.weapons.has(weapon):
		push_warning("Tried to unequip weapon not owned by player: %s" % weapon.name)
		return
	
	# 1. Убираем из списка оружий игрока
	player.weapons.erase(weapon)
	
	# 2. Удаляем визуал, если он существует
	if weapon.has_meta("instance"):
		var inst = weapon.get_meta("instance")
		if is_instance_valid(inst):
			inst.queue_free()
		weapon.set_meta("instance", null)
	
	# 3. (опционально) очищаем контейнер, если нужно полностью сбросить сцену
	var container: Node = null
	if weapon is AOEWeapon:
		container = player_node.find_child("AOEContainer", true, false)
	elif weapon is MeleeWeapon:
		container = player_node.find_child("MeleeContainer", true, false)
	elif weapon is ProjectileWeapon:
		container = player_node.find_child("ProjectileContainer", true, false)

	if container:
		# Просто для надёжности — чистим все "осиротевшие" инстансы
		for child in container.get_children():
			if not is_instance_valid(child):
				continue
			# Можно точнее проверять по имени
			if child.name == weapon.name:
				child.queue_free()

	

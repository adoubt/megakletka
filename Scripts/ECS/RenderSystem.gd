extends Node
class_name RenderSystem

var _time_accum := 0.0
var _last_sizes := {}  # { weapon_id: float }
@export var size_update_interval_sec := 1.0  # обновляем раз в 1 секунду
@export var size_lerp_speed := 15.0
@export var smoothness := 5.0 # чем больше, тем быстрее догоняет (в кадрах/сек)
func update(player_entity: Entity, player_node: Node3D, enemies: Array[Enemy], enemy_nodes: Array[Node3D],delta):
	# Обновляем позицию игрока
	if is_instance_valid(player_node):
		player_entity.position = player_node.global_position

	# Обновляем позиции врагов
	for i in range(enemies.size()):
		var entity = enemies[i]
		var node = enemy_nodes[i]

		#if not entity.alive:
			#node.visible = false
			#continue

		node.visible = true
		#node.global_position = entity.position
		node.global_position = node.global_position.lerp(entity.position, clamp(delta * smoothness, 0, 1))
		# (если хочешь — пусть враги поворачиваются к игроку)
		node.look_at(player_node.global_position)
		node.rotate_y(PI)
		# 2️⃣ Обновляем визуал оружия (раз в N секунд)
		_time_accum += delta
		if _time_accum >= size_update_interval_sec:
			_time_accum = 0.0
			_update_target_sizes(player_entity)

		_interpolate_sizes(delta)
	 

 
func _update_target_sizes(player: Entity):
	for weapon in player.weapons:
		if not weapon.has_meta("instance") or weapon is ProjectileWeapon:
			continue
		var node: Node3D = weapon.get_meta("instance")
		if not is_instance_valid(node):
			continue
		_last_sizes[weapon] = player.stats.size * weapon.stats.size


func _interpolate_sizes(delta: float):
	for weapon in _last_sizes.keys():
		if not weapon.has_meta("instance"):
			continue
		var node: Node3D = weapon.get_meta("instance")
		if not is_instance_valid(node):
			continue
		var target_scale = Vector3.ONE * _last_sizes[weapon]
		node.scale = node.scale.lerp(target_scale, clamp(delta * size_lerp_speed, 0, 1))

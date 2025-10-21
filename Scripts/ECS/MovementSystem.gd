extends Node3D
class_name MovementSystem

@export var climb_check_distance := 1.0
@export var climb_check_height_offset := 0.2
@export var climb_speed := 2.0
@export var ground_mask := (1 << 0) | (1 << 1) | (1 << 2)
@export var min_distance_to_climb := 1.5 # не карабкаемся, если слишком близко
@export var knockback_distance := 5.0 # на сколько "откидывает"
@export var knockback_trigger_distance := 0.5 # ближе этого – откидывает

func update(player: Entity, enemies: Array[Enemy], delta: float):
	var space_state = get_world_3d().direct_space_state

	for enemy in enemies:
		if not enemy.alive:
			continue

		var dir = (player.position - enemy.position)
		var dist = dir.length()
		var dir_norm = dir.normalized()

		# 1️⃣ Откидывание при слишком близкой дистанции
		if dist < knockback_trigger_distance:
			var push_dir = -dir_norm # направление от игрока
			enemy.position += push_dir * knockback_distance
			continue # пропускаем остальную логику, чтобы не шёл сразу обратно

		# 2️⃣ Если просто близко — идём без карабканья
		if dist < min_distance_to_climb:
			enemy.position += dir_norm * enemy.stats.movement_speed * delta
			continue

		# 3️⃣ Проверка на стену
		var origin = enemy.position + Vector3.UP * climb_check_height_offset
		var target = origin + dir_norm * climb_check_distance

		var query = PhysicsRayQueryParameters3D.create(origin, target)
		query.collision_mask = ground_mask
		var result = space_state.intersect_ray(query)

		if result:
			var normal: Vector3 = result.normal
			if abs(normal.y) < 0.3:
				enemy.position.y += climb_speed * delta
			else:
				enemy.position += dir_norm * enemy.stats.movement_speed * delta
		else:
			enemy.position += dir_norm * enemy.stats.movement_speed * delta

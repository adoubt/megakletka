extends Node
class_name ProjectileSystem

# Зависимости: enemy_manager и vfx_system передаются снаружи
var enemy_manager: EnemyManager
var vfx_system: VFXSystem

func process(delta: float, proj_mgr: ProjectileManager, enemies: Array, player_entity: Entity) -> void:
	var n = proj_mgr.start_positions.size()
	for i in range(n):
		if i >= proj_mgr.active.size():
			continue
		if proj_mgr.active[i] == 0:
			continue

		# обновляем время
		proj_mgr.elapsed_times[i] += delta
		var t := proj_mgr.elapsed_times[i] / max(proj_mgr.durations[i], 0.0001)

		# вычисляем текущее положение линейной интерполяцией start -> target(current pos)
		var start_pos: Vector3 = proj_mgr.start_positions[i]
		var target_idx: int = proj_mgr.target_indices[i]
		# если цель умерла или индекс невалиден — помечаем projectile мёртвым
		if target_idx < 0 or target_idx >= enemies.size() or not enemies[target_idx].alive:
			# можно чекнуть nearest или просто убить
			proj_mgr.active[i] = 0
			continue

		var target_pos: Vector3 = enemies[target_idx].position
		var current_pos = start_pos.lerp(target_pos, clamp(t, 0.0, 1.0))

		# столкновение (по достижению t >= 1)
		if proj_mgr.elapsed_times[i] >= proj_mgr.durations[i]:
			# нанести урон цельному врагу
			var enemy = enemies[target_idx]
			if enemy.alive:
				enemy.stats.current_hp -= proj_mgr.damages[i]
				if vfx_system:
					vfx_system.spawn_hit_effect(target_pos)
				if enemy.stats.current_hp <= 0:
					enemy.alive = false
					if vfx_system:
						vfx_system.spawn_death_effect(target_pos)

			# завершить projectile
			proj_mgr.active[i] = 0

extends Node
class_name CombatSystem


@onready var vfx_system: VFXSystem = $VFXSystem

func update(player: Entity, enemies: Array[Enemy], delta: float):
	for enemy in enemies:
		if not enemy.alive:
			continue

		# Обновляем кулдаун
		enemy.stats.cooldown_timer = max(enemy.stats.cooldown_timer - delta, 0.0)
		
		# Враг атакует игрока
		if enemy.stats.cooldown_timer <= 0.0 and enemy.position.distance_to(player.position) <= enemy.stats.attack_range:
			player.stats.current_hp -= enemy.stats.damage
			enemy.stats.cooldown_timer = enemy.stats.attack_cooldown

			if vfx_system:
				vfx_system.spawn_hit_effect(player.position)

	# Проверяем смерть игрока
	if player.stats.current_hp <= 0 and player.alive:
		player.alive = false
		if vfx_system:
			vfx_system.spawn_death_effect(player.position)

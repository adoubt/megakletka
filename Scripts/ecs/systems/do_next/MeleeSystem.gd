extends BaseSystem
class_name MeleeSystem

func update(delta):
	for entity_id in entity_manager.get_entities_with("MeleeWeaponComponent", "TransformComponent"):
		var melee = component_store.get_component(entity_id, "MeleeWeaponComponent")
		var transform = component_store.get_component(entity_id, "TransformComponent")

		melee.time_since_attack += delta

		if melee.is_aura:
			# Аура бьёт постоянно
			_apply_damage_in_radius(entity_id, transform.position, melee.range, melee.damage * delta)
		elif melee.time_since_attack >= melee.cooldown:
			# Совершить удар
			_apply_melee_strike(entity_id, transform, melee)
			melee.time_since_attack = 0.0


func _apply_melee_strike(owner_id, transform, melee):
	var enemies = entity_manager.get_entities_with("StatsComponent", "TransformComponent")
	for enemy_id in enemies:
		if enemy_id == owner_id:
			continue

		var enemy_transform = component_store.get_component(enemy_id, "TransformComponent")
		var to_enemy = enemy_transform.position - transform.position
		var distance = to_enemy.length()

		if distance <= melee.range:
			# Проверяем угол удара
			var forward = transform.forward.normalized()
			if rad_to_deg(forward.angle_to(to_enemy.normalized())) <= melee.attack_angle / 2.0:
				_create_damage_event(owner_id, enemy_id, melee.damage)


func _apply_damage_in_radius(owner_id, position, radius, damage):
	for enemy_id in entity_manager.get_entities_with("StatsComponent", "TransformComponent"):
		if enemy_id == owner_id:
			continue
		var enemy_transform = component_store.get_component(enemy_id, "TransformComponent")
		if enemy_transform.position.distance_to(position) <= radius:
			_create_damage_event(owner_id, enemy_id, damage)


func _create_damage_event(source_id, target_id, amount):
	var damage_event = {
		"source": source_id,
		"target": target_id,
		"amount": amount
	}
	component_store.add_component(target_id, "PendingDamage", damage_event)

extends BaseSystem
class_name WeaponSystem

func update(delta: float) -> void:
	var entities = get_entities_with("WeaponComponent", "TransformComponent") # или TransformComponent

	for entity_id in entities:
		var weapon = component_store.get_component(entity_id, "WeaponComponent")
		if weapon == null:
			continue
		
		# Обновляем таймер
		weapon.timer -= delta
		if weapon.timer > 0.0:
			continue
		
		# Вызываем атаку
		match weapon.type:
			WeaponComponent.WeaponType.MELEE:
				_process_melee(entity_id, weapon)
			WeaponComponent.WeaponType.RANGED:
				_process_ranged(entity_id, weapon)
			WeaponComponent.WeaponType.AURA:
				_process_aura(entity_id, weapon)
			WeaponComponent.WeaponType.SPINNING:
				_process_spinning(entity_id, weapon)
		
		# Сбрасываем таймер
		weapon.timer = weapon.cooldown

# --------------------
func _process_melee(entity_id: int, weapon: WeaponComponent) -> void:
	# Ищем врагов в радиусе melee, наносим урон
	var targets = get_entities_in_radius(entity_id, 50) # пример
	for target_id in targets:
		_apply_damage(target_id, weapon.damage)

func _process_ranged(entity_id: int, weapon: WeaponComponent) -> void:
	# Создаём снаряд
	pass
	#spawn_projectile(weapon.projectile_scene, entity_id, weapon.damage)

func _process_aura(entity_id: int, weapon: WeaponComponent) -> void:
	# Все враги вокруг в radius получают урон
	var targets = get_entities_in_radius(entity_id, weapon.radius)
	for target_id in targets:
		_apply_damage(target_id, weapon.damage)

func _process_spinning(entity_id: int, weapon: WeaponComponent) -> void:
	# Вращающиеся топоры или объекты вокруг игрока
	var targets = get_entities_in_radius(entity_id, weapon.radius)
	for target_id in targets:
		_apply_damage(target_id, weapon.damage)
	# Можно анимировать вращение через weapon.speed

# --------------------
func _apply_damage(target_id: int, amount: float) -> void:
	var damage_component = {
		"amount": amount
	}
	component_store.add_component(target_id, "PendingDamageComponent", damage_component)

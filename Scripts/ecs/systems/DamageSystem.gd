# res://ecs/systems/DamageSystem.gd
extends BaseSystem
class_name DamageSystem

func update() -> void:
	# Берём все сущности, у которых есть HealthComponent и DamageComponent
	var entities = get_entities_with("HealthComponent", "PendingDamageComponent")
	
	for entity_id in entities:
		var health = component_store.get_component(entity_id, "HealthComponent")
		var damage = component_store.get_component(entity_id, "PendingDamageComponent")
		if damage == null:
			continue
		# Применяем урон
		health.current_hp  = _calculate_health_after_damage(health.current_hp, damage.amount , health.max_hp)
		
		# После применения урона можно удалить компонент
		component_store.remove_component(entity_id, "PendingDamageComponent")

func _calculate_health_after_damage(current_hp : float, damage :float, max_hp :float) -> float:
	if max_hp <= 0.0: return 0.0
	if damage <= 0.0: return current_hp
	if current_hp <= 0.0: return 0.0
	return clampf(current_hp - damage, 0.0, max_hp)

extends BaseSystem
class_name DamageSystem

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,  _event_bus: EventBus,):
	super._init(_entity_manager, _component_store, _event_bus)
	
	arch = cs.register_archetype(["PendingDamageComponent", "ArmorComponent"], ["DeadComponent"])
	
func update(_delta: float) -> void:
	var entities = arch.entities.duplicate()
	for target_id in entities:
		var pd: PendingDamageComponent = cs.get_component(target_id, "PendingDamageComponent")
		var source_id: int = pd.source_id

		if pd.execute_chance > 0.0 and randf() < pd.execute_chance:
			cs.add_component(
				target_id,
				"DeathRequestComponent",
				DeathRequestComponent.new(source_id)
			)
			cs.remove_component(target_id, "PendingDamageComponent")
			continue

		# =========================
		# ARMOR
		# =========================
		var armor_value := 0.0
		var armor_comp := cs.get_component(target_id, "ArmorComponent")
		if armor_comp != null:
			armor_value = armor_comp.final_value

		var raw_damage :float = max(pd.amount, 0.0)
		var final_damage := apply_armor(raw_damage, armor_value)

		if final_damage > 0.0:
			cs.add_component(
				target_id,
				"HPChangeRequestComponent",
				HPChangeRequestComponent.new(-final_damage, source_id)
			)

		cs.remove_component(target_id, "PendingDamageComponent")


# =========================
# ARMOR FORMULA (Dota-like)
# =========================
func apply_armor(damage: float, armor: float) -> float:
	var k := 0.12
	var multiplier :float = 1.0 - (k * armor) / (1.0 + k * abs(armor))
	multiplier = clamp(multiplier, 0.15, 2.5)
	return damage * multiplier

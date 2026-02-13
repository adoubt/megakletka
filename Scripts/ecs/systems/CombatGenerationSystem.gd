extends BaseSystem
class_name CombatGenerationSystem

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,  _event_bus: EventBus,):
	super._init(_entity_manager, _component_store, _event_bus)


	arch = cs.register_archetype(["DayComponent","CombatGenerationRequestComponent",])

func update(_delta:float) -> void:
	if arch.entities.is_empty():
		return
	var entities = arch.entities.duplicate()
	for e in entities:
		cs.add_component(e, "CombatStateComponent",CombatStateComponent.new())
		cs.add_component(e, "ButteryComponent", BatteryComponent.new())
		cs.remove_component(e, "CombatGenerationRequestComponent")
		
func _spawn_combat(day_entity, day, ante):
	var budget := int(
		50 *
		(1.0 + day * 0.12) *
		(1.0 + ante * 0.3)
	)

	cs.add_component(day_entity, "CombatStateComponent", CombatStateComponent.new())
	cs.add_component(day_entity, "BatteryComponent", BatteryComponent.new(budget))
	cs.add_component(day_entity, "CombatRewardComponent", CombatRewardComponent.new(6))

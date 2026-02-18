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
		var day_comp = cs.get_component(e,"DayComponent")
		
		_spawn_combat(e,day_comp)
		cs.remove_component(e, "CombatGenerationRequestComponent")
		
func _spawn_combat(day_entity, day_comp):
	var _floor:int = day_comp.floor
	var ante = day_comp.ante
	var type = day_comp.type
	var budget := int(
		50 *
		(1.0 + _floor * 0.12) *
		(1.0 + ante * 0.3)
	)
	var combat_state:= CombatStateComponent.new()
	match type:
		DayType.BOSS:
			combat_state.win_condition = CombatState.WinCondition.KILL_ALL
			
		DayType.ELITE:
			combat_state.win_condition = CombatState.WinCondition.KILL_ALL | CombatState.WinCondition.TIME
			combat_state.time_left = 45.0
		DayType.ENEMY:
			combat_state.win_condition = CombatState.WinCondition.KILL_ALL | CombatState.WinCondition.TIME
			combat_state.time_left = 30.0
	
	cs.add_component(day_entity, "CombatStateComponent", combat_state)
	cs.add_component(day_entity, "BatteryComponent", BatteryComponent.new(budget))
	cs.add_component(day_entity, "CombatRewardComponent", CombatRewardComponent.new(100))

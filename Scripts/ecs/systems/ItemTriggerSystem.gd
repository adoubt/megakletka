extends BaseSystem
class_name ItemTriggerSystem

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_event_bus : EventBus,): 
	super._init(_entity_manager,_component_store,_event_bus)
	
	arch = cs.register_archetype(["ItemAbilityComponent", "TriggerComponent"])
	
	for e in AbilityTriggers.Events.values():
		var event_str:String = AbilityTriggers.event_to_string(e)
		event_bus.subscribe(event_str, func(data): _on_game_event(e, data))

		
func _on_game_event(event_id: int, data: Dictionary) -> void:
	_process_triggers(event_id, data)
	
func _process_triggers(event_id: int, data: Dictionary) -> void:
	var abilities = arch.entities.duplicate()
	for e in abilities:
		var trigger := cs.get_component(e, "TriggerComponent")
		if trigger.event != event_id:
			continue

		var ability := cs.get_component(e, "ItemAbilityComponent")
		var modifier := cs.get_component(e, "StatModifierComponent")
		_apply_trigger_action(e, trigger, ability,modifier)
		
func _apply_trigger_action(
	item_e: int,
	trigger: TriggerComponent,
	ability: ItemAbilityComponent,
	modifier: StatModifierComponent
) -> void:
	match trigger.action:

		AbilityTriggers.Actions.GAIN_VALUE:
			modifier.base_value += trigger.value
			print(modifier.base_value)
		AbilityTriggers.Actions.SET_VALUE:
			modifier.base_value = trigger.value

		AbilityTriggers.Actions.ADD_JUMP:
			_emit_stat_change(item_e, Stats.PlayerStats.JUMPS_COUNT, trigger.value)

		_:
			push_warning("Unknown trigger action")
			
func _emit_stat_change(item_e: int, stat: int, value: float):
		pass

extends BaseSystem

class_name ModifierTriggerSystem
var mod_arch :Archetype
var item_arch: Archetype
func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_event_bus : EventBus,): 
	super._init(_entity_manager,_component_store,_event_bus)
	item_arch = cs.register_archetype(["ItemComponent"],["DeadComponent"])
	mod_arch = cs.register_archetype(["ModifierComponent", "TriggerComponent"], ["DeadComponent"])
	arch = cs.register_archetype(["TriggerEventComponent"],["DeadComponent"])

func update(_delta:float):
	if arch.entities.is_empty():
		return
	var entities := arch.entities.duplicate()
	for e in entities:
		var event := cs.get_component(e, "TriggerEventComponent")
		
		_process_triggers(event.owner_id,event.event_id,event.payload)
		cs.add_component(e, "DeadComponent", DeadComponent.new())
		
func _process_triggers(owner_id:int,event_id: int, payload:Dictionary) -> void:
	
	for e in mod_arch.entities:
		var modifier := cs.get_component(e, "ModifierComponent")
		
		
		var trigger := cs.get_component(e, "TriggerComponent")
		if trigger.event != event_id:
			continue
		if modifier.stat == Stats.PlayerStats.COST:
			if owner_id != cs.get_component(modifier.target_id, "ItemComponent").owner_id:
				continue
		else:
			if modifier.target_id != owner_id:
				continue
		match event_id:
			AbilityTriggers.Events.USED:
				var item_id:int = payload.item_id
				if item_id != cs.get_component(modifier.source_id, "ItemAbilityComponent").owner_id:
					continue
				event_bus.emit("item_used",{"item_id":item_id, "source_id":owner_id})
				
		_apply_trigger_action( trigger, modifier)
		
func _apply_trigger_action(
	trigger: TriggerComponent,
	modifier: ModifierComponent
) -> void:
	match trigger.action:

		AbilityTriggers.Actions.GAIN_VALUE:
			modifier.value += trigger.value
			cs.get_component(modifier.source_id, "StatModifierComponent").value = modifier.value
			var item_id = cs.get_component(modifier.source_id, "ItemAbilityComponent").owner_id
			cs.add_component(item_id, "DirtyStatsComponent", DirtyStatsComponent.new())
		AbilityTriggers.Actions.SET_VALUE:
			modifier.base_value = trigger.value
			
		AbilityTriggers.Actions.ADD_JUMP:
			pass
		AbilityTriggers.Actions.ADD_GOLD:
			cs.add_component(RUN, "BalanceChangeRequestComponent", BalanceChangeRequestComponent.new(int(trigger.value), "item_ability",modifier.source_id))
		AbilityTriggers.Actions.GAMBLE_FOX:
			_gamble1(modifier.target_id)
		_:
			push_warning("Unknown trigger action")
			
		
	cs.add_component(modifier.target_id,"DirtyStatsComponent", DirtyStatsComponent.new())	


func _gamble1(target_id:int) -> void:
	var items_count: int
	var items_for_entity:=[]
	for item in item_arch.entities:
		if cs.get_component(item, "ItemComponent").owner_id == target_id:
			items_for_entity.append(item)
	items_count = items_for_entity.size()
	if items_count<=0:
		return
	var chosen_item = items_for_entity.pick_random()
	var cost_comp := cs.get_component(chosen_item, "CostComponent")
	var new_value = cost_comp.base_value * items_count
	cost_comp.base_value = new_value
	cs.add_component(chosen_item, "DirtyStatsComponent", DirtyStatsComponent.new())
	cs.add_component(chosen_item, "SellRequestComponent",SellRequestComponent.new())

extends BaseSystem
class_name ItemTransactionSystem

var stat_mod_arch: Archetype
var ability_arch: Archetype
var item_arch: Archetype
func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus ):
	super._init(_entity_manager, _component_store, _event_bus)
	
	arch = cs.register_archetype(["ItemTransactionComponent", "ItemComponent",],["DeadComponent"])
	ability_arch = cs.register_archetype(["ItemAbilityComponent"])
	stat_mod_arch = cs.register_archetype([ "ModifierComponent"],["DeadComponent"])
	
	item_arch = cs.register_archetype(["ItemComponent"],["DeadComponent"])
	
func update(_delta: float) -> void:
	var entities = arch.entities.duplicate()
	for e in entities:
		var transaction = cs.get_component(e, "ItemTransactionComponent")
		var target_id = transaction.target_id
		var source_id = transaction.source_id
		var item_comp = cs.get_component(e, "ItemComponent")
		if source_id not in [-1, RUN]:
			_on_item_unequipped(e, source_id, item_comp.slot_mask) 
			cs.add_component(source_id, "UsedSlotsRecalculateRequestComponent", UsedSlotsRecalculateRequestComponent.new())
		
		cs.add_component(e, "AnimationComponent", AnimationComponent.new(AnimationType.FLOAT))
				
		var target_slot_mask :int =-1
		
		if cs.get_component(target_id, "PlayerComponent"):
			target_slot_mask = SlotMask.PLAYER
			
		elif cs.has_component(target_id, "POIComponent"):
			var poi_comp = cs.get_component(target_id,"POIComponent")
			match poi_comp.name:
				"merchant": target_slot_mask = SlotMask.MERCHANT
				"campfire": target_slot_mask = SlotMask.CAMPFIRE
				
		if target_slot_mask ==-1:
			printerr("ItemTransactionSystem. POI Name fornot found. target_slot_mask not found. Transaction can not be done")
			continue
		item_comp.owner_id = target_id
		item_comp.slot_mask = target_slot_mask
			
		item_comp.slot_index = transaction.slot_index if transaction.slot_index!= -1 else _get_valid_slot_index(target_id)
		
		
		
		
		_on_item_equipped(e, target_id,item_comp.slot_mask)
		

		cs.remove_component(e, "ItemTransactionComponent")
		
func _on_item_equipped(item_id:int, owner_id:int, slot_mask:int) -> void:
	cs.add_component(owner_id, "UsedSlotsRecalculateRequestComponent",
		UsedSlotsRecalculateRequestComponent.new())
	cs.add_component(owner_id, "DirtyStatsComponent", DirtyStatsComponent.new())
	cs.add_component(item_id,"ItemPlacementRequestComponent", ItemPlacementRequestComponent.new())
	if (slot_mask & (SlotMask.PLAYER | SlotMask.CAMPFIRE)) == 0:
		return
	for ability_e in ability_arch.entities:
		var ability_comp := cs.get_component(ability_e, "ItemAbilityComponent")
		if ability_comp.owner_id != item_id:
			continue
	
		
		var stat_mod = cs.get_component(ability_e, "StatModifierComponent")
		if not stat_mod:
			return
		
		var mod_e := em.create_entity()
		var mod = ModifierComponent.new(
			ability_e, owner_id, stat_mod.stat, stat_mod.domain, stat_mod.value)
		cs.add_component(mod_e, "ModifierComponent", mod)
		
		var condition := cs.get_component(ability_e, "ConditionComponent")
		if condition != null:
			var new_comp := ConditionComponent.new()
			new_comp.type = condition.type
			new_comp.source = condition.source
			new_comp.domain = condition.domain
			new_comp.value = condition.value
			cs.add_component(mod_e, "ConditionComponent", new_comp)


		var scaling := cs.get_component(ability_e, "ScalingComponent")
		if scaling != null:
			var new_scaling := ScalingComponent.new()
			new_scaling.per = scaling.per
			new_scaling.source = scaling.source
			new_scaling.domain = scaling.domain
			cs.add_component(mod_e, "ScalingComponent", new_scaling)

		var trigger := cs.get_component(ability_e, "TriggerComponent")
		if trigger != null:
			var new_trigger := TriggerComponent.new()
			new_trigger.event = trigger.event
			new_trigger.action = trigger.action
			new_trigger.value = trigger.value
			cs.add_component(mod_e, "TriggerComponent", new_trigger)


func _on_item_unequipped(item_id:int, owner_id:int, slot_mask:int) -> void:
	cs.add_component(owner_id, "UsedSlotsRecalculateRequestComponent",
		UsedSlotsRecalculateRequestComponent.new())
	cs.add_component(owner_id, "DirtyStatsComponent", DirtyStatsComponent.new())
	for mod_e in stat_mod_arch.entities:
		var mod := cs.get_component(mod_e, "ModifierComponent")
		if mod == null:
			continue

		var ability_e :int= mod.source_id
		var ability_comp := cs.get_component(ability_e, "ItemAbilityComponent")
		if ability_comp == null:
			continue

		if ability_comp.owner_id == item_id:
			cs.add_component(mod_e, "DeadComponent", DeadComponent.new(0.0))

func _get_valid_slot_index(owner_id: int) -> int:
	var used := {}


	for e in item_arch.entities:
		var item := cs.get_component(e, "ItemComponent")
		if item == null:
			continue
		if item.owner_id != owner_id:
			continue

		used[item.slot_index] = true

	var index := 0
	while used.has(index):
		index += 1

	return index

		

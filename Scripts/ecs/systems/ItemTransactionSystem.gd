extends BaseSystem
class_name ItemTransactionSystem

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus ):
	super._init(_entity_manager, _component_store, _event_bus)
	
	arch = cs.register_archetype(["ItemTransactionComponent", "ItemComponent", "FollowOwnerComponent"],["DeadComponent"])
	
func update(_delta: float) -> void:
	var entities = arch.entities.duplicate()
	for e in entities:
		var transaction = cs.get_component(e, "ItemTransactionComponent")
		var target_id = transaction.target_id
		var source_id = transaction.source_id
		var item_comp = cs.get_component(e, "ItemComponent")
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
		item_comp.slot_index = transaction.slot_index
		var follow_comp = cs.get_component(e, "FollowOwnerComponent")
		follow_comp.owner_id = target_id
		if target_slot_mask == SlotMask.PLAYER:
			follow_comp.weight = 1.0
		else: follow_comp.weight = 0.1 
		cs.add_component(target_id, "EmptySlotsRecalculateRequestComponent",
		EmptySlotsRecalculateRequestComponent.new())
		cs.add_component(source_id, "EmptySlotsRecalculateRequestComponent",
		EmptySlotsRecalculateRequestComponent.new())
		cs.remove_component(e, "ItemTransactionComponent")

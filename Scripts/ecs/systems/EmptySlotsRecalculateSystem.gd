extends BaseSystem
class_name EmptySlotsRecalculateSystem

var item_arch: Archetype
func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus):
	super._init( _entity_manager, _component_store, _event_bus)
	item_arch = cs.register_archetype(["ItemComponent"])
	arch = cs.register_archetype(["EmptySlotsRecalculateRequestComponent", "EmptySlotsCountComponent", "SlotsCountComponent"])
func update(_delta:float) -> void:
	var entities = arch.entities.duplicate()
	for e in entities:
		var found_items: int = 0
		var slots = cs.get_component(e,"SlotsCountComponent")
		var empty_slots = cs.get_component(e, "EmptySlotsCountComponent")
		for item_id in item_arch.entities:
			var item_comp = cs.get_component(item_id, "ItemComponent")
			
			if item_comp.owner_id == e:
				found_items +=1
		empty_slots.base_value = slots.base_value - found_items			
		print("Items for ",e," ",found_items," / ", slots.base_value )
		cs.add_component(e,"DirtyStatsComponent", DirtyStatsComponent.new())
		cs.remove_component(e,"EmptySlotsRecalculateRequestComponent")

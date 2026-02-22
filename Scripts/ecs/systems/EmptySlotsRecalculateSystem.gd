extends BaseSystem
class_name UsedSlotsRecalculateSystem

var item_arch: Archetype
func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus):
	super._init( _entity_manager, _component_store, _event_bus)
	item_arch = cs.register_archetype(["ItemComponent"])
	arch = cs.register_archetype(["UsedSlotsRecalculateRequestComponent","SlotsCountComponent","UsedSlotsCountComponent"])
func update(_delta: float) -> void:
	var entities = arch.entities.duplicate()

	for e in entities:
		var slots_count: = int(cs.get_component(e, "SlotsCountComponent").base_value)
		var used_slots = cs.get_component(e, "UsedSlotsCountComponent")

		var occupied := {}
		var count := 0
		
		for item_id in item_arch.entities:
			var item = cs.get_component(item_id, "ItemComponent")
			if item.owner_id == e and item.slot_index >= 0:
				occupied[item.slot_index] = true
				count += 1
				
		used_slots.base_value = count

		# формируем массив состояний для визуала
		var slot_states: Array = []
		slot_states.resize(slots_count)

		for i in slots_count:
			slot_states[i] = not occupied.has(i)
		
		var poi = cs.get_component(e, "POIComponent")

		if (poi and poi.name == "campfire") or cs.has_component(e, "PlayerComponent"):
			cs.add_component(
				e,
				"SlotsViewBuilderRequestComponent",
				SlotsViewBuilderRequestComponent.new(slot_states)
			)
		
		cs.remove_component(e, "UsedSlotsRecalculateRequestComponent")

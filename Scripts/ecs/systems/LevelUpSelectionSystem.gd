extends BaseSystem
class_name LevelUpSelectionSystem



func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store,_event_bus)
	
	arch = cs.register_archetype(["LevelUpOfferComponent"])	
func update(_delta: float) -> void:
	var entities = arch.entities.duplicate()
	for e_id in entities:
		var offer = cs.get_component(e_id, "LevelUpOfferComponent")

		match offer.chosen_index:
			-1:
				UIManager.hud.has_upgrade = true
				continue  # Waiting for the choise
			-2:
				# Reroll
				cs.remove_component(e_id, "LevelUpOfferComponent")
				continue
			_:
				# Upgrade Chosen
				 
				cs.get_component(offer.owner_id, "LevelPointsCountComponent").base_value -= 1
				UIManager.hud.has_upgrade = false
				
				event_bus.emit("create_item", [{ "item_id": offer.choices[offer.chosen_index],
				"owner_id": offer.owner_id
				}])
				var instance = cs.get_component(offer.owner_id, "RenderComponent").instance
				if instance: instance.hide_level_up()	
				
				cs.remove_component(e_id, "LevelUpOfferComponent")
				cs.remove_component(offer.owner_id, "ActiveOfferComponent")
				em.destroy_entity(e_id)

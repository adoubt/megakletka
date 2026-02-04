extends BaseSystem
class_name Interactionsystem

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store,_event_bus)
	
	arch = cs.register_archetype(["PlayerComponent","InputComponent", "InRangeInteractionComponent"],["DeadComponent"])
	
func update(_delta: float) -> void:
	var entities = arch.entities.duplicate()
	for player_id in entities:	

		var input = cs.get_component(player_id, "InputComponent")
		
		var inter = cs.get_component(player_id, "InRangeInteractionComponent")
		
				
		if input.interact_pressed and inter.target_id != -1:
			inter.is_interacting = true
			inter.progress = 0.0

		if inter.is_interacting and input.interact_held:
			inter.progress += _delta

			if inter.progress >= inter.interact_time:
				event_bus.emit("poi_interacted", {
					"poi_id": inter.target_id,
					"player_id": player_id,
					"type": "hold"
				})
				inter.is_interacting = false
				inter.progress = 0.0

		elif input.interact_released and inter.target_id != -1 and inter.is_interacting:
			event_bus.emit("poi_interacted", {
				"poi_id": inter.target_id,
				"player_id": player_id,
				"type": "tap"
			})
			inter.is_interacting = false
			inter.progress = 0.0

	

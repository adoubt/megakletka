extends BaseSystem
class_name JumpSystem

func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus,):
	super._init( _entity_manager, _component_store, _event_bus)
	arch = cs.register_archetype([
		"InputComponent",
		"TransformComponent",
		"JumpsLeftComponent",
		"JumpHeightComponent"
	])
func update(_delta):
	

	for e in arch.entities:
		var input := cs.get_component(e, "InputComponent")
		var tf := cs.get_component(e, "TransformComponent")
		var jump_left:= cs.get_component(e, "JumpsLeftComponent")
		var height = cs.get_component(e, "JumpHeightComponent").final_value
		if input.jump and jump_left.base_value > 0:
			tf.velocity.y = height
			tf.grounded = false
			jump_left.base_value -= 1
			cs.add_component(e, "DirtyStatsComponent", DirtyStatsComponent.new())
			event_bus.emit("jumped", {"entity":e})

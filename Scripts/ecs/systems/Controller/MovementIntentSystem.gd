extends BaseSystem
class_name MovementIntentSystem

func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus,):
	super._init( _entity_manager, _component_store, _event_bus)
	arch = cs.register_archetype([
		"TransformComponent",
		"MovementIntentComponent"
	])
func update(_delta):
	

	for e in arch.entities:
		var intent = cs.get_component(e, "MovementIntentComponent")

		var input = cs.get_component(e, "InputComponent")
		if input:
			var cam = cs.get_component(e, "CameraComponent")
			if not cam:
				continue

			var forward = Vector3(sin(cam.yaw), 0, cos(cam.yaw))

			var right = Vector3(forward.z, 0, -forward.x)

			intent.direction =(forward * input.move.y +
				 right   * input.move.x).normalized()

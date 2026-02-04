extends BaseSystem
class_name FollowOwnerPositionSystem

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus ):
	super._init(_entity_manager, _component_store, _event_bus)
	
	arch = cs.register_archetype(["TransformComponent", "FollowOwnerComponent"],["DeadComponent"])
func update(_delta: float) -> void:
	
	for e in arch.entities:
		
		var follow: FollowOwnerComponent = cs.get_component(e, "FollowOwnerComponent")
		var offset: Vector3 = follow.offset
		var owner_id: int = follow.owner_id
		var follow_weight: float = follow.weight
		var owner_tf: TransformComponent = cs.get_component(owner_id, "TransformComponent")
		if not owner_tf:
			continue
		var tf: TransformComponent = cs.get_component(e, "TransformComponent")
		tf.position = lerp(tf.position, owner_tf.position + offset,follow_weight)

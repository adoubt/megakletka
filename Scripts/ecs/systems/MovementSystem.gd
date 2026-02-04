extends BaseSystem
class_name MovementSystem


func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus,):
	super._init( _entity_manager, _component_store, _event_bus)
	arch = cs.register_archetype(["TransformComponent", "MoveSpeedComponent","MovementIntentComponent"],
		["DeadComponent"])

func update(_delta: float) -> void:
	

	for e_id in arch.entities:
		
		var tf := cs.get_component(e_id, "TransformComponent")
		var speed := cs.get_component(e_id, "MoveSpeedComponent")
		
		
		var move := cs.get_component(e_id, "MovementIntentComponent")

		tf.velocity.x = (move.direction.x * speed.final_value ) 
		tf.velocity.z = (move.direction.z * speed.final_value )
		

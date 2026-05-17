extends BaseSystem
class_name GravitySystem

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus ):
	super._init(_entity_manager, _component_store, _event_bus)
	
	arch = cs.register_archetype(
	["TransformComponent", "GravityComponent",],
	["DeadComponent", "JumpTimerComponent"]
)
	event_bus.subscribe("day_changed",_refresh_wind)
		
var wind: Vector3 = Vector3.ZERO

func update(delta: float) -> void:

	for e_id in arch.entities:
		
		var tf: TransformComponent = cs.components["TransformComponent"][e_id]

		if tf.grounded:
			tf.velocity = tf.velocity.lerp(Vector3.ZERO,0.1)
			continue
		var gravity: GravityComponent = cs.components["GravityComponent"][e_id]
		tf.velocity.y += gravity.gravity * delta
		tf.velocity += wind * delta

			
func _refresh_wind(_data: Dictionary)-> void:
	wind = Vector3(randf_range(-5.0,5.0),randf_range(-5.0,5.0),randf_range(-5.0,5.0))	

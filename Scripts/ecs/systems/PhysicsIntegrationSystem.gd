extends BaseSystem
class_name PhysicsIntegrationSystem



var ground: GroundHeightComponent
const GROUND_EPS := 0.01
func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus ):
	super._init(_entity_manager, _component_store, _event_bus)
	event_bus.subscribe("ground_generated",_on_ground_generated)
	arch = cs.register_archetype(
	["TransformComponent", "GravityComponent"],
	["DeadComponent"]
)

		
func update(delta: float) -> void:
	if ground == null:
		return

	var entities := arch.entities.duplicate()
	for e_id in entities:
		var tf := cs.get_component(e_id, "TransformComponent")
		
		tf.position += tf.velocity * delta

		var ground_y := ground.get_height(tf.position.x, tf.position.z)

		if tf.position.y <= ground_y + GROUND_EPS:

			if tf.velocity.y < 0.01:
				var impact_vy :float = tf.velocity.y
				tf.velocity.y = 0.0

				if not tf.grounded:
					tf.grounded = true
					

					var jumps := cs.get_component(e_id, "JumpsCountComponent")
					var jumps_left := cs.get_component(e_id, "JumpsLeftComponent")
					if jumps and jumps_left:
						event_bus.emit("grounded", {
						"entity": e_id,
						"velocity_y": impact_vy
					})
						jumps_left.base_value = jumps.final_value

			tf.position.y = ground_y
		else:
			tf.grounded = false


func _on_ground_generated(data: Dictionary)-> void:
	ground = data.ground

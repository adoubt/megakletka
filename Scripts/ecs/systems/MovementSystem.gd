extends BaseSystem
class_name MovementSystem

const WORLD_HALF := 75/1.5

func _init(
	_entity_manager: EntityManager,
	_component_store: ComponentStore,
	_event_bus: EventBus,
):
	super._init(_entity_manager, _component_store, _event_bus)
	arch = cs.register_archetype(
		["TransformComponent", "MoveSpeedComponent", "MovementIntentComponent"],
		["DeadComponent"]
	)

func update(_delta: float) -> void:
	for e_id in arch.entities:
		var tf: TransformComponent = cs.get_component(e_id, "TransformComponent")
		var speed: MoveSpeedComponent = cs.get_component(e_id, "MoveSpeedComponent")
		var move: MovementIntentComponent = cs.get_component(e_id, "MovementIntentComponent")

		# ===== INPUT → VELOCITY =====
		var dir := move.direction.normalized()
		tf.velocity.x = dir.x * speed.final_value
		tf.velocity.z = dir.z * speed.final_value

		## ===== WORLD WRAP (SNAKE STYLE) =====
		#tf.position.x = _wrap(tf.position.x)
		#tf.position.z = _wrap(tf.position.z)
#
#func _wrap(value: float) -> float:
	#if value > WORLD_HALF:
		#return value - WORLD_HALF * 2.0
	#if value < -WORLD_HALF:
		#return value + WORLD_HALF * 2.0
	#return value

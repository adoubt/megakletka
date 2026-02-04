extends BaseSystem
class_name ClimbSystem

const SIDE_PUSH := 40.0        # горизонтальный импульс
const CLIMB_UP_VELOCITY := 0.3 # скорость вверх
const CLIMB_DAMP := 0.85      # чтобы не разгоняться бесконечно

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus ):
	super._init(_entity_manager, _component_store, _event_bus)
	
	arch = cs.register_archetype(["ClimbComponent", "MovementIntentComponent", "TransformComponent"],
		["DeadComponent"])

func update(delta: float) -> void:
	var enemies = arch.entities.duplicate()
	for e_id in enemies:
		var climb: ClimbComponent = cs.get_component(e_id, "ClimbComponent")
		var move: MovementIntentComponent = cs.get_component(e_id, "MovementIntentComponent")
		var tf: TransformComponent = cs.get_component(e_id, "TransformComponent")

		# таймер
		climb.climb_time_left -= delta
		if climb.climb_time_left <= 0.0:
			cs.remove_component(e_id, "ClimbComponent")
			continue

		# направление ввода (XZ)
		var forward := Vector3(move.direction.x, 0.0, move.direction.z)
		if forward.length_squared() < 0.0001:
			continue

		forward = forward.normalized()
		var side := Vector3(-forward.z, 0.0, forward.x)

		# небольшой рандом / чередование
		if (e_id & 1) == 0:
			side = -side

		# --- ПРИМЕНЕНИЕ К VELOCITY ---
		# вертикаль — задаём минимум (не перетираем, если уже летит выше)
		tf.velocity.y = max(tf.velocity.y, CLIMB_UP_VELOCITY)

		# горизонтальный толчок
		tf.velocity.x = side.x * SIDE_PUSH * delta
		tf.velocity.z = side.z * SIDE_PUSH * delta

		# лёгкое затухание, чтобы не улетать в космос
		tf.velocity.x *= CLIMB_DAMP
		tf.velocity.z *= CLIMB_DAMP

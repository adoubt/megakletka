extends BaseSystem
class_name MovementSystem

var gravity: float = -9.8
var floor_check_distance: float = 2.0
var root_node: Node3D

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _root_node: Node3D):
	super._init(_entity_manager, _component_store)
	root_node = _root_node

func update(delta: float) -> void:
	var entities = get_entities_with(["TransformComponent", "MoveSpeedComponent", "TargetComponent","GroundedComponent"],["ProjectileComponent"])
	if entities.size() == 0:
		return

	var space_state = root_node.get_world_3d().direct_space_state

	for entity_id in entities:
		var tf = cs.get_component(entity_id, "TransformComponent")
		var speed = cs.get_component(entity_id, "MoveSpeedComponent")
		var target = cs.get_component(entity_id, "TargetComponent")
		var grounded = cs.get_component(entity_id, "GroundedComponent")
		#if grounded == null:
			#grounded = GroundedComponent.new()
			#cs.add_component(entity_id,"GroundedComponent", grounded)

		# --- Gravity ---
		if not grounded.is_grounded:
			tf.velocity.y += gravity * delta
		else:
			tf.velocity.y = 0  # стоим на земле

		# --- Горизонтальное движение к цели ---
		if target != null and target.target_id != -1:
			var target_tf = cs.get_component(target.target_id, "TransformComponent")
			if target_tf != null:
				var dir = target_tf.position - tf.position
				dir.y = 0  # игнорируем вертикаль
				if dir.length() > 0.1:
					tf.velocity.x = dir.normalized().x * speed.final_value
					tf.velocity.z = dir.normalized().z * speed.final_value
				else:
					tf.velocity.x = 0
					tf.velocity.z = 0

		# --- Обновляем позицию ---
		tf.position += tf.velocity * delta

		# --- Ground check ---
		var from = tf.position
		var to = tf.position + Vector3.DOWN * floor_check_distance

		var query = PhysicsRayQueryParameters3D.new()
		query.from = from
		query.to = to
		query.collision_mask = 1
		query.exclude = []

		var result = space_state.intersect_ray(query)

		if result:
			tf.position.y = result.position.y
			grounded.is_grounded = true
		else:
			grounded.is_grounded = false

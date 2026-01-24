extends BaseSystem
class_name PhysicsIntegrationSystem


var run_entity : int = -1

func update(delta: float) -> void:
	var entities := get_entities_with(
		["TransformComponent"],
		["DeadComponent"]
	)

	if run_entity == -1:
		run_entity = get_entities_with(["RunComponent"])[0]

	var ground := cs.get_component(run_entity, "GroundHeightComponent")

	for e_id in entities:
		var tf := cs.get_component(e_id, "TransformComponent")
		var col := cs.get_component(e_id, "CollisionComponent")
		var col_offset: float = 0.0
		if col: col_offset = col.radius
		# ---------- INTEGRATION ----------
		tf.position += tf.velocity * delta

		# ---------- GROUND COLLISION ----------
		var ground_y :float = ground.get_height(tf.position.x, tf.position.z) + col_offset

		if tf.position.y <= ground_y:
			tf.position.y = ground_y

			if tf.velocity.y < 0.0:
				tf.velocity.y = 0.0

			if not tf.grounded:
				tf.grounded = true

				# событие приземления
				if cs.has_component(e_id, "CameraComponent"):
					event_bus.emit("grounded", {
						"entity": e_id,
						"impact": abs(tf.velocity.y)
					})

				# reset прыжков
				if cs.has_component(e_id, "JumpComponent"):
					var jump := cs.get_component(e_id, "JumpComponent")
					jump.jumps_left = jump.max_jumps
		else:
			tf.grounded = false

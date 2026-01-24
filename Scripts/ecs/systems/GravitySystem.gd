extends BaseSystem
class_name GravitySystem

const FLOOR_Y: float = 0.0


func update(delta: float) -> void:
	var entities := get_entities_with(
		["TransformComponent", "GravityComponent", "CollisionComponent"],
		["DeadComponent"]
	)

	for e_id in entities:
		var tf := cs.get_component(e_id, "TransformComponent")
		var col := cs.get_component(e_id, "CollisionComponent")
		var gravity:= cs.get_component(e_id, "GravityComponent")
		# ================= CLIMB =================
		if cs.has_component(e_id, "ClimbComponent"):
			cs.remove_component(e_id, "ClimbComponent")
			tf.velocity.y = 0.0
			tf.grounded = false
			continue

		# ================= GRAVITY =================
		tf.velocity.y += gravity.gravity * delta
		
		#tf.position.y += tf.velocity.y * delta

		var floor_y : float = FLOOR_Y + col.radius

		# ================= FLOOR =================
		if tf.position.y <= floor_y:
			tf.position.y = floor_y

			if tf.velocity.y < 0.0:
				tf.velocity.y = 0.0

			# переход ВПЕРВЫЕ в grounded
			if not tf.grounded:
				tf.grounded = true
				if cs.has_component(e_id, "CameraComponent"):
					event_bus.emit("grounded", {"entity": e_id,
					"impact": abs(tf.velocity.y)
					})
				# ===== RESET JUMPS HERE =====
				if cs.has_component(e_id, "JumpComponent"):
					var jump := cs.get_component(e_id, "JumpComponent")
					jump.jumps_left = jump.max_jumps
				
		else:
			tf.grounded = false

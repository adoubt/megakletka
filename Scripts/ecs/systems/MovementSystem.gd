extends BaseSystem
class_name MovementSystem

const GRAVITY := -9.8
const CLIMB_SPEED := 2.0
const FLOOR_Y := 0.6

func update(delta: float) -> void:
	var entities := get_entities_with(
		["TransformComponent", "MoveSpeedComponent", "TargetComponent"],
		["ProjectileComponent"]
	)

	for id in entities:
		var tf = cs.get_component(id, "TransformComponent")
		var speed = cs.get_component(id, "MoveSpeedComponent")
		var target = cs.get_component(id, "TargetComponent")

		if not tf or not speed or not target:
			continue

		# ---- XZ движение к цели ----
		if target.target_id != -1:
			var target_tf = cs.get_component(target.target_id, "TransformComponent")
			if target_tf:
				var dx = target_tf.position.x - tf.position.x
				var dz = target_tf.position.z - tf.position.z
				var len = dx * dx + dz * dz

				if len > 0.001:
					len = sqrt(len)
					var inv = 1.0 / len
					tf.velocity.x = dx * inv * speed.final_value
					tf.velocity.z = dz * inv * speed.final_value
				else:
					tf.velocity.x = 0
					tf.velocity.z = 0
		else:
			tf.velocity.x = 0
			tf.velocity.z = 0
			
		

		# ---- ГРАВИТАЦИЯ ----
		
		if tf.position.y + cs.get_component(id, "CollisionComponent").radius > FLOOR_Y:
			tf.velocity.y += GRAVITY * delta
		elif cs.has_component(id, "ClimbComponent"):
			tf.velocity.y = max(tf.velocity.y, CLIMB_SPEED)


			cs.remove_component(id, "ClimbComponent")
		else: 
			tf.velocity.y = FLOOR_Y
		# ---- ИНТЕГРАЦИЯ ----
		tf.position += tf.velocity * delta

		# ---- ПОЛ ----
		#var col = cs.get_component(id, "CollisionComponent")
		
		#if tf.position.y + col.radius  < FLOOR_Y:
			#tf.position.y = FLOOR_Y
			#if tf.velocity.y < 0:
				#tf.velocity.y = 0

extends BaseSystem
class_name MovementSystem

const GRAVITY :float= -9.8
const CLIMB_SPEED :float= 5.0
const FLOOR_Y :float= 0.6

func update(delta: float) -> void:
	var entities := get_entities_with(
		["TransformComponent", "MoveSpeedComponent"],
		["DeadComponent"]
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
		#elif cs.has_component(id, "ClimbComponent"):
			#tf.velocity.y = 0.0
			#tf.velocity += Vector3( 
				#randf() * -CLIMB_SPEED if (abs(tf.velocity.x) > abs(tf.velocity.z)) else randf() * CLIMB_SPEED,
				#randf() * CLIMB_SPEED,
				#randf() * -CLIMB_SPEED if (abs(tf.velocity.z) > abs(tf.velocity.x)) else randf() * CLIMB_SPEED
				#) 
	#
			#cs.remove_component(id, "ClimbComponent")
		elif cs.has_component(id, "ClimbComponent"):
			var vel :Vector3= tf.velocity

			# направление вперёд (куда моб ХОТЕЛ идти)
			var forward := Vector3(vel.x, 0, vel.z)
			var _speed := forward.length()

			if _speed > 0.01:
				forward = forward.normalized()
			else:
				forward = Vector3.ZERO

			# вектор вбок (перпендикуляр)
			var side := Vector3(-forward.z, 0, forward.x)

			# случайно влево или вправо
			if randf() < 0.5:
				side = -side

			# ---- ПАРАМЕТРЫ ----
			var side_push := CLIMB_SPEED * 0.6
			var brake := 0.5 # 0.0 = стоп, 1.0 = без тормоза

			# ---- ПРИМЕНЕНИЕ ----
			vel.x = forward.x * _speed * brake + side.x * side_push
			vel.z = forward.z * _speed * brake + side.z * side_push
			vel.z = CLIMB_SPEED 
			# слегка прижать вниз, чтобы не подпрыгивал
			#vel.y = min(vel.y, 0.0)

			tf.velocity = vel
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

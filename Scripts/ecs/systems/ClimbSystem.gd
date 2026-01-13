extends BaseSystem
class_name ClimbSystem

func update(_delta:float ) -> void:
	var entities = get_entities_with(["ClimbComponent"],["DeadComponent"])
	for e_id in entities:
		var tf = cs.get_component("")
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
		pass
		

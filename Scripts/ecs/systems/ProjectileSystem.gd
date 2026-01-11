# ProjectileSystem.gd
extends BaseSystem
class_name ProjectileSystem

func update(delta: float) -> void:
	var projectiles = get_entities_with(["ProjectileComponent", "TransformComponent"],["DeadComponent"])
	for e_id in projectiles:
		var tf = cs.get_component(e_id, "TransformComponent")
		var proj = cs.get_component(e_id, "ProjectileComponent")
		if tf == null or proj == null:
			continue
		var lifetime = cs.get_component(e_id,"LifetimeComponent")
		
		# lifetime
		lifetime.time_left -= delta
		if lifetime.time_left <= 0:
		
			if not cs.has_component(e_id, "DeadComponent"):
				cs.add_component(e_id, "DeadComponent", DeadComponent.new())
			continue

		# movement type (здесь безопасно читать proj.move_type — поле всегда есть)
		match proj.move_type:
			MoveType.ORBIT:
				var owner_id = proj.owner_id
				if owner_id == -1 or cs.has_component(owner_id, "DeadComponent"):
					cs.add_component(e_id, "DeadComponent", DeadComponent.new())
					continue

				var owner_tf = cs.get_component(owner_id, "TransformComponent")
				if owner_tf == null:
					cs.add_component(e_id, "DeadComponent", DeadComponent.new())
					continue

				var orbit = cs.get_component(e_id, "OrbitComponent")
				orbit.angle += orbit.speed * delta

				var offset = Vector3(
					cos(orbit.angle) * orbit.radius,
					orbit.height,
					sin(orbit.angle) * orbit.radius
				)

				tf.position = owner_tf.position + offset
				tf.velocity = Vector3.ZERO # важно
				if cs.has_component(e_id, "RenderComponent"):
					var render = cs.get_component(e_id, "RenderComponent")
					
					if render and render.instance:
						
						
						
						render.instance.rotate_x(deg_to_rad(orbit.tilt_x))
						render.instance.rotate_y(deg_to_rad(orbit.tilt_y))
						render.instance.rotate_z(deg_to_rad(orbit.tilt_z))
			MoveType.HOMING:
				if proj.target_id != -1 and cs.has_component(proj.target_id, "TransformComponent"):
					var target_tf = cs.get_component(proj.target_id, "TransformComponent")
					var dir = target_tf.position - tf.position

					if dir.length_squared() > 0.0001:
						tf.velocity = dir.normalized() * proj.speed
				else:
					tf.velocity = proj.direction * proj.speed

			MoveType.LINEAR:
				tf.velocity = proj.direction * proj.speed


		
		

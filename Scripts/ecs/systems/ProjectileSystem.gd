extends BaseSystem
class_name ProjectileSystem

func update(delta: float) -> void:
	var projectiles := get_entities_with(
		["ProjectileComponent"],
		["DeadComponent"]
	)

	for e_id in projectiles:
		var tf: TransformComponent = cs.get_component(e_id, "TransformComponent")
		var proj: ProjectileComponent = cs.get_component(e_id, "ProjectileComponent")
		var lifetime: LifetimeComponent = cs.get_component(e_id, "LifetimeComponent")

		lifetime.time_left -= delta
		if lifetime.time_left <= 0.0:
			cs.add_component(e_id, "DeadComponent", DeadComponent.new())
			continue

		match proj.move_type:
			ProjectileMoveType.LINEAR:
				tf.velocity = proj.direction.normalized() * proj.speed
			ProjectileMoveType.CHASE:
		
				var aim: AimComponent = cs.get_component(e_id, "AimComponent")
				var dir: Vector3 = aim.position - tf.position
		
				if dir.length_squared() <= 0.0001:
					tf.velocity = Vector3.ZERO
					continue

				tf.velocity = dir.normalized() * proj.speed
		cs.remove_component(e_id, "AimComponent")

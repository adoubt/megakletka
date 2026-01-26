extends BaseSystem
class_name ProjectileSystem


func update(_delta: float) -> void:
	var projectiles := get_entities_with(
		["ProjectileComponent"],
		["DeadComponent"]
	)

	for e_id in projectiles:
		var tf: TransformComponent = cs.get_component(e_id, "TransformComponent")
		var proj: ProjectileComponent = cs.get_component(e_id, "ProjectileComponent")
		var move := cs.get_component(e_id, "MovementIntentComponent")
		var speed:= cs.get_component(e_id,"MoveSpeedComponent")
		
		if tf.grounded:
			cs.add_component(e_id,"DeadComponent", DeadComponent.new())
			continue
		tf.velocity.y =  move.direction.y * speed.final_value
		match proj.move_type:
			ProjectileMoveType.LINEAR:
				pass
			ProjectileMoveType.CHASE:
		
				var aim: AimComponent = cs.get_component(e_id, "AimComponent")
				var dir: Vector3 = aim.position - tf.position
		
				if dir.length_squared() <= 0.0001:
					tf.velocity = Vector3.ZERO
					continue

				tf.velocity = dir.normalized() * proj.speed
				cs.remove_component(e_id, "AimComponent")

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
			"orbit":
				# Если владелец мёртв — уничтожаем снаряд
				var owner_id = proj.owner_id
				if owner_id == -1 or cs.has_component(owner_id, "DeadComponent"):
					cs.add_component(e_id,"DeadComponent",DeadComponent.new())
					return
				var owner_tf = cs.get_component(proj.owner_id, "TransformComponent")
				if owner_tf == null:
					print("⚠ ORBIT ERROR: Owner ", owner_id, " has NO TransformComponent! Dead?", cs.has_component(owner_id, "DeadComponent"))
					cs.add_component(e_id, "DeadComponent", DeadComponent.new())
					return

				var orbit = cs.get_component(e_id, "OrbitComponent")
				orbit.angle += orbit.speed * delta
				var x = cos(orbit.angle) * orbit.radius
				var z = sin(orbit.angle) * orbit.radius
				tf.position = owner_tf.position + Vector3(x, orbit.height, z)
			"homing":
				if proj.target_id != -1 and cs.has_component(proj.target_id, "TransformComponent"):
					var target_tf = cs.get_component(proj.target_id, "TransformComponent")
					var dir = (target_tf.position - tf.position)
					if dir.length() > 0.001:
						tf.position += dir.normalized() * proj.speed * delta
					else:
						# если цель слишком близко — ничего
						pass
				else:
					if proj.direction.length() > 0.001:
						tf.position += proj.direction.normalized() * proj.speed * delta
			_:
				# default / "linear"
				if proj.direction.length() > 0.001:
					tf.position += proj.direction.normalized() * proj.speed * delta

		# (опционально) обновим визуал поворотом, если есть
		if cs.has_component(e_id, "RenderComponent"):
			var render = cs.get_component(e_id, "RenderComponent")
			if render and render.instance:
				# направляем инстанс по вектору движения (игнорируя y для красоты)
				var fwd = proj.direction
				fwd.y = 0
				if fwd.length() > 0.001:
					render.instance.look_at(tf.position + fwd, Vector3.UP)

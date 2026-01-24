extends BaseSystem
class_name EnemyChaseSystem

func update(_delta: float) -> void:
	var enemies := get_entities_with([
		"EnemyComponent",
		"TransformComponent",
		"AimComponent",
		"MovementIntentComponent"
	])

	for e_id in enemies:
		

		var tf := cs.get_component(e_id, "TransformComponent")
		var aim := cs.get_component(e_id, "AimComponent")
		var move := cs.get_component(e_id, "MovementIntentComponent")

		var dir :Vector3= aim.position - tf.position
		if dir.length_squared() < 0.01:
			continue
		dir.y = 0.0
		move.direction = dir.normalized()
		cs.remove_component(e_id,"AimComponent")

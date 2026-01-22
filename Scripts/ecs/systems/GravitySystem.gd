extends BaseSystem
class_name GravitySystem

const FLOOR_Y: float = 0.0

func update(delta: float) -> void:
	var entities := get_entities_with(
		["TransformComponent", "GravityComponent", "CollisionComponent"],
		["DeadComponent"]
	)

	for e_id in entities:
		# climb — отдельная способность, временно отменяет гравитацию
		if cs.has_component(e_id, "ClimbComponent"):
			cs.remove_component(e_id, "ClimbComponent")
			continue

		var tf := cs.get_component(e_id, "TransformComponent")
		var col := cs.get_component(e_id, "CollisionComponent")
		var grav := cs.get_component(e_id, "GravityComponent")

		if tf.position.y - col.radius > FLOOR_Y:
			tf.velocity.y += grav.gravity * delta
		else:
			tf.position.y = FLOOR_Y + col.radius
			tf.velocity.y = 0.0

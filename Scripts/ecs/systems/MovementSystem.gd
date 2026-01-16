extends BaseSystem
class_name MovementSystem

const GRAVITY := -9.8
const FLOOR_Y := 0.0

func update(delta: float) -> void:
	var entities := get_entities_with(
		["TransformComponent"],
		["DeadComponent"]
	)

	for e_id in entities:
		var tf := cs.get_component(e_id, "TransformComponent")
		if tf == null:
			continue
		if cs.has_component(e_id, "MovementIntentComponent"):
			var move := cs.get_component(e_id, "MovementIntentComponent")
			tf.velocity.x = move.direction.x * move.speed
			tf.velocity.z = move.direction.z * move.speed
			tf.velocity.y = move.direction.y * move.speed
		# -------- MOB MOVEMENT / PickUps--------
		elif cs.has_component(e_id, "MovementComponent"):
			var move := cs.get_component(e_id, "MovementComponent")
			tf.velocity.x = move.direction.x * move.speed
			tf.velocity.z = move.direction.z * move.speed
			tf.velocity.y = move.direction.y * move.speed
		# -------- GRAVITY --------
		var climb = cs.has_component(e_id, "ClimbComponent")
		if not climb:
			var col = cs.get_component(e_id, "CollisionComponent")
			if col and not cs.has_component(e_id, "POIComponent"):
				if tf.position.y - col.radius > FLOOR_Y:
					tf.velocity.y += GRAVITY * delta
				else:
					tf.position.y = FLOOR_Y + col.radius
					tf.velocity.y = 0.0
		else: cs.remove_component(e_id, "ClimbComponent")

		# -------- INTEGRATION --------
		tf.position += tf.velocity * delta

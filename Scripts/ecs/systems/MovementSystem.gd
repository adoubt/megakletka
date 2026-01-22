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
	

		# -------- INTEGRATION --------
		tf.position += tf.velocity * delta

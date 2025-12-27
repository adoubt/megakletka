extends BaseSystem
class_name MovementSystem

var gravity: float = -9.8
var floor_check_distance: float = 2.0

func update(delta: float) -> void:
	var entities := get_entities_with(["TransformComponent", "MoveSpeedComponent", "TargetComponent"], ["ProjectileComponent"])
	if entities.is_empty():
		return

	for entity_id in entities:
		var tf = cs.get_component(entity_id, "TransformComponent")
		if not tf:
			continue

		var speed = cs.get_component(entity_id, "MoveSpeedComponent")
		if not speed:
			continue

		var target = cs.get_component(entity_id, "TargetComponent")
		if not target or target.target_id == -1:
			tf.velocity = Vector3.ZERO
			continue

		var target_tf = cs.get_component(target.target_id, "TransformComponent")
		if not target_tf:
			tf.velocity = Vector3.ZERO
			continue

		# --- направление к цели ---
		var dx = target_tf.position.x  - tf.position.x
		var dy = target_tf.position.y + 0.3 - tf.position.y
		var dz = target_tf.position.z - tf.position.z
		var len = dx * dx + dy * dy + dz * dz

		if len > 0.01:
			len = sqrt(len)
			var inv = 1.0 / len
			tf.velocity.x = dx * inv * speed.final_value
			tf.velocity.y = dy * inv * speed.final_value
			tf.velocity.z = dz * inv * speed.final_value
		else:
			tf.velocity = Vector3.ZERO

		# --- обновляем позицию ---
		tf.position.x += tf.velocity.x * delta
		tf.position.y += tf.velocity.y * delta
		tf.position.z += tf.velocity.z * delta


	

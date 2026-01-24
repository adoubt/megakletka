extends BaseSystem
class_name MovementSystem


func update(delta: float) -> void:
	var entities := get_entities_with(
		["TransformComponent", "MoveSpeedComponent"],
		["DeadComponent"],
	)

	for e_id in entities:
		var tf := cs.get_component(e_id, "TransformComponent")
		var speed:=cs.get_component(e_id, "MoveSpeedComponent")
		if tf == null:
			continue
		if cs.has_component(e_id, "MovementIntentComponent"):
			var move := cs.get_component(e_id, "MovementIntentComponent")
			tf.velocity.x = move.direction.x * speed.final_value
			tf.velocity.z = move.direction.z * speed.final_value
			#tf.velocity.y += move.direction.y * speed.final_value
		
	

		# -------- INTEGRATION --------
		tf.position += tf.velocity * delta

extends BaseSystem
class_name GravitySystem

func update(delta: float) -> void:
	var entities := get_entities_with(
		["TransformComponent", "GravityComponent"],
		["DeadComponent"]
	)

	for e_id in entities:
		
		var tf := cs.get_component(e_id, "TransformComponent")
		if cs.has_component(e_id, "ClimbComponent"):
			cs.remove_component(e_id, "ClimbComponent")
			tf.velocity.y = 0.0
			tf.grounded = false
			continue
			
		var gravity := cs.get_component(e_id, "GravityComponent")

		# если стоим на земле — не накапливаем вниз
		if tf.grounded and tf.velocity.y <= 0.0:
			continue

		tf.velocity.y += gravity.gravity * delta

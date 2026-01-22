extends BaseSystem
class_name JumpSystem

func update(_delta):
	var entities = get_entities_with([
		"InputComponent",
		"JumpComponent",
		"TransformComponent"
	])

	for e in entities:
		var input := cs.get_component(e, "InputComponent")
		var tf := cs.get_component(e, "TransformComponent")
		var jump := cs.get_component(e, "JumpComponent")

		if input.jump and jump.jumps_left > 0:
			tf.velocity.y = jump.jump_height
			tf.grounded = false
			jump.jumps_left -= 1

extends BaseSystem
class_name InputSystem

func update(_delta):
	var entities = get_entities_with(["InputComponent"])

	for e in entities:
		var input := cs.get_component(e, "InputComponent")

		input.move = Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_back")  - Input.get_action_strength("move_forward")
		)
		input.jump = Input.is_action_just_pressed("jump")

		input.look = UIManager.consume_mouse_delta()

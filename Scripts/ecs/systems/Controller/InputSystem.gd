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

		input.look = UIManager.consume_mouse_delta()

		input.jump = Input.is_action_just_pressed("jump")
		#input.attack = Input.is_action_pressed("attack")

		input.interact_held = Input.is_action_pressed("interact")
		input.interact_pressed = Input.is_action_just_pressed("interact")
		input.interact_released= Input.is_action_just_released("interact")

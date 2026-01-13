extends BaseSystem
class_name InputSystem

func update(_delta):
	var players = get_entities_with([
		"PlayerComponent",
		"InputComponent"
	])

	for e in players:
		var input = cs.get_component(e, "InputComponent")

		input.move = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("forward") - Input.get_action_strength("back")
		)

		input.look = Input.get_mouse_delta()
		input.jump = Input.is_action_just_pressed("jump")
		input.attack = Input.is_action_pressed("attack")

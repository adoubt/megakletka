extends BaseSystem
class_name InputSystem

func update(_delta: float):
	var entities = get_entities_with(
		["InputComponent", "PlayerComponent"],
		["DeadComponent"]
	)

	for id in entities:
		var input := cs.get_component(id, "InputComponent")
		input.move = Input.get_vector(
			"move_left",
			"move_right",
			"move_forward",
			"move_back"
		)
		input.jump = Input.is_action_just_pressed("jump")
		input.sprint = Input.is_action_pressed("sprint")

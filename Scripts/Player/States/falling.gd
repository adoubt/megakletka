extends PlayerState

var was_sprinting: bool = false
func enter(previous_state_path: String, data := {}) -> void:
	player.current_state = name
	was_sprinting = false
	if data.has("was_sprinting"):
		was_sprinting = bool(data["was_sprinting"])
	print(previous_state_path, " -> Falling")

	var anims = ["Pack/fall", "Pack/fall_2"]
	var random_anim = anims.pick_random()

	player.animation_player.play(random_anim, 0.25)

func physics_update(delta: float) -> void:
	player.velocity.y += player.gravity * delta
	handle_air_control(delta,was_sprinting)
	model_follow_camera(delta)
	player.move_and_slide()
	
	if player.is_on_floor():
		# Возвращаемся в Idle или Running в зависимости от ввода
		if Input.get_vector("move_left", "move_right", "move_forward", "move_back").length() > 0:
			if player.input_enabled:  finished.emit(RUNNING)
		else:
			finished.emit(IDLE)

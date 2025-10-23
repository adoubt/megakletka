extends PlayerState

var was_sprinting: bool = false

func enter(previous_state_path: String, data := {}) -> void:
	print(previous_state_path, " -> Jumping")

	# Сохраняем, был ли спринт перед прыжком
	was_sprinting = previous_state_path == SPRINTING

	# Вертикальный импульс
	player.velocity.y = player.jump_velocity
	player.animation_player.speed_scale = 5.0 / player.jump_velocity
	player.animation_player.play("Pack/idle_to_jump", 0.25)


func physics_update(delta: float) -> void:
	player.velocity.y += player.gravity * delta
	handle_air_control(delta,was_sprinting)
	model_follow_camera(delta)

	player.move_and_slide()

	# Когда падаем
	if player.velocity.y <= 0:
		finished.emit(FALLING,{"was_sprinting": was_sprinting})

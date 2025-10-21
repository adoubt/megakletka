extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	print(previous_state_path, " -> Running")
	
	player.animation_player.speed_scale = 1.0
	player.animation_player.play("AnimPack/slow_run", 0.25)


func physics_update(delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = Vector3(input_dir.x, 0, input_dir.y)
	direction = direction.rotated(Vector3.UP, player.get_current_camera().global_rotation.y).normalized()

	# Если игрок двигается
	if direction != Vector3.ZERO:
		# --- обычное движение ---
		direction *= player.max_speed
		player.velocity.x = move_toward(player.velocity.x, direction.x, delta * player.acceleration)
		player.velocity.z = move_toward(player.velocity.z, direction.z, delta * player.acceleration)


		# 👉 если зажат Shift — переходим в Sprinting
		if Input.is_action_pressed("sprint"):
			if player.input_enabled: finished.emit(SPRINTING)
			return
	else:
		finished.emit(IDLE)
		return

	# --- гравитация и прыжок ---
	player.velocity.y += player.gravity * delta
	player.move_and_slide()
	model_follow_camera(delta)
	if not player.is_on_floor():
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("jump"):
		if player.input_enabled:  finished.emit(JUMPING)

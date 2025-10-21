extends PlayerState


func enter(previous_state_path: String, data := {}) -> void:
	
	print(previous_state_path, " -> Sprinting")
	player.animation_player.speed_scale = 1.3
	
	player.animation_player.play("AnimPack/run_fast", 0.25)


func physics_update(delta: float) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = Vector3(input_dir.x, 0, input_dir.y)
	direction = direction.rotated(Vector3.UP, player.get_current_camera().global_rotation.y).normalized()

	if direction != Vector3.ZERO:
		# --- спринт с повышенной скоростью ---
		var sprint_speed = player.max_speed * 1.5
		var sprint_accel = player.acceleration * 1.2

		direction *= sprint_speed
		player.velocity.x = move_toward(player.velocity.x, direction.x, delta * sprint_accel)
		player.velocity.z = move_toward(player.velocity.z, direction.z, delta * sprint_accel)


		# если отпустили Shift — возвращаемся к обычному бегу
		if not Input.is_action_pressed("sprint"):
			if player.input_enabled:  finished.emit(RUNNING)
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

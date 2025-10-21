extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	print(previous_state_path," -> Idle")
	player.velocity.x = 0.0
	player.velocity.z = 0.0
	player.animation_player.speed_scale = 1.0
	#if previous_state_path == "Falling":
		#player.animation_player.play("Pack/fall_to_idle_2",0.8)
	#else:
	player.animation_player.play("AnimPack/idle_3",0.25)


func physics_update(delta: float) -> void:
	# === Гравитация ===
	
	player.velocity.y += player.gravity * delta
	player.move_and_slide()
	
	# === Переходы ===
	if not player.is_on_floor():
		
		finished.emit(FALLING)
	elif Input.is_action_just_pressed("jump"):
		if player.input_enabled: finished.emit(JUMPING)
		
	elif Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") \
		or Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_back"):
		if player.input_enabled: finished.emit(RUNNING)
	#elif Input.get_vector("move_left", "move_right", "move_forward", "move_back") != Vector2.ZERO:
		#finished.emit(PlayerStates.RUNNING)

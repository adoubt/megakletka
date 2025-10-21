extends PlayerState

@export var death_duration := 2.5  # длительность анимации (сек)
var timer := 0.0

func enter(previous_state_path: String, data := {}) -> void:
	print(previous_state_path, " -> Dying")

	# Отключаем движение и ввод
	#player.velocity = Vector3.ZERO
	player.input_enabled = false

	var anims = ["Pack/death", "Pack/death_2", "Pack/death_3", "Pack/death_4" ]
	var random_anim = anims.pick_random()

	player.animation_player.play(random_anim, 0.25)


func physics_update(delta: float) -> void:
	timer += delta
	player.velocity.y += player.gravity * delta
	player.move_and_slide()

	if timer >= death_duration:
		# После смерти можно перейти в Respawn или просто остаться мёртвым
		finished.emit("Respawn")  # или убери это, если смерть — финал

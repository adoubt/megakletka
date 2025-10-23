class_name PlayerState extends State

const IDLE : String = "Idle"
const RUNNING : String = "Running"
const JUMPING : String = "Jumping"
const FALLING : String = "Falling"
const SPRINTING : String = "Sprinting"
enum PlayerStates { IDLE, RUNNING, JUMPING, FALLING,SPRINTING }

var player: Player


func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")

func handle_air_control(delta: float, was_sprinting: bool) -> void:
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	direction = direction.rotated(Vector3.UP, player.get_current_camera().global_rotation.y).normalized()

	# Если был спринт, сохраняем больше горизонтальной скорости
	var base_speed: float = player.max_speed * 1.5 if was_sprinting else player.max_speed
	var air_speed: float = base_speed * 0.9  # немного меньше, чем на земле
	var air_accel: float = player.acceleration * 0.6

	if direction != Vector3.ZERO:
		direction *= air_speed
		player.velocity.x = move_toward(player.velocity.x, direction.x, delta * air_accel)
		player.velocity.z = move_toward(player.velocity.z, direction.z, delta * air_accel)
	else:
		# сохраняем инерцию
		player.velocity.x = move_toward(player.velocity.x, player.velocity.x, delta * air_accel)
		player.velocity.z = move_toward(player.velocity.z, player.velocity.z, delta * air_accel)
		
func model_follow_camera(delta: float) -> void:
	var velocity_dir = Vector3(player.velocity.x, 0, player.velocity.z)
	if velocity_dir.length() < 0.01:
		return  # не поворачиваем, если стоим

	velocity_dir = velocity_dir.normalized()
	var target_rot = player.model.global_transform.looking_at(player.global_position - velocity_dir, Vector3.UP)
	
	# Плавно интерполируем между текущим и целевым вращением
	player.model.global_transform.basis = player.model.global_transform.basis.slerp(
		target_rot.basis,
		delta * 10.0  # <-- чем больше число, тем быстрее поворот
	)

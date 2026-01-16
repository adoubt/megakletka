extends BaseSystem
class_name ClimbSystem

const SIDE_PUSH := 0.4
const CLIMB_Y := 0.8 # насколько "вверх"

func update(_delta: float) -> void:
	var entities = get_entities_with(
		["ClimbComponent", "MovementComponent"],
		["DeadComponent"]
	)

	for e_id in entities:
		var move := cs.get_component(e_id, "MovementComponent")

		var forward := Vector3(move.direction.x, 0, move.direction.z)
		if forward.length() < 0.01:
			continue

		forward = forward.normalized()
		var side := Vector3(-forward.z, 0, forward.x)

		if e_id % 2 == 0:
			side = -side

		var new_dir := forward + side * SIDE_PUSH
		new_dir.y = CLIMB_Y

		move.direction = new_dir.normalized()

	

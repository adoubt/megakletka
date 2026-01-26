extends BaseSystem
class_name PlayerControlSystem

func update(_delta):
	var players = get_entities_with([
		"InputComponent",
		"MovementIntentComponent"
	])

	for e in players:
		var input := cs.get_component(e, "InputComponent")
		var intent := cs.get_component(e, "MovementIntentComponent")

		# --- ищем камеру, которая смотрит на нас ---
		var cam_forward := Vector3.FORWARD
		var cam_right := Vector3.RIGHT
		var camera_id = -1
		for cam_e in get_entities_with(["CameraComponent"]):
			if cs.get_component(cam_e, "CameraComponent").owner_id == e:
				camera_id = cam_e
				break
					
		var cam := cs.get_component(camera_id, "CameraComponent")
		cam_forward = cam.forward
		cam_right = cam.right
		

		var forward := cam_forward
		forward.y = 0
		forward = forward.normalized()

		var right := cam_right
		right.y = 0
		right = right.normalized()

		var dir = forward * input.move.y + right * input.move.x


		if dir.length_squared() > 0.0001:
			dir = dir.normalized()

		intent.direction = dir

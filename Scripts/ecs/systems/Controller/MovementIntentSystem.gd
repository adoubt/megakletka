extends BaseSystem
class_name MovementIntentSystem

func update(_delta):
	var entities = get_entities_with([
		"TransformComponent",
		"MovementIntentComponent"
	])

	for e in entities:
		var intent = cs.get_component(e, "MovementIntentComponent")

		var input = cs.get_component(e, "InputComponent")
		if input:
			var cam = cs.get_component(e, "CameraComponent")
			if not cam:
				continue

			var forward = Vector3(sin(cam.yaw), 0, cos(cam.yaw))

			var right = Vector3(forward.z, 0, -forward.x)

			intent.direction =(forward * input.move.y +
				 right   * input.move.x).normalized()

extends BaseSystem
class_name CameraSystem

func update(delta):
	var entities = get_entities_with([
		"CameraComponent",
		"TransformComponent",
		"InputComponent"
	])

	for e in entities:
		var cam = cs.get_component(e, "CameraComponent")
		var input = cs.get_component(e, "InputComponent")

		cam.yaw   -= input.look.x * 0.002
		cam.pitch -= input.look.y * 0.002
		cam.pitch = clamp(cam.pitch, -1.4, 1.4)

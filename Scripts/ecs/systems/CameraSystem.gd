extends BaseSystem
class_name CameraSystem

const MOUSE_SCALE: float = 0.0025
const MAX_PITCH: float = 1.1
const MIN_PITCH: float = -1.2

func update(delta):
	var entities = get_entities_with([
		"CameraComponent",
		"TransformComponent"
	])

	for e in entities:
		var cam: CameraComponent = cs.get_component(e, "CameraComponent")

		if cam.owner_id == -1:
			continue
		if !cs.has_component(cam.owner_id, "TransformComponent"):
			continue
		if !cs.has_component(cam.owner_id, "InputComponent"):
			continue

		# ================= INPUT =================
		var input := cs.get_component(cam.owner_id, "InputComponent")

		var inv_x := -1.0 if cam.inverted_horisontal_axis else 1.0
		var inv_y := -1.0 if cam.inverted_vertical_axis else 1.0

		cam.yaw   -= input.look.x * MOUSE_SCALE * cam.sensativity * inv_x
		cam.pitch -= input.look.y * MOUSE_SCALE * cam.sensativity * inv_y
		cam.pitch = clamp(cam.pitch, MIN_PITCH, MAX_PITCH)

		# ================= EFFECTS =================
		var fx: CameraEffectsComponent = null
		if cs.has_component(e, "CameraEffectsComponent"):
			fx = cs.get_component(e, "CameraEffectsComponent")

		var kick_pitch := fx.kick_pitch if fx else 0.0
		var kick_yaw   := fx.kick_yaw if fx else 0.0
		var shake      := fx.shake_offset if fx else Vector3.ZERO
		var fov_offset := fx.fov_offset if fx else 0.0

		# ================= TARGET =================
		var target_tf := cs.get_component(cam.owner_id, "TransformComponent")
		var pivot = target_tf.position + cam.offset

		# ================= ROTATION =================
		var yaw_basis   := Basis(Vector3.UP, cam.yaw + kick_yaw)
		var pitch_basis := Basis(Vector3.RIGHT, cam.pitch + kick_pitch)
		var rot := yaw_basis * pitch_basis

		# ================= POSITION =================
		var desired_pos = pivot + (-rot.z) * cam.distance * (1 - max(cam.pitch, 0.0))
		desired_pos += shake

		# ================= SYNC =================
		if cam.camera_instance == null:
			continue

		cam.camera_instance.global_position = desired_pos
		cam.camera_instance.global_basis = rot

		if fov_offset != 0.0:
			cam.camera_instance.fov += fov_offset

		# ================= EFFECT DECAY =================
		if fx:
			fx.shake_offset = fx.shake_offset.lerp(
				Vector3.ZERO,
				1.0 - exp(-fx.shake_decay * delta)
			)

			fx.kick_pitch = lerp(fx.kick_pitch, 0.0, delta * fx.shake_decay)
			fx.kick_yaw   = lerp(fx.kick_yaw,   0.0, delta * fx.shake_decay)
			fx.fov_offset = lerp(fx.fov_offset, 0.0, delta * fx.shake_decay)

		# ================= DIRECTIONS =================
		var forward := rot.z
		forward.y = 0
		forward = forward.normalized()

		cam.forward = forward
		cam.right = Vector3.UP.cross(cam.forward).normalized()

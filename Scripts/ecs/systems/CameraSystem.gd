extends BaseSystem
class_name CameraSystem

const MOUSE_SCALE: float = 0.0025
const MAX_PITCH: float = 1.1
const MIN_PITCH: float = -1.2

func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus):
	super._init( _entity_manager, _component_store, _event_bus)
	arch = cs.register_archetype(["CameraComponent","TransformComponent"],["DeadComponent"])
func update(delta):
	

	for e in arch.entities:
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
		

		var kick_pitch :float= fx.kick_pitch if fx else 0.0
		var kick_yaw   :float= fx.kick_yaw if fx else 0.0
		var shake      :Vector3 = fx.shake_offset if fx else Vector3.ZERO
		var fov_offset :float= fx.fov_offset if fx else 0.0

		# ================= TARGET =================
		var target_tf := cs.get_component(cam.owner_id, "TransformComponent")

		var drop := fx.drop_offset if fx else 0.0
		var pivot = target_tf.position + cam.offset + Vector3(0, drop, 0)

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
			cam.camera_instance.fov = cam.base_fov + fov_offset

	
		var forward_3d := rot.z.normalized() # полный 3D, для стрельбы
		var forward_xz := Vector3(forward_3d.x, 0, forward_3d.z).normalized() # для движения

		cam.forward_3d = forward_3d
		cam.forward = forward_xz
		cam.right = Vector3.UP.cross(forward_xz).normalized()

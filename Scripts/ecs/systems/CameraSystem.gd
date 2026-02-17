extends BaseSystem
class_name CameraSystem

const MOUSE_SCALE: float = 0.0025
const MAX_PITCH: float = 1.1
const MIN_PITCH: float = -1.2

func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus):
	super._init( _entity_manager, _component_store, _event_bus)
	arch = cs.register_archetype(["CameraEffectsComponent","CameraComponent","TransformComponent"],["DeadComponent",])
func update(delta):
	

	for e in arch.entities:
		var cam: CameraComponent = cs.get_component(e, "CameraComponent")
	
		if cam.owner_id == -1:
			continue
		if !cs.has_component(cam.owner_id, "TransformComponent"):
			continue
		if !cs.has_component(cam.owner_id, "InputComponent"):
			continue
		var fx: CameraEffectsComponent = cs.get_component(e, "CameraEffectsComponent")
		if cam.mode == CameraComponent.Mode.FOCUS:
			_update_focus_mode(cam, delta)
			continue
		if cam.mode == CameraComponent.Mode.LOCKED_FOLLOW:
			_update_locked_follow(cam, delta)
			continue
		# ================= INPUT =================
		var input := cs.get_component(cam.owner_id, "InputComponent")

		var inv_x := -1.0 if cam.inverted_horisontal_axis else 1.0
		var inv_y := -1.0 if cam.inverted_vertical_axis else 1.0

		cam.yaw   -= input.look.x * MOUSE_SCALE * cam.sensativity * inv_x
		cam.pitch -= input.look.y * MOUSE_SCALE * cam.sensativity * inv_y
		cam.pitch = clamp(cam.pitch, MIN_PITCH, MAX_PITCH)

		# ================= EFFECTS =================
		
		

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
		if cam.mode == CameraComponent.Mode.BLEND_TO_FOLLOW:
			_update_return_mode(cam,desired_pos, rot, delta)
			continue
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
		


func _update_return_mode(cam:CameraComponent, target_pos: Vector3, rot: Basis, delta: float) -> void:

	cam.transition_elapsed += delta
	var t = cam.transition_elapsed / cam.transition_time
	t = clamp(t, 0.0, 1.0)

	
	#t = pow(t, 2.0)  # ускорение
	#t = pow(t, 3.0)  # ещё сильнее
	t = 1.0 - pow(1.0 - t, 2.0) # ease-out
	#t = t * t * (3.0 - 2.0 * t) # smoothstep

	var new_pos = cam.return_start_pos.lerp(target_pos, t)
	var new_rot = cam.return_start_rot.slerp(rot, t)

	cam.camera_instance.global_position = new_pos
	cam.camera_instance.global_basis = new_rot

	if t >= 1.0:
		cam.mode = CameraComponent.Mode.FOLLOW
func _update_focus_mode(cam: CameraComponent, delta: float) -> void:
	if cam.camera_instance == null:
		return

	var viewport := cam.camera_instance.get_viewport()
	var window_size: Vector2 = viewport.get_visible_rect().size
	var mouse_pos: Vector2 = viewport.get_mouse_position()

	var center: Vector2 = window_size * 0.5
	var normalized: Vector2 = (mouse_pos - center) / center
	normalized.x = clamp(normalized.x, -1.0, 1.0)
	normalized.y = clamp(normalized.y, -1.0, 1.0)

	var parallax_strength: float = 0.25

	var right: Vector3 = cam.camera_instance.global_basis.x
	var up: Vector3 = cam.camera_instance.global_basis.y

	var mouse_offset: Vector3 = right * normalized.x * parallax_strength \
	- up    * normalized.y * parallax_strength

	var target_pos := cam.focus_from_pos + mouse_offset

	var current_pos := cam.camera_instance.global_position
	var new_pos := current_pos.lerp(target_pos, delta * 3.0)

	var target_basis := Transform3D(Basis(), new_pos)\
		.looking_at(cam.focus_target, Vector3.UP).basis

	var current_basis := cam.camera_instance.global_basis
	var new_basis := current_basis.slerp(target_basis, delta * 6.0)

	cam.camera_instance.global_position = new_pos
	cam.camera_instance.global_basis = new_basis

func _update_locked_follow(cam: CameraComponent, delta: float) -> void:
	if cam.camera_instance == null:
		return
	if !cs.has_component(cam.owner_id, "TransformComponent"):
		return

	var target_tf = cs.get_component(cam.owner_id, "TransformComponent")
	var focus_pos = target_tf.position + Vector3(0.0, 0.8, 0.0)

	var dir = (cam.focus_from_pos - cam.focus_target).normalized()
	var distance = cam.focus_from_pos.distance_to(cam.focus_target)

	cam.focus_target = focus_pos
	cam.focus_from_pos = focus_pos + dir * distance

	_update_focus_mode(cam, delta)

	

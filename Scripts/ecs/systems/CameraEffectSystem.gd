extends BaseSystem
class_name CameraEffectSystem


func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)
	event_bus.subscribe("grounded", _on_grounded)

	arch = cs.register_archetype(["CameraComponent", "CameraEffectsComponent"])


func update(delta):
	for e in arch.entities:
		var fx := cs.get_component(e, "CameraEffectsComponent")
		if fx == null:
			continue

		# ========= SHAKE (энергия + жизнь)
		if fx.shake_life > 0.0:
			fx.shake_life -= delta
			fx.shake_time += delta * 8.0

			var nx := sin(fx.shake_time * 1.7)
			var ny := sin(fx.shake_time * 2.3 + 10.0)

			fx.shake_offset = Vector3(nx, ny, 0.0) * fx.shake_strength

			# плавное затухание амплитуды
			fx.shake_strength *= exp(-fx.shake_decay * delta)
		else:
			fx.shake_offset = Vector3.ZERO
			fx.shake_strength = 0.0


		# ========= DROP (пружина, масса)
		var stiffness := 45.0
		var damping   := 10.0

		var accel = -fx.drop_offset * stiffness
		accel -= fx.drop_velocity * damping

		fx.drop_velocity += accel * delta
		fx.drop_offset   += fx.drop_velocity * delta


		# ========= KICK
		fx.kick_pitch = move_toward(fx.kick_pitch, 0.0, 12.0 * delta)
		fx.kick_yaw   = move_toward(fx.kick_yaw,   0.0, 12.0 * delta)


		# ========= FOV
		# ========= FOV (пружина, масса)
		var fov_stiffness := 30.0
		var fov_damping   := 7.0

		var fov_accel = -fx.fov_offset * fov_stiffness
		fov_accel -= fx.fov_velocity * fov_damping

		fx.fov_velocity += fov_accel * delta
		fx.fov_offset   += fx.fov_velocity * delta




func _on_grounded(data: Dictionary) -> void:
	var e_id: int = data.entity
	var impact: float = abs(data.velocity_y)

	if impact < 1.0:
		return

	var cam_e := -1
	for c in arch.entities:
		if cs.get_component(c, "CameraComponent").owner_id == e_id:
			cam_e = c
			break

	if cam_e == -1:
		return

	var fx := cs.get_component(cam_e, "CameraEffectsComponent")

	var power :float= clamp(impact * 0.05, 0.0, 1.0)

	# ========= SHAKE
	fx.shake_strength = max(fx.shake_strength, power * 0.2)
	fx.shake_life     = max(fx.shake_life, 0.25 + power * 0.35)

	# ========= DROP
	fx.drop_velocity -= power * 16.0

	# ========= FOV IMPULSE (короткий zoom-out)
	fx.fov_velocity -= power * 100.0

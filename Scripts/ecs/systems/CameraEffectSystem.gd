extends BaseSystem
class_name CameraEffectSystem


func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus):
	super._init(_entity_manager,_component_store,_event_bus)
	event_bus.subscribe("grounded", _on_grounded)
func update(delta):
	var entities = get_entities_with([
		"CameraEffectsComponent"
	])

	for e in entities:
		var fx := cs.get_component(e, "CameraEffectsComponent")

		# Shake
		if fx.shake_strength > 0.001:
			fx.shake_offset = Vector3(
				randf_range(-1, 1),
				randf_range(-1, 1),
				0
			) * fx.shake_strength

			fx.shake_strength = lerp(
				fx.shake_strength,
				0.0,
				fx.shake_decay * delta
			)
		else:
			fx.shake_offset = Vector3.ZERO

		# Kick decay
		fx.kick_pitch = lerp(fx.kick_pitch, 0.0, 20.0 * delta)
		fx.kick_yaw   = lerp(fx.kick_yaw,   0.0, 20.0 * delta)

		# FOV
		fx.fov_offset = lerp(fx.fov_offset, 0.0, 10.0 * delta)

func _on_grounded(data: Dictionary) -> void:
	var e_id :int= data.entity
	var impact = data.impact

	# находим камеру, которая смотрит на эту энтити
	var cam_e :int
	var cameras = get_entities_with(["CameraComponent"])
	for _cam_e in cameras:
		if cs.get_component(_cam_e, "CameraComponent").owner_id == e_id:
			cam_e = _cam_e


	var fx := cs.get_component(cam_e, "CameraEffectsComponent")

	fx.shake_strength += clamp(impact * 0.05, 0.1, 0.6)
	fx.kick_pitch    += clamp(impact * 0.01, 0.05, 0.25)

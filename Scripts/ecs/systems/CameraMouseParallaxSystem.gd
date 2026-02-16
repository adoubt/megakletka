extends BaseSystem
class_name CameraMouseParallaxSystem



var player_arch: Archetype
func _init(_em, _cs, _bus):
	super._init(_em, _cs, _bus)
	arch = cs.register_archetype(["CameraComponent","CameraEffectsComponent"])
	player_arch = cs.register_archetype(["InputComponent","PlayerComponent"])
func update(delta):
	for e in arch.entities:
		var fx = cs.get_component(e, "CameraEffectsComponent")
		
		var camera_comp = cs.get_component(e, "CameraComponent")
		var player_look = cs.get_component(camera_comp.owner_id, "InputComponent").look
		

		# mouse delta уже относительный
		
		fx.mouse_velocity += player_look * fx.parallax_strength

		

		var accel = -fx.mouse_offset * fx.parallax_stiffness
		accel -= fx.mouse_velocity * fx.parallax_smooth

		fx.mouse_velocity += accel * delta
		fx.mouse_offset += fx.mouse_velocity * delta

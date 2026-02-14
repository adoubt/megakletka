extends BaseSystem
class_name ItemIdleFloatSystem

func _init(_em: EntityManager, _cs: ComponentStore, _bus: EventBus):
	super._init(_em, _cs, _bus)

	arch = cs.register_archetype(
		["RenderComponent", "AnimationComponent"]
	)

func update(delta):
	for e in arch.entities:
		var render = cs.get_component(e, "RenderComponent")
		if not render or not render.instance:
			continue

		var anim = cs.get_component(e, "AnimationComponent")
		if anim.type != AnimationType.FLOAT:
			continue

		var instance = render.instance

		if instance.is_highlighted:
			continue

	

		if not anim.started:
			anim.base_y = instance.model.position.y
			anim.phase = randf() * TAU
			anim.started = true

		anim.time += delta
		var target_y = anim.base_y + sin(anim.time * anim.speed + anim.phase) * anim.amplitude
		var current_y = instance.model.position.y

		instance.model.position.y = lerp(
			current_y,
			target_y,
			delta * anim.smooth_speed
)

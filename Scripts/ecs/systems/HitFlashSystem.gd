extends BaseSystem
class_name HitFlashSystem

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)
	arch = cs.register_archetype(["EnemyComponent","HitFlashComponent", "RenderComponent"],
		["DeadComponent"])
	
func update(delta: float) -> void:
	var entities = arch.entities.duplicate()
	for e in entities:
		var flash = cs.get_component(e, "HitFlashComponent")
		var render = cs.get_component(e, "RenderComponent")
		if not render.instance:
			continue

		if not flash.started:
			render.instance.set_flash_material(render.hit_flash_material)
			cs.add_component(e, "ScaleRequestComponent",
				ScaleRequestComponent.new(flash.scale))
			flash.started = true

		flash.time_left -= delta

		if flash.time_left <= 0.0:
			render.instance.clear_flash_material()
			cs.add_component(e, "ScaleRequestComponent",
				ScaleRequestComponent.new())
			cs.remove_component(e, "HitFlashComponent")

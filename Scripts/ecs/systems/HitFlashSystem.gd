extends BaseSystem
class_name HitFlashSystem


func update(delta: float) -> void:
	var entities = get_entities_with(["HitFlashComponent", "RenderComponent"])

	for e in entities:
		var flash = cs.get_component(e, "HitFlashComponent")
		var render = cs.get_component(e, "RenderComponent")

		if not flash.started:
			render.instance.material_override.next_pass = render.hit_flash_material

		flash.time_left -= delta

		if flash.time_left <= 0.0:
			render.instance.material_override.next_pass = null
			cs.remove_component(e, "HitFlashComponent")

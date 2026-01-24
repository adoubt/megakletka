extends BaseSystem
class_name HitVFXSystem

func update(_delta:float) -> void:
	var entites = get_entities_with(["HitVFXComponent"], ["DeadComponent"])
	for e in entites:
		
		var hit_vfx = cs.get_component(e,"HitVFXComponent")
		
		if not hit_vfx.started: 
			var instance = cs.get_component(e,"RenderComponent").instance
			if instance: 
				instance.shot()
				hit_vfx.started = true
			
		if not hit_vfx.followed: 
			continue
		var owner_tf = cs.get_component(hit_vfx.owner_id, "TransformComponent")
		if not owner_tf:
			continue
		cs.get_component(e, "TransformComponent").position = owner_tf.position
			

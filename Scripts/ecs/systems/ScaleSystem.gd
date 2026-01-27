extends BaseSystem
class_name ScaleSystem
const SHADOW_RESIZE: float = 0.7
const PLAYER_HIGHLIGHT: float = 1.9
const ENEMY_HIGHLIGHT: float = 0.8

func update(_delta: float) -> void:
	var entities: Array = get_entities_with(["ScaleRequestComponent"], ["DeadComponent"])
	
	for e in entities:
		var render = cs.get_component(e, "RenderComponent")
		var col = cs.get_component(e, "CollisionComponent")
		var scale_req = cs.get_component(e, "ScaleRequestComponent")
		if not col or not render:
			continue
		if not render.instance:
			continue
		var higtlight = 1.0
		if cs.has_component(e,"EnemyComponent"):
			higtlight = ENEMY_HIGHLIGHT
		elif cs.has_component(e, "PlayerComponent"):
			higtlight = PLAYER_HIGHLIGHT
		var final_scale = col.radius * scale_req.mult_scale
		if scale_req.debug_mode:
			if not col.debug_collider:
				continue
			col.debug_collider.mesh.radius = final_scale
			col.debug_collider.mesh.height = final_scale*2
		
		render.instance.scale = Vector3.ONE * final_scale * higtlight
		if render.shadow and render.shadow_instance:
			render.shadow_instance.mesh.size = Vector2(col.radius,col.radius) * SHADOW_RESIZE * scale_req.mult_scale * higtlight
		cs.remove_component(e, "ScaleRequestComponent")
		
		

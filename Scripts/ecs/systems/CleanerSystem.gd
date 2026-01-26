extends BaseSystem
class_name CleanerSystem
var object_pool : ObjectPool

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus, _object_pool:ObjectPool):
	super._init(_entity_manager, _component_store, _event_bus)
	object_pool = _object_pool
	
func update(_delta: float):
	var entities = get_entities_with(["DeadComponent"],["RespawnableComponent"])
	for entity_id in entities:
		var dead = cs.get_component(entity_id,"DeadComponent")
		
		if dead.decay_time <=0:
			
			if cs.has_component(entity_id, "RenderComponent"):
				var render = cs.get_component(entity_id, "RenderComponent")
				if render.instance:
					
					object_pool.release_instance(render.scene_path, render.instance)
					
					if cs.has_component(entity_id,"HitFlashComponent"):
						render.instance.material_override.next_pass = null
				if render.shadow_instance:
					object_pool.release_instance("res://Scenes/shadow.tscn", render.shadow_instance)
			var collision = cs.get_component(entity_id, "CollisionComponent")
			if collision and collision.debug_collider:
				object_pool.release_instance(collision.debug_collider_scene_path,collision.debug_collider)
				collision.debug_collider = null
			
			cs.remove_all_components_for_entity(entity_id)
			

			
			em.destroy_entity(entity_id)
		else:
			dead.decay_time -= _delta

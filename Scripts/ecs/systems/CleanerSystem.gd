extends BaseSystem
class_name CleanerSystem
var pool_system : ObjectPool

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _pool_system:ObjectPool):
	super._init(_entity_manager, _component_store)
	pool_system = _pool_system
	
func update(_delta: float):
	var entities = get_entities_with(["DeadComponent"])
	for entity_id in entities:
		var dead = cs.get_component(entity_id,"DeadComponent")
		if dead.decay_time <=0:
			# Вернуть render-узел в пул
			if cs.has_component(entity_id, "RenderComponent"):
				var render = cs.get_component(entity_id, "RenderComponent")
				if render.instance:
					pool_system.return_to_pool(render.scene_path, render.instance)
			
			# ✅ Сначала удаляем компоненты
			cs.remove_all_components_for_entity(entity_id)

			# ✅ Потом удаляем сущность
			em.destroy_entity(entity_id)
		else:
			dead.decay_time -= _delta

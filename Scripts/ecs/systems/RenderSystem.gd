# RenderSystem.gd
extends BaseSystem
class_name RenderSystem


var pool_system: ObjectPool
var smoothness := 1.0 # чем больше, тем быстрее догоняет (в кадрах/сек)
var root_node: Node


func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _root_node :Node3D, _pool_system:ObjectPool):
	super._init(_entity_manager, _component_store)
	root_node = _root_node
	pool_system = _pool_system
	
func update(delta: float) -> void:
	var entities = get_entities_with(["TransformComponent", "RenderComponent"])

	for entity_id in entities:

		var transform = cs.get_component(entity_id, "TransformComponent")
		var render = cs.get_component(entity_id, "RenderComponent")
	
		# Создаём сцену, если ещё не создана
		if render.instance == null:
			render.instance = pool_system.get_from_pool(render.scene_path)
		
		if  cs.get_component(entity_id, "ControllerStateComponent"): 
			continue
		# Обновляем Transform
		
		render.instance.global_position = render.instance.global_position.lerp(transform.position, clamp(delta * smoothness, 0, 1))
		
		
		#render.instance.global_position = transform.position
		#render.instance.rotation = transform.rotation
		render.instance.scale = transform.scale

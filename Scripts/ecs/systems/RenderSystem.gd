# RenderSystem.gd
extends BaseSystem
class_name RenderSystem

var root_node: Node
func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _root_node):
	super._init(_entity_manager, _component_store)
	root_node = _root_node
	
func update(delta: float) -> void:
	var entities = entity_manager.get_entities_with("TransformComponent", "RenderComponent")

	for entity_id in entities:
		var transform = component_store.get_component(entity_id, "TransformComponent")
		var render = component_store.get_component(entity_id, "RenderComponent")

		# Создаём сцену, если ещё не создана
		if not render.instance:
			var scene_res = load(render.scene_path)
			render.instance = scene_res.instantiate()
			root_node.add_child(render.instance)

		# Обновляем Transform
		render.instance.global_transform.origin = transform.position
		render.instance.rotation_degrees = transform.rotation
		render.instance.scale = transform.scale

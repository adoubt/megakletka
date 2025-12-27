# RenderSystem.gd
extends BaseSystem
class_name RenderSystem


var pool_system: ObjectPool
var smoothness := 30.0 # чем больше, тем быстрее догоняет (в кадрах/сек)


func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _pool_system:ObjectPool):
	super._init(_entity_manager, _component_store)
	pool_system = _pool_system
	
func update(_delta: float) -> void:
	var entities = get_entities_with(["TransformComponent", "RenderComponent"],["DeadComponent"])

	for entity_id in entities:

		var transform = cs.get_component(entity_id, "TransformComponent")
		var render = cs.get_component(entity_id, "RenderComponent")
	
		# Создаём сцену, если ещё не создана
		if render.instance == null:
			render.instance = pool_system.get_instance(render.scene_path)
			render.instance.global_position = transform.position
		if  cs.get_component(entity_id, "ControllerStateComponent"): 
			continue

		render.instance.global_position = render.instance.global_position.lerp(transform.position, clamp(_delta * smoothness, 0, 1))
		render.instance.scale = render.instance.scale.lerp(render.scale, clamp(_delta * smoothness, 0, 1))
		var target = cs.get_component(entity_id, "TargetComponent")
		if target and target.target_id !=-1:
			var target_pos = cs.get_component(target.target_id, "TransformComponent")
			render.instance.look_at(target_pos.position)

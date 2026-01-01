# RenderSystem.gd
extends BaseSystem
class_name RenderSystem


const SHADOW_Y := 0.05
const SHADOW_SCENE : String = "res://Scenes/shadow.tscn"
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

		if render.shadow and render.shadow_instance == null:
			render.shadow_instance = pool_system.get_instance(SHADOW_SCENE)
			var base_mesh:QuadMesh = render.shadow_instance.mesh
			render.shadow_instance.mesh = base_mesh.duplicate()
			var col := cs.get_component(entity_id, "CollisionComponent")
			if col:
				render.shadow_instance.mesh.size = Vector2(col.radius,col.radius)
			else: 
				render.shadow_instance.mesh.size = Vector2(0.5,0.5)
	
		_update_shadow(render.shadow_instance, transform)
		
		if  cs.get_component(entity_id, "ControllerStateComponent"): 
			continue

		render.instance.global_position = render.instance.global_position.lerp(transform.position, clamp(_delta * smoothness, 0, 1))
		render.instance.scale = render.instance.scale.lerp(render.scale, clamp(_delta * smoothness, 0, 1))
		var target = cs.get_component(entity_id, "TargetComponent")
		if target and target.target_id !=-1:
			var target_pos = cs.get_component(target.target_id, "TransformComponent")
			render.instance.look_at(target_pos.position)
			
func _update_shadow(shadow: Node3D, tf) -> void:
	if not shadow:
		return

	shadow.global_position.x = tf.position.x
	shadow.global_position.z = tf.position.z
	shadow.global_position.y = SHADOW_Y
		

# RenderSystem.gd
extends BaseSystem
class_name RenderSystem


const SHADOW_Y := 0.05
const SHADOW_SCENE : String = "res://Scenes/shadow.tscn"
const FLASH_HIT_MATERIAL := preload("res://assets/Materials/flash_hit.tres")
var object_pool: ObjectPool
var smoothness := 15.0 # чем больше, тем быстрее догоняет (в кадрах/сек)


func _init(_entity_manager: EntityManager, _component_store: ComponentStore,  _event_bus: EventBus, _object_pool:ObjectPool):
	super._init(_entity_manager, _component_store, _event_bus)
	object_pool = _object_pool
	
func update(_delta: float) -> void:
	var entities = get_entities_with(["TransformComponent", "RenderComponent"],["DeadComponent"])
	
	for entity_id in entities:
		var render = cs.get_component(entity_id, "RenderComponent")
		
		var transform = cs.get_component(entity_id, "TransformComponent")
		
		
		# Создаём сцену, если ещё не создана
		if render.instance == null:
			
			render.instance = object_pool.get_instance(render.scene_path)
			render.instance.global_position = transform.position
			render.instance.visible = false
			if cs.has_component(entity_id,"EnemyComponent"):
				var mat = render.instance.material_override
				if mat:
					mat = mat.duplicate()
				else:
					mat = StandardMaterial3D.new()

				render.instance.material_override = mat

				# делаем УНИКАЛЬНЫЙ next_pass
				render.hit_flash_material = FLASH_HIT_MATERIAL.duplicate()
				
		var target = cs.get_component(entity_id, "MovementIntentComponent")
		if target:
			var target_pos = target.direction * 1000
			if target_pos != Vector3.ZERO:
				render.instance.look_at(target_pos)
				render.instance.rotate_y(PI)	
			
		if render.shadow and render.shadow_instance == null:
			render.shadow_instance = object_pool.get_instance(SHADOW_SCENE)
			var base_mesh:QuadMesh = render.shadow_instance.mesh
			render.shadow_instance.mesh = base_mesh.duplicate()
			var col := cs.get_component(entity_id, "CollisionComponent")
			if col:
				render.shadow_instance.mesh.size = Vector2(col.radius,col.radius)
			else: 
				render.shadow_instance.mesh.size = Vector2(0.5,0.5)
	
		_update_shadow(render.shadow_instance, transform)
		
		#if  cs.has_component(entity_id, "PlayerComponent"): 
				#render.instance.visible = true
				#continue
		
		render.instance.global_position = render.instance.global_position.lerp(transform.position, clamp(_delta * smoothness, 0, 1))
		#render.instance.scale = render.instance.scale.lerp(render.scale, clamp(_delta * smoothness, 0, 1))
		render.instance.scale = render.scale
		
		
		
		if render.time_to_render > 0.0:
				render.time_to_render -=_delta
				render.instance.visible = true
				continue	
func _update_shadow(shadow: Node3D, tf) -> void:
	if not shadow:
		return

	shadow.global_position.x = tf.position.x
	shadow.global_position.z = tf.position.z
	shadow.global_position.y = SHADOW_Y
		

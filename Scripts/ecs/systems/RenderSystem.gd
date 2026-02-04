# RenderSystem.gd
extends BaseSystem
class_name RenderSystem


const SHADOW_OFFSET := 0.05
const SHADOW_SCENE : String = "res://Scenes/shadow.tscn"
const FLASH_HIT_MATERIAL := preload("res://assets/Materials/flash_hit.tres")
var object_pool: ObjectPool
var smoothness := 15.0 #
var ground: GroundHeightComponent

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,  _event_bus: EventBus, _object_pool:ObjectPool):
	super._init(_entity_manager, _component_store, _event_bus)
	object_pool = _object_pool
	event_bus.subscribe("ground_generated", _on_ground_generated)
	arch = cs.register_archetype(["TransformComponent", "RenderComponent"],["DeadComponent"])
		
func update(_delta: float) -> void:
	
	for entity_id in arch.entities:
		var render = cs.get_component(entity_id, "RenderComponent")
		
		var transform = cs.get_component(entity_id, "TransformComponent")
		
		
		# Создаём сцену, если ещё не создана
		if render.instance == null:
			
			render.instance = object_pool.get_instance(render.scene_path)
			render.instance.global_position = transform.position
			render.instance.visible = false
			if cs.has_component(entity_id,"EnemyComponent"):
				render.instance.ensure_unique_base_material()

				
				# делаем УНИКАЛЬНЫЙ next_pass
				render.hit_flash_material = FLASH_HIT_MATERIAL
			cs.add_component(entity_id, "ScaleRequestComponent", ScaleRequestComponent.new())	
		var target = cs.get_component(entity_id, "MovementIntentComponent")
		if target:
			var target_pos = target.direction * 1000
			if target_pos != Vector3.ZERO:
				render.instance.look_at(target_pos)
				render.instance.rotate_y(PI)	
			
		if render.shadow and render.shadow_instance == null:
			render.shadow_instance = object_pool.get_instance(SHADOW_SCENE)
			render.shadow_instance.visible = true
			var base_mesh:QuadMesh = render.shadow_instance.mesh
			render.shadow_instance.mesh = base_mesh.duplicate()
			cs.add_component(entity_id, "ScaleRequestComponent", ScaleRequestComponent.new())
	
		_update_shadow(render.shadow_instance, transform, _delta)
		
		#if  cs.has_component(entity_id, "PlayerComponent"): 
				#render.instance.visible = true
				#continue
		
		render.instance.global_position = render.instance.global_position.lerp(transform.position, clamp(_delta * smoothness, 0, 1))
		
		if render.time_to_render > 0.0:
				render.time_to_render -=_delta
				render.instance.visible = true
				
				continue	
func _update_shadow(shadow: Node3D, tf, _delta) -> void:
	if not shadow:
		return

	shadow.global_position.x = lerp(shadow.global_position.x, tf.position.x, clamp(_delta * smoothness, 0, 1))
	shadow.global_position.z = lerp(shadow.global_position.z, tf.position.z, clamp(_delta * smoothness, 0, 1))
	shadow.global_position.y = ground.get_height(tf.position.x, tf.position.z) + SHADOW_OFFSET

func _on_ground_generated(data: Dictionary) ->void:
	ground = data.ground

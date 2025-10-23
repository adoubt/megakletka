extends BaseSystem
class_name MovementSystem

var root_node: Node3D

var climb_check_distance := 1.0
var climb_check_height_offset := 0.2
var climb_speed := 2.0
var ground_mask := (1 << 0) | (1 << 1) | (1 << 2)
var min_distance_to_climb := 1.5 # не карабкаемся, если слишком близко
var knockback_distance := 5.0 # на сколько "откидывает"
var knockback_trigger_distance := 0.5 # ближе этого – откидывает


func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _root_node: Node3D):
	super._init(_entity_manager, _component_store)
	root_node = _root_node


func update(delta: float) -> void:
	var entities = get_entities_with([
		"TransformComponent",
		"TargetComponent",
		"MoveSpeedComponent"
	])

	if entities.is_empty():
		return

	var space_state = root_node.get_world_3d().direct_space_state

	for entity_id in entities:
		var tf = cs.get_component(entity_id, "TransformComponent")
		
		var target = cs.get_component(entity_id, "TargetComponent")
		var speed_comp = cs.get_component(entity_id, "MoveSpeedComponent")

		if tf == null or target == null or speed_comp == null:
			continue

		if target.target_id == -1:
			continue

		var target_tf = cs.get_component(target.target_id, "TransformComponent")
		if target_tf == null:
			continue
		var render = cs.get_component(entity_id,"RenderComponent")
		if render.instance:
			render.instance.look_at(target_tf.position,Vector3.UP) 
			render.instance.rotate_y(PI)
		var dir = target_tf.position - tf.position
		var dist = dir.length()
		if dist <= 0.7:
			continue

		var dir_norm = dir.normalized()
		var move_speed = speed_comp.final_value 

		## --- 1️⃣ Откидывание ---
		#if dist < knockback_trigger_distance:
			#tf.position -= dir_norm * knockback_distance
			#continue

		# --- 2️⃣ Простое движение ---
		if dist < min_distance_to_climb:
			tf.position += dir_norm * move_speed * delta
			continue
		
		## --- 3️⃣ Проверка препятствий ---
		var origin : Vector3 = tf.position + Vector3.UP * climb_check_height_offset
		var target_pos :Vector3 = origin + dir_norm * climb_check_distance

		var query :PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
		query.from = origin
		query.to = target_pos
		query.collision_mask = ground_mask
 

		var result = space_state.intersect_ray(query)

		if result.size() > 0:
			var normal: Vector3 = result.normal
			if abs(normal.y) < 0.3:
				tf.position.y += climb_speed * delta
			else:
				tf.position += dir_norm * move_speed * delta
		else:
			tf.position += dir_norm * move_speed * delta
		
		
		

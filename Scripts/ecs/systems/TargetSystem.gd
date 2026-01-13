extends BaseSystem
class_name TargetSystem

func update(_delta: float) -> void:
	var entities := get_entities_with([
	"TargetRequestComponent"],["AimComponent","DeadComponent"])

	for e_id in entities:
		
		var tf = cs.get_component(e_id, "TransformComponent")
		if not tf:
			var weapon = cs.get_component(e_id, "WeaponComponent")
			if weapon:
				tf = cs.get_component(weapon.owner_id, "TransformComponent")
				
		var req: TargetRequestComponent = cs.get_component(e_id, "TargetRequestComponent")

		var best_pos: Vector3 = Vector3.ZERO
		var best_dist: float = req.radius * req.radius
		var found := false

		var candidates := _get_candidates(req.target_layers)

		for c_id in candidates:
			if c_id == e_id:
				continue
			if cs.has_component(c_id, "DeadComponent"):
				continue

			var c_tf: TransformComponent = cs.get_component(c_id, "TransformComponent")
			if c_tf == null:
				continue

			var d : float = tf.position.distance_squared_to(c_tf.position)
			if d < best_dist:
				best_dist = d
				best_pos = c_tf.position
				found = true

		if found:
			cs.add_component(e_id, "AimComponent", AimComponent.new(best_pos))
			if req.one_shot:
				cs.remove_component(e_id, "TargetRequestComponent")

			
func _get_candidates(target_layers: int) -> Array:
	var result: Array = []

	if (target_layers & CollisionLayers.PLAYER) != 0:
		result += get_entities_with(["PlayerComponent", "TransformComponent"])

	if (target_layers & CollisionLayers.ENEMY) != 0:
		result += get_entities_with(["EnemyComponent", "TransformComponent"])

	return result

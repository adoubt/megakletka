extends BaseSystem
class_name TargetSystem

const CAMERA_ASSIST_DOT := 0.82

const TARGET_Y_OFFSET := 0.0
const ORIGIN_Y_OFFSET := 0.0


func update(_delta: float) -> void:
	var entities := get_entities_with(
		["TargetRequestComponent"],
		["AimComponent", "DeadComponent"]
	)

	for e_id in entities:
		var req: TargetRequestComponent = cs.get_component(e_id, "TargetRequestComponent")
		if req == null:
			continue


		var weapon: WeaponComponent = cs.get_component(e_id, "WeaponComponent")
		var owner_id :int= weapon.owner_id if weapon else e_id

		var owner_tf: TransformComponent = cs.get_component(owner_id, "TransformComponent")
		if owner_tf == null:
			continue

		var origin := owner_tf.position + Vector3(0, ORIGIN_Y_OFFSET, 0)


		var use_camera := req.target_type == TargetType.CAMERA_ASSIST
		var cam_forward := Vector3.ZERO

		if use_camera and weapon:
			for cam_e in get_entities_with(["CameraComponent"]):
				var cam := cs.get_component(cam_e, "CameraComponent")
				if cam.owner_id == owner_id:
				
					cam_forward = -cam.forward.normalized()
					break

			if cam_forward == Vector3.ZERO:
				use_camera = false # fallback в AUTO


		var best_pos := Vector3.ZERO
		var best_dot := -1.0
		var best_dist := req.radius * req.radius
		var found := false

		var candidates := _get_candidates(req.target_layers)

		for c_id in candidates:
			if c_id == owner_id:
				continue
			if cs.has_component(c_id, "DeadComponent"):
				continue

			var c_tf: TransformComponent = cs.get_component(c_id, "TransformComponent")
			if c_tf == null:
				continue

			
			var target_pos := c_tf.position + Vector3(0, TARGET_Y_OFFSET, 0)
			
			var to_target := target_pos -origin
			var dist_sq := to_target.length_squared()

			if dist_sq > best_dist:
				continue

			if use_camera:
				var dir := to_target.normalized()
				var dot := cam_forward.dot(dir)

				if dot < CAMERA_ASSIST_DOT:
					continue

			
				if dot > best_dot or (dot == best_dot and dist_sq < best_dist):
					best_dot = dot
					best_dist = dist_sq
					best_pos = target_pos
					found = true
			else:

				if dist_sq < best_dist:
					best_dist = dist_sq
					best_pos = target_pos
					found = true

		if found:
			cs.add_component(e_id, "AimComponent", AimComponent.new(best_pos))
		else: continue
		if req.one_shot:
			cs.remove_component(e_id, "TargetRequestComponent")


func _get_candidates(target_layers: int) -> Array:
	var result: Array = []

	if (target_layers & CollisionLayers.PLAYER) != 0:
		result += get_entities_with(
			["PlayerComponent", "TransformComponent"],
			["DeadComponent"]
		)

	if (target_layers & CollisionLayers.ENEMY) != 0:
		result += get_entities_with(
			["EnemyComponent", "TransformComponent"],
			["DeadComponent"]
		)

	return result

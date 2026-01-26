extends BaseSystem
class_name FireSystem

func update(_delta: float) -> void:
	var weapons : Array = get_entities_with(["FireRequestComponent"],["DeadComponent"])
	for weapon_id in weapons:
		var weapon = cs.get_component(weapon_id, "WeaponComponent")
		
		if weapon.target in [TargetType.CAMERA_ASSIST, TargetType.NORMAL] and not cs.has_component(weapon_id,"AimComponent"):
			
			continue
		match weapon.name:
			"fire_shard":
				_fire_projectile(weapon.owner_id, weapon_id,weapon.target)
			"ice_shard":
				_fire_projectile(weapon.owner_id, weapon_id,weapon.target)
			"carrot":
				_fire_orbit(weapon.owner_id, weapon_id)

		cs.remove_component(weapon_id, "FireRequestComponent")


func _compute_stats(owner_id: int, weapon_id: int) -> Dictionary:
	var data: Dictionary = {"owner_id": owner_id}

	var comp: Object
	
	comp = cs.get_component(owner_id, "BounceComponent")
	var owner_bounce: float = comp.final_value if comp else 0.0
	comp = cs.get_component(weapon_id, "BounceComponent")
	var weapon_bounce: float = comp.final_value if comp else 0.0
	if owner_bounce + weapon_bounce > 0:
		data["bounce"] = int(owner_bounce + weapon_bounce)
		
	comp = cs.get_component(owner_id, "PierceComponent")
	var owner_pierce: float = comp.final_value if comp else 0.0
	comp = cs.get_component(weapon_id, "PierceComponent")
	var weapon_pierce: float = comp.final_value if comp else 0.0
	if owner_pierce + weapon_pierce > 0:
		data["pierce"] = int(owner_pierce + weapon_pierce)
		
	comp = cs.get_component(owner_id, "ProjectileCountComponent")
	var owner_proj_count: float = comp.final_value if comp else 0.0
	comp = cs.get_component(weapon_id, "ProjectileCountComponent")
	var weapon_proj_count: float = comp.final_value if comp else 0.0
	if owner_proj_count + weapon_proj_count > 0:
		data["projectile_count"] = int(owner_proj_count + weapon_proj_count)

	data["damage"] = cs.get_component(owner_id, "DamageComponent").final_value * cs.get_component(weapon_id, "DamageComponent").final_value

	comp = cs.get_component(owner_id, "ProjectileRadiusComponent")
	var owner_proj_radius: float = comp.final_value if comp else 1.0
	comp = cs.get_component(weapon_id, "ProjectileRadiusComponent")
	var weapon_proj_radius: float = comp.final_value if comp else 1.0
	if owner_proj_radius != 1.0 or weapon_proj_radius != 1.0:
		data["projectile_radius"] = owner_proj_radius * weapon_proj_radius

	comp = cs.get_component(owner_id, "DurationComponent")
	var owner_duration: float = comp.final_value if comp else 1.0
	comp = cs.get_component(weapon_id, "DurationComponent")
	var weapon_duration: float = comp.final_value if comp else 1.0
	data["duration"] =  owner_duration * weapon_duration

	comp = cs.get_component(owner_id, "WeaponRadiusComponent")
	var owner_weapon_radius: float = comp.final_value if comp else 0.0
	comp = cs.get_component(weapon_id, "WeaponRadiusComponent")
	var weapon_radius: float = comp.final_value if comp else 0.0
	if owner_weapon_radius + weapon_radius > 0:
		data["weapon_radius"] = owner_weapon_radius * weapon_radius

	
	
	data["projectile_speed"] = (cs.get_component(owner_id, "ProjectileSpeedComponent").final_value *
		cs.get_component(weapon_id, "ProjectileSpeedComponent").final_value)

	data["is_enemy"] = cs.has_component(owner_id, "EnemyComponent")

	var render: Dictionary = _collect_render(weapon_id)
	if render.size() > 0:
		data["render"] = render

	return data


func _collect_render(weapon_id: int) -> Dictionary:
	var comp: Object = cs.get_component(weapon_id, "RenderComponent")
	if comp == null:
		return {}
	return {"path": comp.scene_path, "shadow": comp.shadow}


func _base_projectile_data(stats: Dictionary, position: Vector3) -> Dictionary:
	var data: Dictionary = {
		"owner_id": stats.owner_id,
		"position": position
	}
	if stats.has("bounce"):
		data["bounce"] = stats.bounce
	if stats.has("damage"):
		data["damage"] = stats.damage	
	if stats.has("pierce"):
		data["pierce"] = stats.pierce
	if stats.has("projectile_speed"):
		data["projectile_speed"] = stats.projectile_speed
	if stats.has("projectile_radius"):
		data["projectile_radius"] = stats.projectile_radius
	if stats.has("weapon_radius"):
			data["weapon_radius"]= stats.weapon_radius
	if stats.has("duration"):
		data["duration"] = stats.duration

	if stats.is_enemy:
		data["collision_layer"] = CollisionLayers.ENEMY_PROJECTILE
		data["collision_mask"] = CollisionLayers.PLAYER
	else:
		data["collision_layer"] = CollisionLayers.PLAYER_PROJECTILE
		data["collision_mask"] = CollisionLayers.ENEMY

	if stats.has("render"):
		data["render_path"] = stats.render.get("path", "")
		data["render_shadow"] = stats.render.get("shadow", false)
		data["render_scale"] = Vector3.ONE * stats.projectile_radius

	return data


func _fire_orbit(owner_id: int, weapon_id: int) -> void:
	var owner_tf = cs.get_component(owner_id, "TransformComponent")
	if owner_tf == null:
		return

	var stats: Dictionary = _compute_stats(owner_id, weapon_id)
	if not stats.has("projectile_count") or stats.projectile_count <= 0:
		return

	var data_array: Array = []

	for i in range(stats.projectile_count):
		var angle: float = TAU * float(i) / float(stats.projectile_count)
		var pos: Vector3 = owner_tf.position + Vector3(
			cos(angle) * stats.weapon_radius,
			0.2,
			sin(angle) * stats.weapon_radius
		)

		var d: Dictionary = _base_projectile_data(stats, pos)
		d["move_type"] = ProjectileMoveType.ORBIT
		d["orbit_radius"] = stats.weapon_radius
		d["orbit_speed"] = stats.projectile_speed
		d["orbit_angle"] = angle
		d["orbit_height"] = 0.2

		data_array.append(d)

	event_bus.emit("create_projectile", data_array)


func _fire_projectile(owner_id: int, weapon_id: int, aim: int) -> void:
	var owner_tf := cs.get_component(owner_id, "TransformComponent")
	if owner_tf == null:
		return

	var stats: Dictionary = _compute_stats(owner_id, weapon_id)
	if stats.projectile_count <= 0:
		return

	var aim_comp: AimComponent = cs.get_component(weapon_id, "AimComponent")
	if aim_comp == null:
		return

	var from: Vector3 = owner_tf.position + Vector3(0.0,0.7,0.0)
	var to: Vector3 = aim_comp.position 

	var data_array: Array = []

	for i in range(stats.projectile_count):
		var d := _base_projectile_data(stats, from)
		d["move_type"] = ProjectileMoveType.LINEAR

		if (aim & (TargetType.NORMAL | TargetType.CAMERA_ASSIST)) != 0:
			d["direction"] = (to - from).normalized()
			
		data_array.append(d)

	cs.remove_component(weapon_id, "AimComponent")
	event_bus.emit("create_projectile", data_array)

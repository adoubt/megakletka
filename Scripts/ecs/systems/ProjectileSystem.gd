extends BaseSystem
class_name ProjectileSystem

func update(delta: float) -> void:
	var entities = get_entities_with("Projectile", "ProjectileStats", "Transform")
	
	for entity_id in entities:
		var proj = cs.get_component(entity_id, "Projectile")
		var stats = cs.get_component(entity_id, "ProjectileStats")
		var transform = cs.get_component(entity_id, "Transform")
		if proj == null or stats == null or transform == null:
			continue

		# --- Homing behaviour ---
		if stats.homing_enabled:
			var target_pos = _find_nearest_target(transform.position, stats.chain_range)
			if target_pos != null:
				var desired = (target_pos - transform.position).normalized()
				proj.direction = proj.direction.lerp(desired, stats.homing_strength * delta).normalized()

		# --- Move projectile ---
		transform.position += proj.direction * proj.speed * delta

		# --- Lifetime ---
		proj.lifetime += delta
		if proj.lifetime >= stats.duration:
			_destroy_projectile(entity_id)
			continue

		# --- Collision check ---
		var hit_target = _check_collision(transform.position)
		if hit_target != null:
			_on_hit(entity_id, hit_target)


# -------------------
func _check_collision(pos: Vector3) -> int:
	for target_id in get_entities_with(["Target", "Transform"]):
		var target_tf = cs.get_component(target_id, "Transform")
		if target_tf == null:
			continue
		if pos.distance_to(target_tf.position) < 20.0: # фейковый радиус
			return target_id
	return -1


func _on_hit(projectile_id: int, target_id: int) -> void:
	var proj = cs.get_component(projectile_id, "Projectile")
	var stats = cs.get_component(projectile_id, "ProjectileStats")
	if proj == null or stats == null:
		return

	# Apply damage через ECS
	var dmg = PendingDamageComponent.new()
	dmg.source = proj.owner_id
	dmg.amount = stats.damage  # берем из ProjectileStats
	cs.add_component(target_id, "PendingDamageComponent", dmg)

	# Chain / bounce
	if stats.projectile_bounces > 0:
		stats.projectile_bounces -= 1
		var current_tf = cs.get_component(projectile_id, "Transform")
		var new_target = _find_nearest_target(current_tf.position, stats.chain_range, [target_id])
		if new_target != null:
			proj.direction = (new_target - current_tf.position).normalized()
			return

	# Если нет отскоков — уничтожаем
	_destroy_projectile(projectile_id)


func _destroy_projectile(entity_id: int) -> void:
	cs.remove_component(entity_id, "Projectile")
	cs.remove_component(entity_id, "Transform")
	em.destroy_entity(entity_id)


func _find_nearest_target(origin: Vector3, range: float, exclude: Array = []) -> Vector3:
	var best_pos = null
	var best_dist = range
	for target_id in get_entities_with("Target", "Transform"):
		if target_id in exclude:
			continue
		var tf = cs.get_component(target_id, "Transform")
		if tf == null:
			continue
		var dist = origin.distance_to(tf.position)
		if dist < best_dist:
			best_dist = dist
			best_pos = tf.position
	return best_pos

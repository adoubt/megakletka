# res://ecs/systems/ProjectileSystem.gd
extends BaseSystem
class_name ProjectileSystem


## Called every frame
func update(delta: float):
	for entity_id in entity_manager.entities.keys():
		var proj = component_store.get_component(entity_id, "Projectile")
		if proj == null:
			continue

		var stats = component_store.get_component(entity_id, "ProjectileStats")
		var transform = component_store.get_component(entity_id, "Transform")
		if transform == null:
			continue

		# --- Homing behaviour ---
		if stats.homing_enabled:
			var target_pos = _find_nearest_target(transform.position, stats.chain_range)
			if target_pos != null:
				var desired = (target_pos - transform.position).normalized()
				proj.direction = proj.direction.lerp(desired, stats.homing_strength * delta)
				proj.direction = proj.direction.normalized()

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


## Simulate simple collision (in practice — Physics query or overlap)
func _check_collision(pos: Vector3):
	for target_id in entity_manager.entities.keys():
		if component_store.get_component(target_id, "Target") == null:
			continue
		var target_tf = component_store.get_component(target_id, "Transform")
		if target_tf == null:
			continue
		if pos.distance_to(target_tf.position) < 20.0: # fake radius
			return target_id
	return null


## Handle projectile hit
func _on_hit(projectile_id: int, target_id: int):
	var stats = component_store.get_component(projectile_id, "ProjectileStats")
	var proj = component_store.get_component(projectile_id, "Projectile")
	if stats == null or proj == null:
		return

	# Apply damage
	var dmg = PendingDamageComponent.new()
	dmg.source = proj.owner_id
	dmg.amount = 10.0  # from weapon stats, ideally
	component_store.add_component(target_id, "Damage", dmg)

	# Try to chain to next target if we have bounces left
	if stats.projectile_bounces > 0:
		stats.projectile_bounces -= 1
		var current_tf = component_store.get_component(projectile_id, "Transform")
		var new_target = _find_nearest_target(current_tf.position, stats.chain_range, [target_id])
		if new_target != null:
			var new_dir = (new_target - current_tf.position).normalized()
			proj.direction = new_dir
			return

	# If no bounces left — destroy
	_destroy_projectile(projectile_id)


## Destroy projectile entity
func _destroy_projectile(entity_id: int):
	component_store.remove_component(entity_id, "Projectile")
	component_store.remove_component(entity_id, "Transform")
	entity_manager.destroy_entity(entity_id)


## Find nearest target (can be used both for homing and chaining)
func _find_nearest_target(origin: Vector3, range: float, exclude: Array = []) -> Vector3:
	var best_pos: Vector3 = Vector3.ZERO
	var best_dist = range
	for target_id in entity_manager.entities.keys():
		if target_id in exclude:
			continue
		if component_store.get_component(target_id, "Target") == null:
			continue
		var tf = component_store.get_component(target_id, "Transform")
		if tf == null:
			continue
		var dist = origin.distance_to(tf.position)
		if dist < best_dist:
			best_dist = dist
			best_pos = tf.position
	return best_pos

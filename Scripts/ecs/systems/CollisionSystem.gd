extends BaseSystem
class_name CollisionSystem

func update(_delta: float) -> void:
	var entities = get_entities_with(["TransformComponent", "CollisionComponent"])
	if entities.size() < 2:
		return

	for i in range(entities.size()):
		var a_id = entities[i]
		var a_tf = cs.get_component(a_id, "TransformComponent")
		var a_col = cs.get_component(a_id, "CollisionComponent")
		if a_tf == null or a_col == null:
			continue

		for j in range(i+1, entities.size()):
			var b_id = entities[j]
			var b_tf = cs.get_component(b_id, "TransformComponent")
			var b_col = cs.get_component(b_id, "CollisionComponent")
			if b_tf == null or b_col == null:
				continue

			# --- фильтрация по слоям ---
			if (a_col.collision_mask & b_col.collision_layer) == 0 and (b_col.collision_mask & a_col.collision_layer) == 0:
				continue

			# --- проверка пересечения сфер ---
			var dist = a_tf.position.distance_to(b_tf.position)
			var radius_sum = a_col.radius + b_col.radius
			if dist < radius_sum:
				# --- отскок для динамических ---
				handle_overlap(a_id, b_id, dist, radius_sum)

				# --- обработка урона ---
				handle_damage(a_id, b_id)

func handle_overlap(a_id: int, b_id: int, dist: float, radius_sum: float) -> void:
	var a_tf = cs.get_component(a_id, "TransformComponent")
	var b_tf = cs.get_component(b_id, "TransformComponent")
	var dir = (a_tf.position - b_tf.position).normalized()
	var overlap = radius_sum - dist

	# только для динамических объектов (можно расширить)
	var a_col = cs.get_component(a_id, "CollisionComponent")
	var b_col = cs.get_component(b_id, "CollisionComponent")
	if a_col.type == "dynamic" and b_col.type == "dynamic":
		a_tf.position += dir * (overlap * 0.5)
		b_tf.position -= dir * (overlap * 0.5)
	elif a_col.type == "dynamic":
		a_tf.position += dir * overlap
	elif b_col.type == "dynamic":
		b_tf.position -= dir * overlap

func handle_damage(a_id: int, b_id: int) -> void:
	var a_has_damage = cs.has_component(a_id, "PendingDamageComponent")
	var b_has_damage = cs.has_component(b_id, "PendingDamageComponent")
	
	var a_stats = cs.get_component(a_id, "CurrentHpComponent")
	var b_stats = cs.get_component(b_id, "CurrentHpComponent")

	# Если A наносит урон B
	if a_has_damage and b_stats:
		var dmg_src = cs.get_component(a_id, "PendingDamageComponent")
		if not cs.has_component(b_id, "PendingDamageComponent"):
			cs.add_component(b_id, "PendingDamageComponent", PendingDamageComponent.new())
		var pd = cs.get_component(b_id, "PendingDamageComponent")
		pd.amount  = dmg_src.amounts
		pd.source_id = dmg_src.source_id
		pd.execute_chance = dmg_src.execute_chance
		pd.pierce = dmg_src.pierce

	# Если B наносит урон A
	if b_has_damage and a_stats:
		var dmg_src = cs.get_component(b_id, "PendingDamageComponent")
		if not cs.has_component(a_id, "PendingDamageComponent"):
			cs.add_component(a_id, "PendingDamageComponent", PendingDamageComponent.new())
		var pd = cs.get_component(a_id, "PendingDamageComponent")
		pd.amount = dmg_src.amount
		pd.source_id = dmg_src.source_id
		pd.execute_chance = dmg_src.execute_chance
		pd.pierce = dmg_src.pierce

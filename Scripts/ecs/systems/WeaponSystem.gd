extends BaseSystem
class_name WeaponSystem


func update(delta: float) -> void:
	var entities = get_entities_with(["WeaponComponent"]) # или TransformComponent

	for weapon_id in entities:
		
		var weapon = cs.get_component(weapon_id, "WeaponComponent")
		if not weapon:
			continue
		weapon.cd_timer = max(weapon.cd_timer - delta, 0.0)
		if weapon.cd_timer > 0.0:
			continue	
		
		match weapon.name:
			"cheese":
				spawn_cheese(weapon.owner_id, weapon_id)
			"dexecutioner":
				spawn_dexecutioner(weapon.owner_id, weapon_id)
		
		weapon.cd_timer = weapon.cd / max(cs.get_component(weapon_id,"AttackSpeedComponent").final_value * cs.get_component(weapon.owner_id,"AttackSpeedComponent").final_value, 0.001)



func spawn_cheese(owner_id: int, weapon_id: int) -> void:
	# 1️⃣ Удаляем старые орбитальные топоры владельца
	var existing = get_entities_with(["ProjectileComponent", "OrbitComponent"])
	for e in existing:
		var proj = cs.get_component(e, "ProjectileComponent")
		if proj.owner_id == owner_id and proj.move_type == "orbit":
			cs.add_component(e, "DeadComponent", DeadComponent.new())

	# 2️⃣ Берём количество топоров из компонента оружия
	var projectile_count = cs.get_component(weapon_id, "ProjectileCountComponent")
	var count = projectile_count.final_value
	if count <= 0:
		return

	var weapon_dmg = cs.get_component(weapon_id, "DamageComponent").final_value
	var weapon_render = null
	if cs.has_component(weapon_id, "RenderComponent"):
		weapon_render = cs.get_component(weapon_id, "RenderComponent").scene_path

	var owner_tf = cs.get_component(owner_id, "TransformComponent")

	# 3️⃣ Спавним новое количество топоров
	for i in range(count):
		var axe_id = em.create_entity()

		# 🔹 Damage
		cs.add_component(axe_id, "PendingDamageComponent", PendingDamageComponent.new())
		var dmg = cs.get_component(axe_id, "PendingDamageComponent")
		dmg.amount = weapon_dmg
		dmg.source_id = owner_id

		# 🔹 Collision
		cs.add_component(axe_id, "CollisionComponent",
			CollisionComponent.new(0.7, 4, 2, "projectile"))

		# 🔹 Render
		if weapon_render:
			cs.add_component(axe_id, "RenderComponent", RenderComponent.new(weapon_render))

		# 🔹 Projectile
		var proj = ProjectileComponent.new()
		proj.move_type = "orbit"
		proj.owner_id = owner_id
		proj.lifetime = 3 # effectively infinite
		cs.add_component(axe_id, "ProjectileComponent", proj)

		# 🔹 Orbit
		var orbit = OrbitComponent.new()
		orbit.radius = 1.5
		orbit.speed = 3.0
		orbit.offset_angle = (TAU * i) / count
		orbit.angle = orbit.offset_angle
		cs.add_component(axe_id, "OrbitComponent", orbit)

		# 🔹 Transform (стартовая позиция)
		var x = cos(orbit.offset_angle) * orbit.radius
		var z = sin(orbit.offset_angle) * orbit.radius
		cs.add_component(axe_id, "TransformComponent",
			TransformComponent.new(owner_tf.position + Vector3(x, 1.5, z)))

		

# --- Dexecutioner: прямой удар с шансом на execute ---
func spawn_dexecutioner(owner_id: int, weapon_id: int) -> void:
	var dex_id = em.create_entity()
	
	cs.add_component(dex_id, "CollisionComponent", CollisionComponent.new(0.5, 4, 2, "projectile"))
	cs.add_component(dex_id, "PendingDamageComponent", PendingDamageComponent.new())
	if cs.has_component(weapon_id,"RenderComponent"):
		cs.add_component(dex_id ,"RenderComponent",RenderComponent.new(cs.get_component(weapon_id,"RenderComponent").scene_path))
	var dmg = cs.get_component(dex_id, "PendingDamageComponent")
	dmg.amount = cs.get_component(weapon_id,"DamageComponent").final_value
	dmg.source_id = owner_id
	dmg.execute_chance = 0.05 # 5% 
	dmg.pierce = true
	
	# Устанавливаем позицию около владельца
	var owner_tf = cs.get_component(owner_id, "TransformComponent")
	var new_pos = owner_tf.position + Vector3(1,0,1)
	cs.add_component(dex_id, "TransformComponent", TransformComponent.new(new_pos))
	cs.add_component(dex_id,"ProjectileComponent", ProjectileComponent.new())

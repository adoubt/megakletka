extends BaseSystem
class_name WeaponSystem


func update(delta: float) -> void:
	var entities = get_entities_with(["WeaponComponent"]) # или TransformComponent

	for weapon_id in entities:
		
		var weapon = cs.get_component(weapon_id, "WeaponComponent")
		if not weapon:
			continue
		# ✅ Проверяем владельца
		var owner_id = weapon.owner_id
		if owner_id == -1:
			continue
		if cs.has_component(owner_id, "DeadComponent"):
			continue
			
		weapon.cd_timer = max(weapon.cd_timer - delta, 0.0)
		if weapon.cd_timer > 0.0:
			continue	
		
		match weapon.name:
			"cheese":
				spawn_cheese(weapon.owner_id, weapon_id)
			"dexecutioner":
				spawn_dexecutioner(weapon.owner_id, weapon_id)
		
		# Берём скорость атаки владельца
		var attack_speed = 1.0
		if cs.has_component(owner_id, "AttackSpeedComponent"):
			attack_speed = cs.get_component(owner_id,"AttackSpeedComponent").final_value

		weapon.cd_timer = weapon.cd / max(attack_speed, 0.001)



func spawn_cheese(owner_id: int, weapon_id: int) -> void:
	# 1) Помечаем старые орбитальные снаряды владельца как Dead
	var existing = get_entities_with(["ProjectileComponent", "OrbitComponent"])
	for e in existing:
		var p = cs.get_component(e, "ProjectileComponent")
		if p != null and p.owner_id == owner_id and p.move_type == "orbit":
			if not cs.has_component(e, "DeadComponent"):
				cs.add_component(e, "DeadComponent", DeadComponent.new(0.0))

	# 2) Берём count

	var count = int(cs.get_component(weapon_id, "ProjectileCountComponent").final_value
	) * int(cs.get_component(owner_id, "ProjectileCountComponent").final_value) 
	
	if count <= 0:
		return


	var	damage_value = cs.get_component(weapon_id, "DamageComponent").final_value * cs.get_component(owner_id, "DamageComponent").final_value

	var render_path = null
	if cs.has_component(weapon_id, "RenderComponent"):
		var rcomp = cs.get_component(weapon_id, "RenderComponent")
		if rcomp != null:
			render_path = rcomp.scene_path

	# Хит: если у владельца нет Transform — выходим
	var owner_tf = cs.get_component(owner_id, "TransformComponent")
	if owner_tf == null:
		return

	# 3) Спавним новые снаряды (равномерно по окружности)
	for i in range(count):
		var ent_id = em.create_entity()

		# --- PendingDamageComponent ---
		var dmg_comp := DamageComponent.new()
		# используем поле amount (если у тебя другое имя — замени)
		dmg_comp.final_value = damage_value

		## --- CollisionComponent ---
		#var col_comp := CollisionComponent.new(
		#CollisionLayers.Layer.PLAYER_PROJECTILE,
		#CollisionLayers.Layer.ENEMY | CollisionLayers.Layer.WORLD,
		#0.2
		#)
		# --- CollisionComponent ---
		var col_comp := CollisionComponent.new(
		CollisionLayers.Layer.ENEMY_PROJECTILE,
		CollisionLayers.Layer.PLAYER | CollisionLayers.Layer.WORLD,
		0.5
		)

		# --- ProjectileComponent ---
		var proj_comp := ProjectileComponent.new()
		proj_comp.move_type = "orbit"
		proj_comp.owner_id = owner_id
		
		var lifetime = LifetimeComponent.new(1.0)
		# --- OrbitComponent ---
		var orbit_comp := OrbitComponent.new()
		

		orbit_comp.radius = cs.get_component(weapon_id,"WeaponRadiusComponent").final_value * cs.get_component(owner_id,"WeaponRadiusComponent").final_value
		var a = cs.get_component(weapon_id,"ProjectileSpeedComponent").final_value
		var b = cs.get_component(owner_id,"ProjectileSpeedComponent").final_value 
		orbit_comp.speed = cs.get_component(weapon_id,"ProjectileSpeedComponent").final_value * cs.get_component(owner_id,"ProjectileSpeedComponent").final_value 
		orbit_comp.height = 0.5
		orbit_comp.offset_angle = (TAU * float(i)) / float(max(1, count))
		orbit_comp.angle = orbit_comp.offset_angle

		# --- TransformComponent (инициализация и позиция) ---
		var t_comp := TransformComponent.new()
		var x = cos(orbit_comp.offset_angle) * orbit_comp.radius
		var z = sin(orbit_comp.offset_angle) * orbit_comp.radius
		t_comp.position = owner_tf.position + Vector3(x, orbit_comp.height, z)

		# --- RenderComponent (если есть) ---
		var r_comp = null
		if render_path != null:
			r_comp = RenderComponent.new(render_path)

		# --- Добавляем компоненты пачкой в понятном порядке ---
		cs.add_component(ent_id, "TransformComponent", t_comp)
		cs.add_component(ent_id, "DamageComponent", dmg_comp)
		cs.add_component(ent_id, "CollisionComponent", col_comp)
		cs.add_component(ent_id, "ProjectileComponent", proj_comp)
		cs.add_component(ent_id, "OrbitComponent", orbit_comp)
		cs.add_component(ent_id,"LifetimeComponent",  lifetime)
		if r_comp != null:
			cs.add_component(ent_id, "RenderComponent", r_comp)

		
		

# --- Dexecutioner: прямой удар с шансом на execute ---
func spawn_dexecutioner(owner_id: int, weapon_id: int) -> void:
	var dex_id = em.create_entity()
	
	
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
	var col_comp := CollisionComponent.new(
		CollisionLayers.Layer.PLAYER_PROJECTILE,
		CollisionLayers.Layer.ENEMY | CollisionLayers.Layer.WORLD,
		0.2
		)
	cs.add_component(dex_id, "TransformComponent", TransformComponent.new(new_pos))
	cs.add_component(dex_id,"ProjectileComponent", ProjectileComponent.new())
	cs.add_component(dex_id,"LifetimeConponent", LifetimeComponent.new())
	cs.add_component(dex_id, "CollisionComponent", col_comp)

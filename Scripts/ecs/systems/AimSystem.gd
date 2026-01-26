extends BaseSystem
class_name AimSystem

func update(_delta):
	var weapons = get_entities_with(
		["WeaponComponent", "AimRequestComponent"],
		["AimComponent", "DeadComponent"]
	)

	for weapon_id in weapons:
		var weapon := cs.get_component(weapon_id, "WeaponComponent")

		match weapon.target:
			TargetType.NORMAL:
				_resolve_auto_target(weapon_id, weapon)

			TargetType.CAMERA_ASSIST:
				_resolve_camera_assist(weapon_id, weapon)

		cs.remove_component(weapon_id, "AimRequestComponent")


func _resolve_auto_target(weapon_id: int, weapon: WeaponComponent)->  void:

	var is_enemy_weapon = cs.has_component(weapon.owner_id,"EnemyComponent")			 
	var weapon_radius: float = (cs.get_component(weapon.owner_id, "WeaponRadiusComponent").final_value * 
	cs.get_component(weapon_id, "WeaponRadiusComponent").final_value)
	
	cs.add_component(weapon_id, "TargetRequestComponent",TargetRequestComponent.new(
		weapon_radius,
		CollisionLayers.PLAYER if is_enemy_weapon else CollisionLayers.ENEMY,
		true, TargetType.NORMAL))

func _resolve_camera_assist(weapon_id: int, weapon: WeaponComponent) -> void:
	var is_enemy_weapon = cs.has_component(weapon.owner_id, "EnemyComponent")

	var weapon_radius: float = (
		cs.get_component(weapon.owner_id, "WeaponRadiusComponent").final_value *
		cs.get_component(weapon_id, "WeaponRadiusComponent").final_value
	)

	# просто говорим TargetSystem:
	# "ищи цель, но с учетом камеры"
	cs.add_component(
		weapon_id,
		"TargetRequestComponent",
		TargetRequestComponent.new(
			weapon_radius,
			CollisionLayers.PLAYER if is_enemy_weapon else CollisionLayers.ENEMY, true,
			TargetType.CAMERA_ASSIST # <-- ВАЖНО
		)
	)

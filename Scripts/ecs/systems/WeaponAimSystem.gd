extends BaseSystem
class_name WeaponAimSystem


func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus):
	super._init(_entity_manager,_component_store,_event_bus)
	
	arch = cs.register_archetype(["WeaponComponent", "WeaponRadiusComponent","AimRequestComponent"],
		["DeadComponent"])
	
	
func update(_delta):
	var weapons = arch.entities.duplicate()
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

	cs.add_component(
		weapon_id,
		"TargetRequestComponent",
		TargetRequestComponent.new(
			weapon_radius,
			CollisionLayers.PLAYER if is_enemy_weapon else CollisionLayers.ENEMY, true,
			TargetType.CAMERA_ASSIST # <-- ВАЖНО
		)
	)

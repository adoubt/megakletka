extends BaseSystem
class_name WeaponSystem

var combat := false

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,  _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)

	event_bus.subscribe("combat_started", _start_combat)
	event_bus.subscribe("combat_completed", _finish_combat)
	
func _start_combat(_data) -> void:
	combat = true
func _finish_combat(_data)-> void:
	combat = false	
	

func update(delta: float) -> void:
	#if not combat:
		#return
	var weapons = get_entities_with(["WeaponComponent"], ["FireRequestComponent","DeadComponent"])

	for weapon_id in weapons:
		var weapon = cs.get_component(weapon_id, "WeaponComponent")
		var owner_id = weapon.owner_id
		
		if cs.has_component(owner_id, "DeadComponent"):
			cs.add_component(weapon_id, "DeadComponent", DeadComponent.new())
			continue
			

		weapon.cd_timer = max(weapon.cd_timer - delta, 0.0)
		if weapon.cd_timer > 0.0 :
			continue
			
		cs.add_component(weapon_id, "AimRequestComponent", AimRequestComponent.new())
		
		cs.add_component(weapon_id, "FireRequestComponent", FireRequestComponent.new(owner_id))
		
		var atk_speed = cs.get_component(owner_id, "AttackSpeedComponent")
		##TODO something wrong here
		if not atk_speed:
			cs.add_component(weapon_id, "DeadComponent", DeadComponent.new())
			continue
		weapon.cd_timer = weapon.cd / max(atk_speed.final_value, 0.001)

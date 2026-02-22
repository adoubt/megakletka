extends BaseSystem
class_name MushroomSystem

func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus,):
	super._init( _entity_manager, _component_store, _event_bus)
	arch = cs.register_archetype(["MushroomEatedComponent","POIComponent"],["DeadComponent"])
	
func update(_delta:float) -> void:
	var entities = arch.entities.duplicate()
	for e_id in entities:
		var mushroom_poi = cs.get_component(e_id, "POIComponent")
		var source_id = cs.get_component(e_id, "MushroomEatedComponent").source_id
		var mult = mushroom_poi.mushroom_mult_size
		match mushroom_poi.name:
			"max_hp_mushroom":
				_eat_max_hp_mushroom(mult, source_id, e_id)
			"xp_left_mushroom":
				_eat_xp_left_mushroom(mult,source_id, e_id)
			"heal_mushroom":
				_eat_heal_mushroom(mult,source_id,e_id)
			"damage_for_current_hp_mushroom":
				_eat_damage_for_current_hp_mushroom(mult,source_id,e_id)
			_:
				printerr("Mushroom logic not founded")
		var event_e := em.create_entity()
		cs.add_component(event_e, "TriggerEventComponent", TriggerEventComponent.new(AbilityTriggers.Events.MUSHROOM_EATED,source_id))
			
		cs.add_component(e_id, "DeadComponent", DeadComponent.new())
		
func _eat_max_hp_mushroom(mult: float, source_id: int, _e_id: int):
	var base_value : float = 0.1
	var final_value = base_value * mult
	var max_hp = cs.get_component(source_id, "MaxHPComponent")

	max_hp.base_value += final_value
	cs.add_component(source_id, "DirtyStatsComponent", DirtyStatsComponent.new())

func _eat_xp_left_mushroom(mult: float,source_id, e_id: int): 
	var current_xp = cs.get_component(source_id, "CurrentXPComponent").final_value
	if current_xp <= 0.0:
		return
	
		
	var exp_reward = current_xp * mult
	var exp_to_create:= []
	const xp_per_orb : int = 1 
	for i in range(0, int(exp_reward), xp_per_orb):
		var pos: Vector3 =cs.get_component(e_id, "TransformComponent").position + Vector3(randf_range(-2.0,2.0),1.0,randf_range(-2.0,2.0))
	
		exp_to_create.append({"e_id": e_id,"position": pos, "xp_value": xp_per_orb })
		
	event_bus.emit("create_xp",exp_to_create)
func _eat_heal_mushroom(mult: float, source_id: int, _e_id: int):
	var value_to_heal:float = 0.1
	
	var max_hp = cs.get_component(source_id, "MaxHPComponent").final_value	
	var amount: float = value_to_heal * max_hp * mult
	cs.add_component(source_id,"PendingHealComponent", PendingHealComponent.new(amount))
func _eat_damage_for_current_hp_mushroom(mult: float,source_id: int, e_id: int):
	var value:float = 0.05
	var final_value = value * mult
	cs.get_component(source_id, "DamageMultComponent").base_value+= final_value
	var max_hp:float = cs.get_component(source_id, "MaxHPComponent").final_value 
	var damage_amount = max_hp * final_value
	cs.add_component(source_id, "PendingDamageComponent", PendingDamageComponent.new(damage_amount, e_id))

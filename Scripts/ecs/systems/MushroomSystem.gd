extends BaseSystem
class_name MushroomSystem

func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus,):
	super._init( _entity_manager, _component_store, _event_bus)
	arch = cs.register_archetype(["MushroomEatedComponent","POIComponent"],["DeadComponent"])
	
func update(_delta:float) -> void:
	var entities = arch.entities.duplicate()
	for e in entities:
		var mushroom_poi = cs.get_component(e, "POIComponent")
		var source_id = cs.get_component(e, "MushroomEatedComponent").source_id

		match mushroom_poi.name:
			"max_hp_mushroom":
				_eat_max_hp_mushroom(mushroom_poi,source_id)
			"xp_left_mushroom":
				_eat_xp_left_mushroom(mushroom_poi,e,source_id)
			_:
				printerr("Mushroom logic not founded")
		event_bus.emit("MUSHROOM_EATED", {"source_id": source_id})
		cs.add_component(e, "DeadComponent", DeadComponent.new())
		
func _eat_max_hp_mushroom(mushroom_poi:POIComponent,e_id: int):
	var base_value : float = 0.1
	var mult = mushroom_poi.mushroom_mult_size
	var final_value = base_value * mult
	var max_hp = cs.get_component(e_id, "MaxHPComponent")

	max_hp.base_value += final_value
	cs.add_component(e_id, "DirtyStatsComponent", DirtyStatsComponent.new())

func _eat_xp_left_mushroom(mushroom_poi:POIComponent,e, e_id: int): 
	var current_xp = cs.get_component(e_id, "CurrentXPComponent").final_value
	if current_xp <= 0.0:
		return
	var mult = mushroom_poi.mushroom_mult_size	
		
	var exp_reward = current_xp * mult
	var exp_to_create:= []
	const xp_per_orb : int = 1 
	for i in range(0, int(exp_reward), xp_per_orb):
		var pos: Vector3 =cs.get_component(e, "TransformComponent").position + Vector3(randf_range(-2.0,2.0),1.0,randf_range(-2.0,2.0))
	
		exp_to_create.append({"e_id": e_id,"position": pos, "xp_value": xp_per_orb })
		
	event_bus.emit("create_xp",exp_to_create)
	

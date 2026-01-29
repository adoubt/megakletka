extends BaseSystem
class_name MushroomSystem

func update(_delta:float) -> void:
	var entities = get_entities_with(["MushroomEatedComponent"],["DeadComponent"])
	for e in entities:
		var mushroom_poi = cs.get_component(e, "POIComponent")
		var source_id = cs.get_component(e, "MushroomEatedComponent").source_id

		match mushroom_poi.name:
			"max_hp_mushroom":
				_eat_max_hp_mushroom(source_id)
			"xp_left_mushroom":
				_eat_xp_left_mushroom(e,source_id)
			_:
				printerr("Mushroom logic not founded")
		cs.add_component(e, "DeadComponent", DeadComponent.new())
func _eat_max_hp_mushroom(e_id: int):
	var hp : float = 1
	var max_hp = cs.get_component(e_id, "MaxHpComponent")
	var current_hp = cs.get_component(e_id, "CurrentHpComponent")
	var hp_to_heal: float = (current_hp.final_value / max_hp.final_value) * hp
	max_hp.base_value += hp
	cs.add_component(e_id, "PendingHealthComponent", PendingHealthComponent.new(hp_to_heal))

func _eat_xp_left_mushroom(e, e_id: int):
	var level_comp = cs.get_component(e_id, "LevelComponent")
	var current_xp = level_comp.current_xp
	if current_xp <=0.0:
		return
	var exp_to_create:= []
	const xp_per_orb : int = 1
	for i in range(0, int(current_xp), xp_per_orb):
		var pos: Vector3 =cs.get_component(e, "TransformComponent").position + Vector3(randf_range(-2.0,2.0),1.0,randf_range(-2.0,2.0))
	
		exp_to_create.append({"e_id": e_id,"position": pos, "xp_value": xp_per_orb })
		
	event_bus.emit("create_xp",exp_to_create)
	

extends BaseSystem
class_name DayActivationSystem


var db: DataBase
var object_pool: ObjectPool
var run_entity:int=-1
func _init(_entity_manager: EntityManager, _component_store: ComponentStore,  _event_bus: EventBus,_db: DataBase,_object_pool: ObjectPool ):
	super._init(_entity_manager, _component_store, _event_bus)
	
	db = _db
	object_pool = _object_pool
	
	event_bus.subscribe("day_changed", _update_day)
	event_bus.subscribe("POI_CREATED", _update_day)
	
	
	#event_bus.subscribe("poi_interacted", _sleep)
	
func _update_day(_data: Dictionary = {}) ->void:
	if run_entity ==-1:
		run_entity = get_entities_with(["RunComponent"])[0]
	var current_day = cs.get_component(run_entity,"RunComponent").current_day
	
	_activate_poi_on_day(current_day, _data)
	
func _activate_poi_on_day(current_day:int, _data: Dictionary = {}) ->void:
	
		
	var pois = get_entities_with(["DayIdComponent", "POIComponent"],["DeadComponent"])



	
	
	for poi_id in pois:
		var day_id = cs.get_component(poi_id, "DayIdComponent").id
		var poi_name =cs.get_component(poi_id, "POIComponent").name
		if poi_name == "campfire": 
			day_id = current_day
			continue
		if day_id == current_day:
			var e_data: Dictionary = db.poi_configs[poi_name]
			cs.add_component(poi_id, "RenderComponent", RenderComponent.new(e_data["scene"]))
			
			cs.add_component(poi_id, "InteractionTargetComponent", InteractionTargetComponent.new(e_data["interact_radius"], e_data["target_priority"]))
		else:
			if cs.has_component(poi_id, "RenderComponent"):
				var render = cs.get_component(poi_id, "RenderComponent")
				if render.instance:
					object_pool.release_instance(render.scene_path, render.instance)
				if render.shadow_instance:
					object_pool.release_instance("res://Scenes/shadow.tscn", render.shadow_instance)
			
			cs.remove_component(poi_id, "RenderComponent")		
			cs.remove_component(poi_id, "CollisionComponent")	
			cs.remove_component(poi_id, "InteractionTargetComponent")

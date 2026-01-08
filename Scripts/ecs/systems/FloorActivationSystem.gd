extends BaseSystem
class_name FloorActivationSystem

var event_bus: EventBus
var db: DataBase
var object_pool: ObjectPool

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _db: DataBase, _event_bus: EventBus,_object_pool: ObjectPool ):
	super._init(_entity_manager, _component_store)
	event_bus = _event_bus
	db = _db
	object_pool = _object_pool
	
	event_bus.subscribe("floor_changed", _activate_poi_on_floor)
	event_bus.subscribe("POI_CREATED", _activate_poi_on_floor)
func _activate_poi_on_floor():
	var pois = get_entities_with(["FloorIdComponent", "POIComponent"],["DeadComponent"])
	var floors = get_entities_with([
	"FloorComponent",
	"CombatStateComponent",
	"CurrentFloorComponent"
	])

	if floors.is_empty():
		return

	var current_floor = floors[0]
	
	for poi_id in pois:
		var floor_id = cs.get_component(poi_id, "FloorIdComponent").id
		var poi_name =cs.get_component(poi_id, "POIComponent").name
		if poi_name == "wagon": 
			floor_id = current_floor
			continue
		if floor_id == current_floor:
			var data: Dictionary = db.poi_configs[poi_name]
			cs.add_component(poi_id, "RenderComponent", RenderComponent.new(data["scene"]))
			cs.add_component(poi_id, "CollisionComponent", CollisionComponent.new(
				CollisionLayers.Layer.WORLD, 
				CollisionLayers.Layer.PLAYER |
				CollisionLayers.Layer.ENEMY | 
				CollisionLayers.Layer.ENEMY_PROJECTILE |
				CollisionLayers.Layer.PLAYER_PROJECTILE,
				data["collider_radius"]))
			cs.add_component(poi_id, "InteractionTargetComponent", InteractionTargetComponent.new(data["interact_radius"], data["target_priority"]))
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

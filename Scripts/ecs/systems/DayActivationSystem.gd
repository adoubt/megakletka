extends BaseSystem
class_name DayActivationSystem

var BASE_BUDGET :float = 50
var db: DataBase
var object_pool: ObjectPool

var item_arch : Archetype
var enemy_arch: Archetype
var pick_up_arch: Archetype
func _init(_entity_manager: EntityManager, _component_store: ComponentStore,  _event_bus: EventBus,_db: DataBase,_object_pool: ObjectPool ):
	super._init(_entity_manager, _component_store, _event_bus)
	
	db = _db
	object_pool = _object_pool
	event_bus.subscribe("poi_created", _update_day)
	event_bus.subscribe("day_changed", _update_day)

	arch = cs.register_archetype(["DayComponent","POIComponent","TransformComponent"],["DeadComponent"])
	
func _update_day(data: Dictionary = {}) ->void:
	
	_activate_poi_on_day(data)
	

	
func _activate_poi_on_day(_data: Dictionary = {}) ->void:
	var poi_list := arch.entities.duplicate()
	var current_day = cs.get_component(RUN,"RunComponent").current_day
	for poi_id in poi_list:
		var day_id = cs.get_component(poi_id, "DayComponent").id
		var poi = cs.get_component(poi_id, "POIComponent")
		
		var poi_name = poi.name
		
				
			
		if day_id == current_day:
			var e_data: Dictionary = db.poi_configs[poi_name]
			var scene = e_data.get("scene", null)
			var render_comp = RenderComponent.new()
			if scene: render_comp.scene_path = scene
			var radius :float = e_data["collider_radius"]
			if poi.is_mushroom:
				radius*= poi.mushroom_mult_size
			cs.add_component(poi_id, "RenderComponent", render_comp)
			cs.add_component(poi_id, "CollisionComponent", CollisionComponent.new(
			CollisionLayers.WORLD, 
			CollisionLayers.WORLD,
			radius))
			cs.add_component(poi_id, "InteractionTargetComponent", InteractionTargetComponent.new(
				e_data.interact_radius + 0.2 * poi.mushroom_mult_size, e_data.target_priority, e_data.interact_type))
			_activate_items_for_entity(poi_id)
		else:
			if cs.has_component(poi_id, "RenderComponent"):
				var render = cs.get_component(poi_id, "RenderComponent")
				if render.instance:
					object_pool.release_instance(render.scene_path, render.instance)
				if render.shadow_instance:
					object_pool.release_instance("res://Scenes/shadow.tscn", render.shadow_instance)
			cs.remove_component(poi_id,"RenderComponent")
			cs.remove_component(poi_id, "CollisionComponent")		
			cs.remove_component(poi_id, "InteractionTargetComponent")
			_deactivate_items_for_entity(poi_id)
func _activate_items_for_entity(id : int)-> void:

	for e in item_arch.entities:
		var item_comp = cs.get_component(e, "ItemComponent")
		if item_comp.owner_id == id:
			
			var e_data: Dictionary = db.item_configs[item_comp.item_id]
			var scene = e_data.get("scene", null)
			var render_comp = RenderComponent.new()
			if scene: render_comp.scene_path = scene
			cs.add_component(e, "RenderComponent", render_comp)
			
func _deactivate_items_for_entity(id : int)-> void:

	for e in item_arch.entities:
		var item_comp = cs.get_component(e, "ItemComponent")
		if item_comp.owner_id == id:
			if cs.has_component(e, "RenderComponent"):
				var render = cs.get_component(e, "RenderComponent")
				if render.instance:
					object_pool.release_instance(render.scene_path, render.instance)
				if render.shadow_instance:
					object_pool.release_instance("res://Scenes/shadow.tscn", render.shadow_instance)
				cs.remove_component(e,"RenderComponent")
			
			



	



	

extends BaseSystem
class_name MerchantActivationSystem

var db: DataBase
var poi_arch: Archetype
var object_pool: ObjectPool

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,  _event_bus: EventBus,_db:DataBase, _object_pool: ObjectPool):
	super._init(_entity_manager, _component_store, _event_bus)
	db = _db
	object_pool = _object_pool
	arch = cs.register_archetype(["MerchantActivationRequestComponent","TransformComponent","SlotsCountComponent","POIComponent","RenderComponent"],["DeadComponent"])
	#poi_arch = cs.register_archetype(["DayComponent","POIComponent","TransformComponent"],["DeadComponent"])
	
func update(_delta:float)-> void:
	var entities = arch.entities.duplicate()
	for e in entities:

		var render = cs.get_component(e,"RenderComponent")
		if not render.instance:
			continue
			
		
		
		
		var slots = cs.get_component(e, "SlotsCountComponent")
		
		
		var items_to_create :=[]
		var pool := []
		for item_id in db.item_configs.keys():
			var poi_data = db.item_configs[item_id]
			if not poi_data.has("drop_weight"):
				continue
			var weight = poi_data.drop_weight
			for i in range(weight):
				pool.append(item_id)
		
		
		pool.shuffle()
		var chosen := []

		var slots_count: int = floor(slots.base_value)

		for item_id in pool:
	
			items_to_create.append({"owner_id": e,
			"item_id": item_id,
			"position":_get_random_position(),
			"slot_index": chosen.size()-1})
			
			chosen.append(item_id)
			if chosen.size() >= slots_count:
				break
		
		cs.remove_component(e,"MerchantActivationRequestComponent")
		event_bus.emit("create_item", items_to_create)


func _get_random_position()-> Vector3:
	var x: float = randf_range(-30.0,30.0)
	var z: float = randf_range(-30.0,30.0)
	var y: float = -1.0
	return Vector3(x,y,z)

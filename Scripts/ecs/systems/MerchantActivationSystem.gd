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
	#poi_arch = cs.register_archetype(["DayIdComponent","POIComponent","TransformComponent"],["DeadComponent"])
	
func update(_delta:float)-> void:
	var entities = arch.entities.duplicate()
	for e in entities:

		var render = cs.get_component(e,"RenderComponent")
		if not render.instance:
			continue
			
		
		
		var tf = cs.get_component(e,"TransformComponent")
		var run_comp = cs.get_component(RUN, "RunComponent")
		
		
		var slots = cs.get_component(e, "SlotsCountComponent")
		
		
		var items_to_create :=[]
		var pool := []
		for item_name in db.item_configs.keys():
			var poi_data = db.item_configs[item_name]
			if not poi_data.has("drop_weight"):
				continue
			var weight = poi_data.drop_weight
			for i in range(weight):
				pool.append(item_name)
		
		
		pool.shuffle()
		var chosen := []
		var offset: Vector3
		var slots_count: int = floor(slots.base_value)
		var follow_weight: float
		for item_name in pool:
			offset= _get_offset(chosen.size(), slots_count,tf.position, Vector3.ZERO)
			follow_weight = randf_range(0.007, 0.07)
			items_to_create.append({"owner_id": e,
			"item_name": item_name,
			"position":_get_random_position(),
			"follow_offset": offset,
			"follow_weight": follow_weight,
			"slot_index": chosen.size()})
			
			chosen.append(item_name)
			if chosen.size() >= slots_count:
				break
		
		cs.remove_component(e,"MerchantActivationRequestComponent")
		event_bus.emit("create_item", items_to_create)

func _get_offset(
	step: int,
	count: int,
	poi_pos: Vector3,
	target_pos: Vector3,
	height: float = 1.0,
	spacing: float = 0.55
) -> Vector3:

	if count <= 1:
		return Vector3(0, height, 0)

	# направление от POI к цели (костёр / центр)
	var forward := (target_pos - poi_pos).normalized()

	# перпендикуляр (ось размещения предметов)
	var right := forward.cross(Vector3.UP).normalized()

	# начало и конец линии
	var half := spacing * 0.5
	var start := -right * half
	var end   :=  right * half

	var t := float(step) / float(count - 1)
	var offset := start.lerp(end, t)

	offset.y = height
	return offset

func _get_random_position()-> Vector3:
	var x: float = randf_range(-30.0,30.0)
	var z: float = randf_range(-30.0,30.0)
	var y: float = -1.0
	return Vector3(x,y,z)

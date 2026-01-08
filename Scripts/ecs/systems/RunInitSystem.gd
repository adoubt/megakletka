extends BaseSystem
class_name RunInitSystem

var event_bus:EventBus
var db : DataBase
const ANTES := 3
const FLOORS_PER_ANTE := 5
const BASE_BATTERY := 50
const BATTERY_STEP := 20
const POI_ON_FLOOR : int = 3

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _db: DataBase, _event_bus: EventBus):
	super._init(_entity_manager, _component_store)
	event_bus = _event_bus
	db = _db
	event_bus.subscribe("run_started", _init_run)

func _init_run(data: Dictionary) -> void:
	
	var run_entity = em.create_entity()
	cs.add_component(run_entity,"RunComponent",RunComponent.new())
	cs.add_component(run_entity,"SeedComponent", SeedComponent.new(data.seed))
	cs.add_component(run_entity,"RunPhaseComponent",RunPhaseComponent.new(
		RunPhaseComponent.Phase.INIT))
	_init_floors()
	
	_init_poi()
func _init_floors()	-> void:

	var floor_index := 0

	for ante in range(ANTES):
		var ante_multiplier: float = 1+ (ante * 0.1)
		for i in range(FLOORS_PER_ANTE):
			var floor_entity = em.create_entity()
			cs.add_component(floor_entity, "FloorComponent",FloorComponent.new())
			cs.add_component(floor_entity, "FloorIdComponent",FloorIdComponent.new(floor_index+1))
			cs.add_component(floor_entity, "AnteComponent", AnteComponent.new(ante))
			cs.add_component(floor_entity, "CombatStateComponent",CombatStateComponent.new())
			if floor_index ==0: cs.add_component(floor_entity, "CurrentFloorComponent",CurrentFloorComponent.new())
			var multiplier := randf_range(0.6,0.8)
		
			##TODO modifiers here + skip rewards
			if i == 1 or i == 2:
				multiplier = randf_range(0.8,1.3)
			elif i == 3:
				multiplier = randf_range(1.3,1.8) 
			elif i == 4:
				multiplier = randf_range(1.5,2.2)	
				cs.add_component(floor_entity,"BossFloorComponent",BossFloorComponent.new())
				
			var budget: int = int(BASE_BATTERY + (floor_index*10)* multiplier * ante_multiplier)
			cs.add_component(floor_entity,"BatteryComponent",BatteryComponent.new(budget))
			
			floor_index += 1
			print("floor ", floor_index+1, ": budget ",budget)
			
	event_bus.emit("FLOORS_CREATED")		
	
	
func _init_poi() -> void:
	var entities = get_entities_with(["FloorComponent"])
	var pois_to_create := []
	for e_id in entities:
		var floor_id = cs.get_component(e_id, "FloorIdComponent").id
		var pool := []

	
		for poi_name in db.poi_configs.keys():
			var poi_data = db.poi_configs[poi_name]
			if not poi_data.has("drop_weight"):
				continue
			var weight = poi_data.get("drop_weight", 1)
			for i in range(weight):
				pool.append(poi_name)

		
		pool.shuffle()

		
		var chosen := []
		for poi_name in pool:
			var position: Vector3 = _get_random_position_in_radius()
			pois_to_create.append({"floor_id":floor_id, "poi_name":poi_name, "position": position})
			
			chosen.append(poi_name)
			if chosen.size() >= POI_ON_FLOOR:
				break
	event_bus.emit("create_pois", pois_to_create)			
	
	
func _get_random_position_in_radius(min_radius: float= 10.0, max_radius: float= 50.0) -> Vector3:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var angle := rng.randf_range(0.0, TAU)
	var radius := sqrt(rng.randf_range(min_radius * min_radius, max_radius * max_radius))

	var x := cos(angle) * radius
	var z := sin(angle) * radius

	return Vector3(x, 0.0, z)

	

	

extends BaseSystem
class_name RunInitSystem


var db : DataBase
const ANTES := 3
const DAYS_PER_ANTE := 5
const BASE_BATTERY := 50
const WORLD_SIZE : int = 75
const CELL_SIZE : float = 1.5
const POI_ON_DAY : int = 3

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus, _db: DataBase ):
	super._init(_entity_manager, _component_store, _event_bus)
	
	db = _db
	event_bus.subscribe("run_started", _init_run)
	#var run_seed = randi()
	#_init_run(run_seed)

func _init_run(data: Dictionary) -> void:
	var _seed = data.seed
	var run_entity = em.create_entity()
	cs.add_component(run_entity,"RunComponent",RunComponent.new())
	cs.add_component(run_entity,"SeedComponent", SeedComponent.new(_seed))
	cs.add_component(run_entity,"RunPhaseComponent",RunPhaseComponent.new(RunPhaseComponent.Phase.INIT))
	cs.add_component(run_entity,"GroundHeightComponent",GroundHeightComponent.new(WORLD_SIZE, WORLD_SIZE, CELL_SIZE))
	cs.add_component(run_entity,"GroundVisualComponent", GroundVisualComponent.new())
	
	_init_days(_seed)
	event_bus.emit("create_poi",[{ "poi_name": "campfire", "day_id" :0, "position": Vector3.ZERO}])
	_init_poi()
	
	event_bus.emit("create_char", [{ "camera":true, "char_name": "Rigman", "position": Vector3(-3.0,3,0)}])
	event_bus.emit("day_changed",{"current_day": 1})
	
	
func _init_days(run_seed: int) -> void:
	var day_index := 0

	for ante in range(ANTES):
		var ante_multiplier: float = 1.0 + (ante * 0.1)

		for i in range(DAYS_PER_ANTE):
			var day_entity := em.create_entity()

			# ---------- RNG ДНЯ ----------
			var day_rng := RandomNumberGenerator.new()
			day_rng.seed = run_seed + day_index * 1337

			# ---------- DAY COMPONENT ----------
			var day := DayComponent.new()

			# базовые параметры мира
			day.height_amp = day_rng.randf_range(0.0, 2.0) ## height
			day.frequency  = day_rng.randf_range(0.02, 0.9) ## flatness
			day.puddles    = day_rng.randf_range(4.3, 5.1)

			day.biome     = day_rng.randi_range(0, 2)

			# ---------- СЛОЖНОСТЬ ДНЯ ----------
			var multiplier := day_rng.randf_range(0.6, 0.8)

			if i == 1 or i == 2:
				multiplier = day_rng.randf_range(0.8, 1.3)
			elif i == 3:
				multiplier = day_rng.randf_range(1.3, 1.8)
			elif i == 4:
				multiplier = day_rng.randf_range(1.5, 2.2)
				cs.add_component(day_entity, "BossDayComponent", BossDayComponent.new())

			# усиливаем визуал вместе со сложностью
			#day.roughness *= multiplier
			#day.hills     *= ante_multiplier

			# ---------- COMPONENTS ----------
			cs.add_component(day_entity, "DayComponent", day)
			cs.add_component(day_entity, "DayIdComponent", DayIdComponent.new(day_index + 1))
			cs.add_component(day_entity, "AnteComponent", AnteComponent.new(ante))
			cs.add_component(day_entity, "CombatStateComponent", CombatStateComponent.new())
			cs.add_component(day_entity, "CombatRewardComponent", CombatRewardComponent.new(6.0))

			# ---------- BUDGET ----------
			var budget: int = int(
				BASE_BATTERY +
				(day_index * 10) * multiplier * ante_multiplier
			)

			cs.add_component(
				day_entity,
				"BatteryComponent",
				BatteryComponent.new(budget)
			)

			print(
				"day ", day_index + 1,
				" | budget ", budget,
				" | biome ", day.biome
			)

			day_index += 1

	event_bus.emit("DAYS_CREATED")

	
	
func _init_poi() -> void:
	var entities = get_entities_with(["DayComponent"])
	var pois_to_create := []
	for e_id in entities:
		var day_id = cs.get_component(e_id, "DayIdComponent").id
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
			pois_to_create.append({"day_id":day_id, "poi_name":poi_name, "position": position})

			chosen.append(poi_name)
			if chosen.size() >= POI_ON_DAY:
				break
	event_bus.emit("create_poi", pois_to_create)			
	
	
func _get_random_position_in_radius(min_radius: float= 10.0, max_radius: float= 50.0) -> Vector3:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var angle := rng.randf_range(0.0, TAU)
	var radius := sqrt(rng.randf_range(min_radius * min_radius, max_radius * max_radius))

	var x := cos(angle) * radius
	var z := sin(angle) * radius

	return Vector3(x, 0.5, z)

	

	

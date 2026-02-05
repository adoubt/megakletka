extends BaseSystem
class_name RunInitSystem


var db : DataBase
const ANTES := 3
const DAYS_PER_ANTE := 5
const BASE_BATTERY := 50
const WORLD_SIZE : int = 75
const CELL_SIZE : float = 1.5
const POI_ON_DAY : int = 1
const MUSHROOM_POI_ON_DAY: int = 40
var days_arch: Archetype
var run_seed: int
var start_day := 0
var start_balance: int = 10

func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus, _db: DataBase,_run_seed:int):
	super._init( _entity_manager, _component_store, _event_bus)
	run_seed = _run_seed
	days_arch = cs.register_archetype(["DayComponent","DayIdComponent"],["DeadComponent"])
	db = _db
	event_bus.subscribe("ecs_ready",_init_run)
	
func _init_run(_data:Dictionary ={}) -> void:
	
	
	var run_entity = em.create_entity()
	var run_comp:= RunComponent.new()
	if run_entity != RUN:
		return
	run_comp.seed = run_seed
	run_comp.current_day = start_day
	run_comp.logs = start_balance
	cs.add_component(run_entity,"RunComponent",run_comp)
	cs.add_component(run_entity,"RunPhaseComponent",RunPhaseComponent.new(RunPhaseComponent.Phase.INIT))
	cs.add_component(run_entity,"GroundHeightComponent",GroundHeightComponent.new(WORLD_SIZE, WORLD_SIZE, CELL_SIZE))
	cs.add_component(run_entity,"GroundVisualComponent", GroundVisualComponent.new())
	
	#print("RUN MASK:", entity_component_mask[run_entity])
	#print("BITS:", component_bit)
	_init_days(run_seed)
	
	
	_init_campfire()
	
	_init_poi()
	
	event_bus.emit("create_char", [{ "camera":true, "char_name": "Rigman", "position": Vector3(-3.0,3,0)}])
	
	event_bus.emit("change_day_request",{})
	event_bus.emit("balance_changed", {"current_balance": run_comp.logs, "value": run_comp.logs})
	
func _init_days(run_seed: int) -> void:
	var day_index := start_day

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
			day.height_amp = day_rng.randf_range(-2.0, 5.0) ## height
			day.frequency  = day_rng.randf_range(0.2, 0.2) ## flatness
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
			cs.add_component(day_entity, "DayIdComponent", DayIdComponent.new(day_index+1))
			cs.add_component(day_entity, "AnteComponent", AnteComponent.new(ante))
			cs.add_component(day_entity, "CombatStateComponent", CombatStateComponent.new())
			cs.add_component(day_entity, "CombatRewardComponent", CombatRewardComponent.new(6))
			
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
				"day ", day_index+1,
				" | budget ", budget,
				" | biome ", day.biome
			)

			day_index += 1

	#event_bus.emit("DAYS_CREATED")
	
func _init_campfire() -> void:
	event_bus.emit("create_poi",[{ "poi_name": "campfire", "day_id" :start_day, "position": Vector3.ZERO}])

	
func _init_poi() -> void:
	var pois_to_create := []
	var days_list = days_arch.entities.duplicate()

	for e_id in days_list:
		var day_id = cs.get_component(e_id, "DayIdComponent").id

		var pool := []
		var mushroom_pool := []

		# ===== BUILD POOL =====
		for poi_name in db.poi_configs.keys():
			var poi_data = db.poi_configs[poi_name]
			if not poi_data.has("drop_weight") or poi_data.has("mushroom"):
				continue

			for i in range(poi_data.drop_weight):
				pool.append(poi_name)

		for poi_name in db.poi_configs.keys():
			var poi_data = db.poi_configs[poi_name]
			if not poi_data.has("drop_weight") and not poi_data.has("mushroom"):
				continue

			for i in range(poi_data.drop_weight):
				mushroom_pool.append(poi_name)

		pool.shuffle()
		mushroom_pool.shuffle()

		# ===== NORMAL POI =====
		var chosen := []
		for poi_name in pool:
			var position := _get_random_position_in_radius()
			pois_to_create.append({
				"day_id": day_id,
				"poi_name": poi_name,
				"position": position
			})

			chosen.append(poi_name)
			if chosen.size() >= POI_ON_DAY:
				break

		# ===== MUSHROOMS (heal only once) =====
		chosen.clear()
		var heal_added := false

		for poi_name in mushroom_pool:
			# ❗ фильтр хилки
			if poi_name == "heal_mushroom":
				if heal_added:
					continue
				heal_added = true

			var position = _get_random_position_in_radius()
			
			var t := randf()
			var mushroom_mult_size :float= lerp(0.4, 5.0, pow(t, 2.5))

			pois_to_create.append({
				"day_id": day_id,
				"poi_name": poi_name,
				"position": position,
				"mushroom_mult_size": mushroom_mult_size
			})

			chosen.append(poi_name)
			if chosen.size() >= MUSHROOM_POI_ON_DAY:
				break

		# ===== MERCHANT =====
		var merchant_pos := _get_random_position_in_radius(3.0, 7.0)
		pois_to_create.append({
			"day_id": day_id,
			"poi_name": "merchant",
			"position": merchant_pos
		})

	event_bus.emit("create_poi", pois_to_create)

				

	
func _get_random_position_in_radius(min_radius: float= 10.0, max_radius: float= 50.0) -> Vector3:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var angle := rng.randf_range(0.0, TAU)
	var radius := sqrt(rng.randf_range(min_radius * min_radius, max_radius * max_radius))

	var x := cos(angle) * radius
	var z := sin(angle) * radius

	return Vector3(x, 0.5, z)

	

	

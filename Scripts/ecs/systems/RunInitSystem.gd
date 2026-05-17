extends BaseSystem
class_name RunInitSystem


var db : DataBase
const ANTES := 1
const DAYS_PER_ANTE := 5
const BASE_BATTERY := 50
const WORLD_SIZE : int = 150
const CELL_SIZE : float = 0.3
const POI_ON_DAY : int = 1
const MUSHROOM_POI_ON_DAY: int = 40
const MIN_COLUMNS_PER_FLOOR: int = 3
var days_arch: Archetype
var run_seed: int

var start_balance: int = 500
var floors_per_ante: int = 10
const COLUMNS_PER_FLOOR: int = 6
func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus, _db: DataBase,_run_seed:int):
	super._init( _entity_manager, _component_store, _event_bus)
	run_seed = _run_seed
	days_arch = cs.register_archetype(["DayComponent"],["DeadComponent"])
	db = _db
	event_bus.subscribe("ecs_ready",_init_run)
	
func _init_run(_data:Dictionary ={}) -> void:
	
	
	var run_entity = em.create_entity()
	var run_comp:= RunComponent.new()
	if run_entity != RUN:
		return
	run_comp.seed = run_seed
	
	run_comp.current_floor = 0
	run_comp.current_ante = 1
	run_comp.logs = start_balance
	run_comp.current_day = -1
	cs.add_component(run_entity,"RunComponent",run_comp)
	cs.add_component(run_entity,"RunPhaseComponent",RunPhaseComponent.new(RunPhaseComponent.Phase.INIT))
	cs.add_component(run_entity,"GroundHeightComponent",GroundHeightComponent.new(WORLD_SIZE, WORLD_SIZE, CELL_SIZE))
	cs.add_component(run_entity,"GroundVisualComponent", GroundVisualComponent.new())
	

	
	var lobby_id = _init_lobby()
	
	var boss_id : int
	for ante in range(1, ANTES + 1):
		boss_id = _init_days(run_seed, ante)
	
	var req:GraphGenerationRequestComponent = GraphGenerationRequestComponent.new()
	req.boss_id = boss_id
	req.lobby_id = lobby_id
	cs.add_component(RUN,"GraphGenerationRequestComponent", req)
	_init_campfire()
	
	#_init_poi()
	
	event_bus.emit("create_char", [{ "camera":true, "char_name": "Rigman", "position": Vector3(-3.0,3,0)}])
	
	
	event_bus.emit("balance_changed", {"balance": run_comp.logs, "value": run_comp.logs})

func _init_lobby() -> int:
	var e = em.create_entity()
	var day_comp :=  DayComponent.new(0,1,DayType.LOBBY,2)
	day_comp.completed = true
	cs.add_component(e, "DayComponent",day_comp)
	cs.add_component(RUN, "DaySelectRequestComponent", DaySelectRequestComponent.new(e))
	cs.add_component(e, "ReachableComponent", ReachableComponent.new())
	return e

func _init_days(run_seed: int, ante: int) -> int:
	var mid_floor := int(floors_per_ante / 2)
	var boss_id:int = -1
	for floor in range(1, floors_per_ante + 1):

		var rng := RandomNumberGenerator.new()
		rng.seed = run_seed ^ (ante << 8) ^ (floor << 4)
		
		# ---- сколько нод на этаже ----
		var node_count := rng.randi_range(MIN_COLUMNS_PER_FLOOR, COLUMNS_PER_FLOOR)

		# ---- СПЕЦ ЭТАЖИ ----
		var available_columns := []
		for i in range(COLUMNS_PER_FLOOR):
			available_columns.append(i)

		available_columns.shuffle()
		var chosen_columns := available_columns.slice(0, node_count)
		
		# первый этаж — всегда 4 врага
		if floor == 1:
			for column in chosen_columns.slice(1, 5):
				var e := em.create_entity()
				cs.add_component(
					e,
					"DayComponent",
					DayComponent.new(floor, ante, DayType.ENEMY, column)
				)
			continue

		# последний этаж — один босс
		if floor == floors_per_ante:
			var e := em.create_entity()
			cs.add_component(
				e,
				"DayComponent",
				DayComponent.new(
					floor,
					ante,
					DayType.BOSS,
					int(COLUMNS_PER_FLOOR / 2)
				)
			)
			boss_id = e
			continue
			
		if floor == floors_per_ante-1:
			for column in chosen_columns:
				var e := em.create_entity()
				cs.add_component(
					e,
					"DayComponent",
					DayComponent.new(
						floor,
						ante,
						DayType.MUSHROOMS,
						int(column)
					)
				)
			continue
			
		# серединный этаж — все сундуки
		if floor == mid_floor:
			for column in chosen_columns:
				var e := em.create_entity()
				cs.add_component(
					e,
					"DayComponent",
					DayComponent.new(floor, ante, DayType.CHEST, column)
				)
			continue
		# ---- ОБЫЧНЫЕ ЭТАЖИ ----
		for column in chosen_columns:
			
			var roll := rng.randf()
			var day_type := DayType.ENEMY

			# редкие события
			if roll < 0.03:
				day_type = DayType.MERCHANT_DEAD
			
			elif roll < 0.05:
				day_type = DayType.MERCHANT
			
			elif roll < 0.10:
				day_type = DayType.ELITE
			elif roll < 0.25:
				day_type = DayType.MUSHROOMS	
			elif roll < 0.40:
				day_type = DayType.HIDDEN
			

			

			var e := em.create_entity()
			cs.add_component(
				e,
				"DayComponent",
				DayComponent.new(floor, ante, day_type, column)
			)
	return boss_id
	
func _init_campfire() -> void:
	event_bus.emit("create_poi",[{ "poi_name": "campfire", "position": Vector3.ZERO}])
	event_bus.emit("campfire_created",{})
	
func _init_poi() -> void:
	var pois_to_create := []
	var days_list = days_arch.entities.duplicate()

	for e_id in days_list:
		var day_id = cs.get_component(e_id, "DayComponent").id

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

	

	

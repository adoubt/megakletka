extends BaseSystem
class_name DayEnterSystem

var db: DataBase
var op: ObjectPool
var item_arch : Archetype
var enemy_arch: Archetype
var pick_up_arch: Archetype
var poi_arch: Archetype
var day_arch: Archetype
func _init(_em, _cs, _bus, _db, _op):
	super._init(_em, _cs, _bus)
	db = _db
	op = _op
	arch = cs.register_archetype(
		["RunComponent", "DayEnterRequestComponent"]
	)
	item_arch = cs.register_archetype(["ItemComponent",])
	enemy_arch = cs.register_archetype(["EnemyComponent"], ["DeadComponent"])
	pick_up_arch = cs.register_archetype((["PickUpComponent"]),["DeadComponent"])
	poi_arch = cs.register_archetype(["POIComponent","TransformComponent"],["DeadComponent"])
	day_arch = cs.register_archetype(["GraphNodeComponent", "DayComponent"])
func update(_delta):
	if arch.entities.is_empty():
		return
	_clear_enemies()
	_clear_pick_ups()
	_clear_pois()
	
	var run: RunComponent = cs.get_component(RUN, "RunComponent")
	
	var req: DayEnterRequestComponent = cs.get_component(RUN, "DayEnterRequestComponent")

	var day_id :int= req.target_day
	var day: DayComponent = cs.get_component(day_id, "DayComponent")

	var day_type:int = day.type
	
	var heal_mushrooms:int  = 1
	var pois_to_create := []
	
	match day_type:
		DayType.LOBBY:
			pois_to_create.append({"poi_name": "merchant", "slots":5, "position": _get_random_position_in_radius(3.0, 7.0)})
			
			pois_to_create.append_array(_place_heal_mushroom(heal_mushrooms))
			
		DayType.BOSS:
			pois_to_create.append_array(_place_heal_mushroom(heal_mushrooms))
		DayType.ELITE:
			pois_to_create.append_array(_place_heal_mushroom(heal_mushrooms))
		DayType.ENEMY:
			
			cs.add_component(day_id, "CombatGenerationRequestComponent", CombatGenerationRequestComponent.new())
			pois_to_create.append_array(_place_heal_mushroom(heal_mushrooms))
		DayType.MERCHANT:
		
			pois_to_create.append({"poi_name": "merchant", "slots":5, "position": _get_random_position_in_radius(3.0, 7.0)})
			
		DayType.MERCHANT_DEAD:pass
		DayType.MUSHROOMS:
			pois_to_create.append_array(_place_heal_mushroom(heal_mushrooms))
			

	event_bus.emit("create_poi",pois_to_create)
	_emit_map_snapshot(run)
	event_bus.emit("day_changed",{"current_day": run.depth})
	# ---------- конец ----------
	cs.remove_component(RUN, "DayEnterRequestComponent")
		
func _place_heal_mushroom(count:int) -> Array:
	var rng :RandomNumberGenerator= RandomNumberGenerator.new()
	var mushrooms_to_create = []
	for mushroom in range(count):
		var pos_to_spawn: Vector3 =  _get_high_position(rng)
		mushrooms_to_create.append({"position": pos_to_spawn, "poi_name": "heal_mushroom"})
	return mushrooms_to_create
	
func _get_highiest_position():
	var ground = cs.get_component(RUN, "GroundHeightComponent")
	
	var max_h := -INF
	var best_x := 0
	var best_z := 0

	for z in range(ground.size_z):
		for x in range(ground.size_x):
			var i :float= x + z * ground.size_x
			var h :float= ground.heights[i]

			if h > max_h:
				max_h = h
				best_x = x
				best_z = z

	# grid → world
	var half_x :float= (ground.size_x - 1) * ground.cell_size * 0.5
	var half_z :float= (ground.size_z - 1) * ground.cell_size * 0.5

	var world_x :float= best_x * ground.cell_size - half_x
	var world_z :float= best_z * ground.cell_size - half_z

	return Vector3(world_x, max_h, world_z)

func _get_high_position(
	rng: RandomNumberGenerator,
	delta_height: float = 1.0
) -> Vector3:
	var ground := cs.get_component(RUN, "GroundHeightComponent")

	# ---------- 1. ищем максимум ----------
	var max_h := -INF
	for h in ground.heights:
		if h > max_h:
			max_h = h

	var threshold := max_h - delta_height

	# ---------- 2. собираем кандидатов ----------
	var candidates := []

	for z in range(ground.size_z):
		for x in range(ground.size_x):
			var i = x + z * ground.size_x
			if ground.heights[i] >= threshold:
				candidates.append(Vector2i(x, z))

	# fallback — если вдруг порог слишком высокий
	if candidates.is_empty():
		return _get_highiest_position()

	# ---------- 3. выбираем случайную ----------
	var pick = candidates[rng.randi_range(0, candidates.size() - 1)]

	# ---------- 4. grid → world ----------
	var half_x = (ground.size_x - 1) * ground.cell_size * 0.5
	var half_z = (ground.size_z - 1) * ground.cell_size * 0.5

	var world_x = pick.x * ground.cell_size - half_x
	var world_z = pick.y * ground.cell_size - half_z
	var world_y = ground.heights[pick.x + pick.y * ground.size_x]

	return Vector3(world_x, world_y, world_z)
func _clear_enemies():
	var entities = enemy_arch.entities.duplicate()
	for e in entities:
		cs.add_component(e, "DeadComponent", DeadComponent.new())
		
func _clear_pick_ups():
	var entities = pick_up_arch.entities.duplicate()
	for e in entities:
		cs.add_component(e, "DeadComponent", DeadComponent.new())
func _clear_pois():
	var poi_list = poi_arch.entities.duplicate()
	for poi_id in poi_list:

			var poi = cs.get_component(poi_id, "POIComponent")
			var poi_name = poi.name
					
			if poi_name == "campfire":
				continue
			
			if cs.has_component(poi_id, "RenderComponent"):
				var render = cs.get_component(poi_id, "RenderComponent")
				if render.instance:
					op.release_instance(render.scene_path, render.instance)
				if render.shadow_instance:
					op.release_instance("res://Scenes/shadow.tscn", render.shadow_instance)
			cs.remove_component(poi_id, "RenderComponent")
			cs.remove_component(poi_id, "CollisionComponent")		
			cs.remove_component(poi_id, "InteractionTargetComponent")
			_deactivate_items_for_entity(poi_id)
			
			
func _deactivate_items_for_entity(id : int)-> void:

	for e in item_arch.entities:
		var item_comp = cs.get_component(e, "ItemComponent")
		if item_comp.owner_id == id:
			if cs.has_component(e, "RenderComponent"):
				var render = cs.get_component(e, "RenderComponent")
				if render.instance:
					op.release_instance(render.scene_path, render.instance)
				if render.shadow_instance:
					op.release_instance("res://Scenes/shadow.tscn", render.shadow_instance)
				cs.remove_component(e,"RenderComponent")	

func _emit_map_snapshot(run: RunComponent) -> void:
	var snapshot := {
		"ante": run.current_ante,
		"current_day": run.current_day,
		"floors": {}
	}

	for day_id in day_arch.entities:
		var day: DayComponent = cs.get_component(day_id, "DayComponent")
		if day.ante != run.current_ante:
			continue

		if !snapshot.floors.has(day.floor):
			snapshot.floors[day.floor] = []

		var node: GraphNodeComponent = cs.get_component(day_id, "GraphNodeComponent")

		snapshot.floors[day.floor].append({
			"id": day_id,
			"column": day.column,
			"type": day.type,
			"exits": node.exits.duplicate(),
			"completed": day.completed,
		})

	event_bus.emit("map_snapshot_changed", snapshot)

func _get_random_position_in_radius(min_radius: float= 10.0, max_radius: float= 50.0) -> Vector3:
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var angle := rng.randf_range(0.0, TAU)
	var radius := sqrt(rng.randf_range(min_radius * min_radius, max_radius * max_radius))

	var x := cos(angle) * radius
	var z := sin(angle) * radius

	return Vector3(x, 0.5, z)

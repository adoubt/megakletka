extends BaseSystem
class_name GraphGenerationSystem

const MAX_EXITS := 2          # было 2 — можно чуть больше
const MIN_EXITS := 1

const MAX_RETRIES := 500
const COLUMN_RADIUS := 3     # было 1 — даём больше свободы

var run_arch
var day_arch: Archetype

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)
	run_arch = cs.register_archetype(["RunComponent","GraphGenerationRequestComponent"])
	day_arch = cs.register_archetype(["DayComponent"])

func update(_delta):
	for run_id in run_arch.entities:
		var req:= cs.get_component(run_id, "GraphGenerationRequestComponent")
		var run:= cs.get_component(run_id, "RunComponent")
		var rng := RandomNumberGenerator.new()
		rng.randomize()
		
		var success := false
		for attempt in range(MAX_RETRIES):
			_clear_graph()
			if _build_graph(rng):
				if _validate_graph():
					success = true
					break
		
		if !success:
			print_rich("[color=red][b]Graph generation failed after %d retries[/b][/color]"% MAX_RETRIES)
	
		else:
			print_rich("[color=green][b]Graph generated![/b][/color]"
)
		# Убираем запрос
		cs.remove_component(run_id, "GraphGenerationRequestComponent")
		attach_lobby_and_boss(req.lobby_id, req.boss_id, run.current_ante)
# ────────────────────────────────────────────────
# Главная функция сборки — теперь возвращает bool
# ────────────────────────────────────────────────
func _build_graph(rng: RandomNumberGenerator) -> bool:
	var days_by_ante := _collect_days_by_ante()

	for ante in days_by_ante.keys():
		var floors = days_by_ante[ante].keys()
		floors.sort()

		if floors.size() < 2:
			continue

		for i in range(floors.size() - 1):
			var cur := _sorted_by_column(days_by_ante[ante][floors[i]])
			var next := _sorted_by_column(days_by_ante[ante][floors[i + 1]])

			if not _build_skeleton(cur, next):
				return false

			if not _heal_orphans(cur, next, rng):
				return false

			_add_noise(cur, next, rng)

	return true


func _collect_days_by_ante() -> Dictionary:
	var result := {}

	for day_id in day_arch.entities:
		var day: DayComponent = cs.get_component(day_id, "DayComponent")
		if day.type == DayType.LOBBY or day.type == DayType.BOSS:
			continue

		if not result.has(day.ante):
			result[day.ante] = {}
		if not result[day.ante].has(day.floor):
			result[day.ante][day.floor] = []

		result[day.ante][day.floor].append(day_id)

		if not cs.has_component(day_id, "GraphNodeComponent"):
			cs.add_component(day_id, "GraphNodeComponent", GraphNodeComponent.new())

	return result

func _sorted_by_column(ids: Array) -> Array:
	var arr := ids.duplicate()
	arr.sort_custom(func(a, b):
		return cs.get_component(a, "DayComponent").column \
			 < cs.get_component(b, "DayComponent").column)
	return arr

func _build_skeleton(cur: Array, next: Array) -> bool:
	var cur_size := cur.size()
	var next_size := next.size()

	for n in range(next_size):
		var t = float(n) / max(1.0, float(next_size - 1))
		var from_index := int(round(t * float(cur_size - 1)))
		from_index = clamp(from_index, 0, cur_size - 1)

		_connect(cur[from_index], next[n])

	return true

func _heal_orphans(cur: Array, next: Array, rng: RandomNumberGenerator) -> bool:
	for from_id in cur:
		var node := cs.get_component(from_id, "GraphNodeComponent")
		if not node.exits.is_empty():
			continue

		var from_col = cs.get_component(from_id, "DayComponent").column
		var options := []

		for to_id in next:
			var to_col = cs.get_component(to_id, "DayComponent").column
			if abs(to_col - from_col) <= COLUMN_RADIUS:
				options.append(to_id)

		if options.is_empty():
			return false

		_connect(from_id, options.pick_random())

	return true

func _add_noise(cur: Array, next: Array, rng: RandomNumberGenerator) -> void:
	for from_id in cur:
		var from_node := cs.get_component(from_id, "GraphNodeComponent")
		if from_node.exits.size() >= MAX_EXITS:
			continue
		if rng.randf() > 0.35:
			continue

		var from_col = cs.get_component(from_id, "DayComponent").column

		var options := []
		for to_id in next:
			var to_col = cs.get_component(to_id, "DayComponent").column
			var to_node := cs.get_component(to_id, "GraphNodeComponent")

			if abs(to_col - from_col) > 0:
				continue
			if from_node.exits.has(to_id):
				continue
			if to_node.entries.size() >= 3:
				continue

			options.append(to_id)

		if not options.is_empty():
			_connect(from_id, options.pick_random())


func _validate_graph() -> bool:
	var by_ante: Dictionary = {}
	for day_id in day_arch.entities:
		
		var day: DayComponent = cs.get_component(day_id, "DayComponent")
		if day.type == DayType.LOBBY or day.type == DayType.BOSS:
			continue
		if not by_ante.has(day.ante):
			by_ante[day.ante] = []
		by_ante[day.ante].append(day_id)
	
	for ante in by_ante:
		if not _validate_ante(by_ante[ante]):
			return false
	return true

func _validate_ante(day_ids: Array) -> bool:
	var by_floor := {}

	for id in day_ids:
		var day: DayComponent = cs.get_component(id, "DayComponent")
		if not by_floor.has(day.floor):
			by_floor[day.floor] = []
		by_floor[day.floor].append(id)

	var floors = by_floor.keys()
	floors.sort()

	# минимум 1 этаж внутри
	if floors.size() < 1:
		return false

	# 1. у каждой ноды есть вход
	for floor in range(2,floors.size()-1):
		for id in by_floor[floor]:
			var node := cs.get_component(id, "GraphNodeComponent")
			
			if node.entries.is_empty():
				return false

	# 2. у каждой ноды есть выход
	for floor in floors.slice(0,-1):
		for id in by_floor[floor]:
			var node := cs.get_component(id, "GraphNodeComponent")
			if node.exits.is_empty():
				return false

	# 3. каждый этаж соединён со следующим
	for i in range(floors.size() - 1):
		var cur_floor = floors[i]
		var next_floor = floors[i + 1]

		var ok := false
		for id in by_floor[cur_floor]:
			for to in cs.get_component(id, "GraphNodeComponent").exits:
				var to_day := cs.get_component(to, "DayComponent")
				if to_day.floor == next_floor:
					ok = true
					break
			if ok:
				break

		
		if not ok: return false
	return true


func _filter_by_column(from_column: int, targets: Array, radius := COLUMN_RADIUS) -> Array:
	var result := []
	for id in targets:
		var day: DayComponent = cs.get_component(id, "DayComponent")
		if abs(day.column - from_column) <= radius:
			result.append(id)
	return result

func _connect(from_id: int, to_id: int) -> void:
	var from_node := cs.get_component(from_id, "GraphNodeComponent")
	var to_node   := cs.get_component(to_id,   "GraphNodeComponent")

	if not from_node.exits.has(to_id):
		from_node.exits.append(to_id)
	if not to_node.entries.has(from_id):
		to_node.entries.append(from_id)


func _clear_graph() -> void:
	for day_id in day_arch.entities:
		if cs.has_component(day_id, "GraphNodeComponent"):
			var node := cs.get_component(day_id, "GraphNodeComponent")
			node.exits.clear()
			node.entries.clear()


func attach_lobby_and_boss(lobby_id: int, boss_id: int, ante: int) -> void:
	cs.add_component(lobby_id, "GraphNodeComponent", GraphNodeComponent.new())
	cs.add_component(boss_id,  "GraphNodeComponent", GraphNodeComponent.new())

	var by_floor := {}
	for id in day_arch.entities:
		var day := cs.get_component(id, "DayComponent")
		if day.ante != ante:
			continue
		if not by_floor.has(day.floor):
			by_floor[day.floor] = []
		by_floor[day.floor].append(id)

	var floors := by_floor.keys()
	floors.sort()

	if floors.is_empty():
		return

	var first_floor = floors.front() +1
	var last_floor  = floors.back() -1

	for id in by_floor[first_floor]:
		_connect(lobby_id, id)

	for id in by_floor[last_floor]:
		_connect(id, boss_id)

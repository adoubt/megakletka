extends BaseSystem
class_name GraphGenerationSystem

const MAX_EXITS := 2          # было 2 — можно чуть больше
const MIN_EXITS := 1

const MAX_RETRIES := 1000
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
			push_error("Graph generation failed after %d retries" % MAX_RETRIES)
		
		# Убираем запрос
		cs.remove_component(run_id, "GraphGenerationRequestComponent")
		attach_lobby_and_boss(req.lobby_id, req.boss_id, run.current_ante)
# ────────────────────────────────────────────────
# Главная функция сборки — теперь возвращает bool
# ────────────────────────────────────────────────
func _build_graph(rng: RandomNumberGenerator) -> bool:
	var days_by_ante := {}

	for day_id in day_arch.entities:
		var day: DayComponent = cs.get_component(day_id, "DayComponent")
		if day.type == DayType.LOBBY or day.type == DayType.BOSS:
			continue
		if !days_by_ante.has(day.ante):
			days_by_ante[day.ante] = {}
		if !days_by_ante[day.ante].has(day.floor):
			days_by_ante[day.ante][day.floor] = []

		days_by_ante[day.ante][day.floor].append(day_id)

		if !cs.has_component(day_id, "GraphNodeComponent"):
			cs.add_component(day_id, "GraphNodeComponent", GraphNodeComponent.new())

	for ante in days_by_ante.keys():
		var floors = days_by_ante[ante].keys()
		floors.sort()

		for f in range(floors.size() - 1):
			var cur = days_by_ante[ante][floors[f]]
			var next = days_by_ante[ante][floors[f + 1]]

			# сортируем по колонке
			cur.sort_custom(func(a, b):
				return cs.get_component(a, "DayComponent").column < cs.get_component(b, "DayComponent").column)
			next.sort_custom(func(a, b):
				return cs.get_component(a, "DayComponent").column < cs.get_component(b, "DayComponent").column)

			# --- ШАГ 1: каждый next получает 1 вход ---
			for to_id in next:
				var to_day := cs.get_component(to_id, "DayComponent")
				var candidates := []

				for from_id in cur:
					var from_node := cs.get_component(from_id, "GraphNodeComponent")
					var from_day := cs.get_component(from_id, "DayComponent")

					if from_node.exits.size() < MAX_EXITS \
					and abs(from_day.column - to_day.column) <= COLUMN_RADIUS:
						candidates.append(from_id)

				if candidates.is_empty():
					return false

				_connect(candidates.pick_random(), to_id)
			# --- ШАГ 1.5: каждый cur должен иметь хотя бы 1 выход ---
			for from_id in cur:
				var from_node := cs.get_component(from_id, "GraphNodeComponent")
				if from_node.exits.is_empty():
					var from_day := cs.get_component(from_id, "DayComponent")
					var options := []

					for to_id in next:
						var to_day := cs.get_component(to_id, "DayComponent")
						if abs(from_day.column - to_day.column) <= COLUMN_RADIUS:
							options.append(to_id)

					if options.is_empty():
						return false

					_connect(from_id, options.pick_random())
			# --- ШАГ 2: добавляем доп. выходы ---
			for from_id in cur:
				var from_node := cs.get_component(from_id, "GraphNodeComponent")
				if from_node.exits.size() >= MAX_EXITS:
					continue

				if rng.randf() > 0.35:
					continue

				var from_day := cs.get_component(from_id, "DayComponent")
				var options := []

				for to_id in next:
					if from_node.exits.has(to_id):
						continue
					var to_day := cs.get_component(to_id, "DayComponent")
					if abs(from_day.column - to_day.column) <= COLUMN_RADIUS:
						options.append(to_id)

				if !options.is_empty():
					_connect(from_id, options.pick_random())

	return true



# ────────────────────────────────────────────────
# Валидация — улучшенная
# ────────────────────────────────────────────────
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
	for floor in floors:
		for id in by_floor[floor]:
			var node := cs.get_component(id, "GraphNodeComponent")
			if node.entries.is_empty():
				return false

	# 2. у каждой ноды есть выход
	for floor in floors:
		for id in by_floor[floor]:
			var node := cs.get_component(id, "GraphNodeComponent")
			if node.exits.is_empty():
				return false

	# 3. каждый этаж соединён со следующим
	for i in range(floors.size() - 1):
		var ok := false
		for id in by_floor[floors[i]]:
			for to in cs.get_component(id, "GraphNodeComponent").exits:
				var to_day := cs.get_component(to, "DayComponent")
				if to_day.floor == floors[i + 1]:
					ok = true
					break
			if ok:
				break
		if not ok:
			return false

	return true


func _pick_n(rng: RandomNumberGenerator, source: Array, count: int) -> Array:
	if count <= 0 or source.is_empty():
		return []
	var pool := source.duplicate()
	var result := []
	for i in range(min(count, pool.size())):
		var idx = rng.randi_range(0, pool.size() - 1)
		result.append(pool[idx])
		pool.remove_at(idx)
	return result

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

func attach_lobby_and_boss(lobby_id:int, boss_id: int, ante:int) -> void:
	
	var by_floor := {}
	cs.add_component(lobby_id, "GraphNodeComponent",GraphNodeComponent.new())
	cs.add_component(boss_id, "GraphNodeComponent",GraphNodeComponent.new())
	for id in day_arch.entities:
		
		var day := cs.get_component(id, "DayComponent")
		if day.ante != ante: continue
		if not by_floor.has(day.floor):
			by_floor[day.floor] = []
		by_floor[day.floor].append(id)

	var floors = by_floor.keys()
	floors.sort()

	# лобби → первый этаж
	for id in by_floor[floors[1]]:
		_connect(lobby_id, id)

	# последний этаж → босс
	for id in by_floor[floors.back()-1]:
		_connect(id, boss_id)

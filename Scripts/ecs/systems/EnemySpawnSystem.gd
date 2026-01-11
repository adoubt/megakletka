extends BaseSystem
class_name EnemySpawnSystem


var db: DataBase

var current_floor: int = -1
var spawning := false

# ===== НАСТРОЙКИ =====
var spawn_interval := 1.0        # как часто разрешено ДОСПАВНИВАТЬ
var spawn_timer := 0.0

const MAX_ENEMIES := 100
const BATTERY_BUDGET_RATIO := 0.5   # 50% бюджета
const MAX_PER_TICK := 10             # защита от лагов

# ====================

func _init(
	_entity_manager: EntityManager,
	_component_store: ComponentStore,
	_event_bus: EventBus,
	_db: DataBase,
	
):
	super._init(_entity_manager, _component_store,_event_bus)
	db = _db


	event_bus.subscribe("combat_started", _on_combat_started)
	event_bus.subscribe("combat_finished", _on_combat_finished)


func update(delta: float) -> void:
	if not spawning:
		return

	spawn_timer -= delta
	if spawn_timer > 0.0:
		return

	spawn_timer = spawn_interval
	_try_spawn()


# ===== ОСНОВНАЯ ЛОГИКА =====

func _try_spawn() -> void:
	var battery := cs.get_component(current_floor, "BatteryComponent")
	if battery == null:
		return

	# Текущее количество врагов
	var enemies := get_entities_with(["EnemyComponent"], ["DeadComponent"])
	var enemy_count := enemies.size()

	if enemy_count >= MAX_ENEMIES:
		return

	var max_budget_allowed :int = battery.budget * BATTERY_BUDGET_RATIO
	var available_budget :int = min(
		battery.current_budget,
		max_budget_allowed
	)

	if available_budget <= 0:
		return

	var enemies_to_create := []
	var can_spawn :int = min(
		MAX_ENEMIES - enemy_count,
		MAX_PER_TICK
	)

	for i in range(can_spawn):
		var enemy_name := _pick_enemy()
		var cost := _get_enemy_cost(enemy_name)

		if available_budget < cost:
			break

		available_budget -= cost
		battery.current_budget -= cost

		enemies_to_create.append({
			"enemy_name": enemy_name,
			"position": _get_spawn_position()
		})

	if not enemies_to_create.is_empty():
		event_bus.emit("create_enemy", enemies_to_create)


# ===== СОБЫТИЯ =====

func _on_combat_started(data: Dictionary) -> void:
	spawning = true
	current_floor = data["current_floor"]

	# 🔥 первый спавн — СРАЗУ
	spawn_timer = 0.0


func _on_combat_finished(_data: Dictionary) -> void:
	spawning = false


# ===== ВСПОМОГАТЕЛЬНОЕ =====

func _pick_enemy() -> String:
	return "Aboba" # позже: веса / сложность / этаж

func _get_enemy_cost(_enemy_name: String) -> int:
	return 2

func _get_spawn_position() -> Vector3:
	return Vector3(
		randf_range(-20.0, 20.0),
		0.5,
		randf_range(-20.0, 20.0)
	)

extends BaseSystem
class_name EnemySpawnSystem


var db: DataBase

var current_floor: int = -1
var spawning := false


var spawn_interval := 0.5      
var spawn_timer := 0.0

const MAX_ALIVE_ENEMIES := 50
const BATTERY_BUDGET_RATIO := 1   # 50% бюджета
const MAX_PER_TICK := 1            # защита от лагов

const WORLD_SIZE := Vector2(75.0, 75.0)
const MAX_SPAWN_RANGE :float = 15.0
const MIN_SPAWN_RANGE :float = 5.0
#cashe
var players: Array = []
var players_update_timer := 0.0
const PLAYERS_UPDATE_INTERVAL := 3.0
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
	event_bus.subscribe("combat_completed", _on_combat_finished)
	event_bus.subscribe("day_skipped", _on_combat_finished)

func update(delta: float) -> void:
	if not spawning:
		return

	spawn_timer -= delta
	if spawn_timer > 0.0:
		return
	players_update_timer -= delta
	if players_update_timer < 0.0 : 
		_update_players()
		players_update_timer = PLAYERS_UPDATE_INTERVAL
		
		
	spawn_timer = spawn_interval
	_try_spawn()
	
		
func _update_players() -> void:
	players = get_entities_with(
		["PlayerComponent"],
		["DeadComponent"]
	)


func _try_spawn() -> void:
	var battery := cs.get_component(current_floor, "BatteryComponent")
	if battery == null:
		return

	# Текущее количество врагов
	var enemies := get_entities_with(["EnemyComponent"], ["DeadComponent"])
	var enemy_count := enemies.size()

	if enemy_count >= MAX_ALIVE_ENEMIES:
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
		MAX_ALIVE_ENEMIES - enemy_count,
		MAX_PER_TICK
	)

	for i in range(can_spawn):
		var enemy_name := _pick_enemy()
		var cost = db.enemy_configs[enemy_name]["budget"]
		
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
	if not data.has("current_floor"):
		return
	spawning = true
	current_floor = data["current_floor"]

	# 🔥 первый спавн — СРАЗУ
	spawn_timer = 0.0


func _on_combat_finished(_data: Dictionary) -> void:
	spawning = false


# ===== ВСПОМОГАТЕЛЬНОЕ =====

func _pick_enemy() -> String:
	var keys : Array = db.enemy_configs.keys()
	return keys.pick_random()

func _get_enemy_cost(_enemy_name: String) -> int:
	return 2



func _get_spawn_position() -> Vector3:
	if players.is_empty():
		return Vector3.ZERO

	var tf = cs.get_component(players.pick_random(), "TransformComponent")
	if tf == null:
		return Vector3.ZERO

	var angle := randf() * TAU
	var r := sqrt(randf_range(MIN_SPAWN_RANGE * MIN_SPAWN_RANGE, MAX_SPAWN_RANGE * MAX_SPAWN_RANGE))

	var pos :Vector3= tf.position + Vector3(
		cos(angle) * r,
		0.5,
		sin(angle) * r
	)

	pos.x = clamp(pos.x, -WORLD_SIZE.x + 1.0, WORLD_SIZE.x - 1.0)
	pos.z = clamp(pos.z, -WORLD_SIZE.y + 1.0, WORLD_SIZE.y - 1.0)

	return pos

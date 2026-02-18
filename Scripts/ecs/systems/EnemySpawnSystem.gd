extends BaseSystem
class_name EnemySpawnSystem


var db: DataBase

var enemy_arch: Archetype




const MAX_ALIVE_ENEMIES := 200
const BATTERY_BUDGET_RATIO :float= 0.1   # 100% бюджета
const MAX_PER_TICK := 5            

const WORLD_SIZE := Vector2(75.0, 75.0)
const MAX_SPAWN_RANGE :float = 15.0
const MIN_SPAWN_RANGE :float = 5.0
#cashe
var players_update_timer := 0.0
const PLAYERS_UPDATE_INTERVAL := 3.0
# ====================
var players_arch: Archetype
var enemies_arch: Archetype
func _init(
	_entity_manager: EntityManager,
	_component_store: ComponentStore,
	_event_bus: EventBus,
	_db: DataBase,
	
):
	super._init(_entity_manager, _component_store,_event_bus)
	db = _db


	arch = cs.register_archetype(["DayComponent","CombatStateComponent","BatteryComponent"])
	
	players_arch = cs.register_archetype(["PlayerComponent"],["DeadComponent"])
	enemy_arch = cs.register_archetype(["EnemyComponent","EnemyBudgetComponent"], ["DeadComponent"])
	
func update(delta: float) -> void:
	if arch.entities.is_empty():
		return
		
	var entities = arch.entities
	for e in entities:
		var combat := cs.get_component(e, "CombatStateComponent")
		if combat.state != CombatState.ACTIVE:
			continue
			
		combat.spawn_timer -= delta
		if combat.spawn_timer > 0.0:
			return
		
			
			
		combat.spawn_timer = combat.spawn_interval
		_try_spawn(e)
	
		

func _try_spawn(e:int) -> void:
	var battery := cs.get_component(e, "BatteryComponent")
	if battery == null:
		return
	
	var enemy_count := enemy_arch.entities.size()

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
		



func _pick_enemy() -> String:
	var keys : Array = db.enemy_configs.keys()
	return keys.pick_random()

func _get_enemy_cost(_enemy_name: String) -> int:
	return 2



func _get_spawn_position() -> Vector3:
	if players_arch.entities.is_empty():
		return Vector3.ZERO

	var tf = cs.get_component(players_arch.entities.pick_random(), "TransformComponent")
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

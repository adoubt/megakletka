extends BaseSystem
class_name EnemySpawnSystem

var event_bus: EventBus
var db : DataBase
var current_floor: int = -1
var spawning :bool= false

var spawn_interval :float = 10.0
var spawn_timer :float= 1.0
const ENEMIES_PER_TICK :int= 10

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,_db: DataBase, _event_bus: EventBus):
	super._init(_entity_manager, _component_store)
	event_bus = _event_bus
	db = _db
	event_bus.subscribe("combat_started", _on_combat_started)
	event_bus.subscribe("combat_finished", _on_combat_finished)
	

	
	
func update(delta: float) -> void:
	if not spawning:
		return

	spawn_timer += delta
	if spawn_timer < spawn_interval:
		return

	spawn_timer -= spawn_interval

	_spawn_tick()

func _spawn_tick() -> void:
	

	var battery = cs.get_component(current_floor, "BatteryComponent")
	if battery.current_budget <= 0:
		return

	
	var enemies_to_create := []
	for i in range(ENEMIES_PER_TICK):
		var enemy_name : String = _pick_enemy()
		var cost :int = _get_enemy_cost(enemy_name)

		if battery.current_budget < cost:
			return

		battery.current_budget -= cost

		enemies_to_create.append({"enemy_name":enemy_name, "position":_get_spawn_position()})
	
	event_bus.emit("create_enemy", enemies_to_create)


func  _on_combat_started(data : Dictionary) -> void:
	spawning = true
	current_floor = data["current_floor"]
	spawn_timer = 1.0
func  _on_combat_finished(data : Dictionary) -> void:		
	spawning = false
	

func _pick_enemy() -> String:
	return "Aboba" # потом: таблица, вес, сложность

func _get_enemy_cost(enemy_name: String) -> int:
	return 2

func _get_spawn_position() -> Vector3:
	return Vector3(
		randf_range(-20.0, 20.0),
		0.5,
		randf_range(-20.0, 20.0)
	)

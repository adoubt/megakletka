class_name CombatSystem
extends BaseSystem

var run_entity := -1
var current_day := -1
var current_day_entity := -1

var combat : CombatStateComponent
var battery : BatteryComponent

func _init(_entity_manager: EntityManager, _component_store: ComponentStore,  _event_bus: EventBus,):
	super._init(_entity_manager, _component_store, _event_bus)

	event_bus.subscribe("enemy_died", _on_enemy_died)
	event_bus.subscribe("day_changed", _on_day_changed)

func update(delta: float) -> void:
	if run_entity == -1:
		run_entity = get_entities_with(["RunComponent"])[0]
		current_day = cs.get_component(run_entity, "RunComponent").current_day
		_cache_day_entities()

	if combat.state == CombatState.INACTIVE:
		if _player_left_safe_zone() and battery.current_budget > 0:
			combat.state = CombatState.ACTIVE
			event_bus.emit("combat_started", {
				"day_index": current_day,
				"current_day": current_day_entity
			})

	if combat.state == CombatState.ACTIVE:
		combat.time_to_next_phase -= delta
		if combat.time_to_next_phase <= 0:
			_change_phase(combat)

		var enemies = get_entities_with(["EnemyComponent"], ["DeadComponent"])
		if battery.current_budget <= 0 and enemies.is_empty():
			combat.state = CombatState.COMPLETED
			event_bus.emit("combat_completed", {
				"day_index": current_day,
				"current_day": current_day_entity,
				"current_phase": combat.phase
			})
		
func _player_left_safe_zone() -> bool:
	var players = get_entities_with(["PlayerComponent", "TransformComponent"])
	if players.is_empty():
		return false

	var day_center: Vector3 = Vector3.ZERO
	var safe_radius: float = 10.0

	for p in players:
		var pos = cs.get_component(p, "TransformComponent").position
		if pos.distance_to(day_center) > safe_radius:
			return true
	return false

func _change_phase(combat: CombatStateComponent):
	combat.phase+=1
	event_bus.emit("phase_changed", {"current_phase": combat.phase})
	combat.time_to_next_phase = 10.0
	

func _on_day_changed(data: Dictionary):
	current_day = data.current_day
	_cache_day_entities()

func _cache_day_entities():
	var days = get_entities_with(["DayComponent", "DayIdComponent"])
	for day in days:
		if cs.get_component(day, "DayIdComponent").id == current_day:
			current_day_entity = day
			break

	combat = cs.get_component(current_day_entity, "CombatStateComponent")
	battery = cs.get_component(current_day_entity, "BatteryComponent")
	
func _on_enemy_died(data : Dictionary):
	var enemy_budget = cs.get_component(data.e_id, "EnemyBudgetComponent")
	battery.alive_budget -= int(enemy_budget.final_value)
	
	event_bus.emit("budget_changed",{"max_budget": battery.budget,
	"current_budget":battery.current_budget, 
	"alive_budget": battery.alive_budget
	})
	

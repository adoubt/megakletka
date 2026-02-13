class_name CombatSystem
extends BaseSystem


var current_day := -1
var current_day_entity := -1

var combat : CombatStateComponent
var battery : BatteryComponent
var day_arch: Archetype
var enemy_arch: Archetype
var player_arch: Archetype
var day_center: Vector3 = Vector3.ZERO
func _init(_entity_manager: EntityManager, _component_store: ComponentStore,  _event_bus: EventBus,):
	super._init(_entity_manager, _component_store, _event_bus)

	event_bus.subscribe("enemy_died", _on_enemy_died)
	event_bus.subscribe("day_changed", _on_day_changed)
	
	day_arch = cs.register_archetype(["DayComponent","CombatStateComponent","BatteryComponent"])
	enemy_arch = cs.register_archetype(["EnemyComponent","EnemyBudgetComponent"], ["DeadComponent"])
	player_arch = cs.register_archetype(["PlayerComponent", "TransformComponent"],["DeadComponent"])
	
func update(delta: float) -> void:
	if time_to_ignore >= 0.0:
		time_to_ignore -= delta
		return
	if day_arch.entities.is_empty():
		return
	
	var enemies = enemy_arch.entities.duplicate()
	var entities = day_arch.entities.duplicate()
	for e in entities:
		var combat_state = cs.get_component(e, "CombatStateComponent")
		
		if combat_state.state == CombatState.INACTIVE:
			if _player_left_safe_zone() and battery.current_budget > 0:
				combat_state.state = CombatState.ACTIVE
				event_bus.emit("combat_started", {
					"day_index": current_day,
					"current_day": current_day_entity
				})

			if combat_state.state == CombatState.ACTIVE:

				combat_state.time_left -= delta

				var can_win_by_time :bool= has_win(
					combat_state.win_condition,
					CombatState.WinCondition.TIME
				) and combat_state.time_left <= 0

				var can_win_by_kill : bool = has_win(
					combat_state.win_condition,
					CombatState.WinCondition.KILL_ALL
				) and battery.current_budget <= 0 \
				  and enemies.is_empty()


				if can_win_by_kill or can_win_by_time:
					combat_state.state = CombatState.COMPLETED
					event_bus.emit("combat_completed", {
						"day_index": current_day,
						"current_day": current_day_entity,
						"current_phase": combat.phase
					})
					
func has_win(win_mask: int, flag: int) -> bool:
	return (win_mask & flag) != 0

func _player_left_safe_zone() -> bool:
	time_to_ignore+= 1.0
	if player_arch.entities.is_empty():
		return false

	
	var safe_radius: float = 10.0

	for p in player_arch.entities:
		var pos = cs.get_component(p, "TransformComponent").position
		if pos.distance_to(day_center) > safe_radius:
			return true
	return false

func _change_phase(combat: CombatStateComponent):
	combat.phase+=1
	event_bus.emit("phase_changed", {"current_phase": combat.phase})
	combat.time_to_next_phase = 10.0
	

func _on_day_changed(data: Dictionary):
	if combat and combat.state == CombatState.ACTIVE:
		event_bus.emit("day_skipped", {
				"day_index": current_day,
				"current_day": current_day_entity
			})
	
	current_day = data.current_day
	
	for day in day_arch.entities:
		if cs.get_component(day, "DayComponent").id == current_day:
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

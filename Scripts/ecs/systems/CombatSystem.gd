class_name CombatSystem
extends BaseSystem

var run_entity:int=-1
func update(_delta: float) -> void:
	
	if run_entity ==-1:
		run_entity = get_entities_with(["RunComponent"])[0]
	var current_day = cs.get_component(run_entity,"RunComponent").current_day
	var day_id: int
	
	var days = get_entities_with(["DayComponent", "DayIdComponent"])
	for day in days:
		if cs.get_component(day, "DayIdComponent").id  == current_day:
			day_id = day
	var combat = cs.get_component(day_id, "CombatStateComponent")
	var battery = cs.get_component(day_id, "BatteryComponent")
	
	if combat.state == CombatState.INACTIVE:
		if _player_left_safe_zone() and battery.current_budget > 0:
			combat.state = CombatState.ACTIVE
			print("combat_started")
			event_bus.emit("combat_started", { "current_day": day_id })
			
	if combat.state == CombatState.ACTIVE:
		var enemies = get_entities_with(["EnemyComponent"])
		if battery.current_budget <= 0 and enemies.is_empty() :
			combat.state = CombatState.COMPLETED
			print('combat_completed')
			event_bus.emit("combat_completed", { "current_day": day_id })
					
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

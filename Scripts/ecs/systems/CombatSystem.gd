class_name CombatSystem
extends BaseSystem


func update(_delta: float) -> void:
	var days = get_entities_with([
	"DayComponent",
	"CombatStateComponent",
	"CurrentDayComponent",
	"BatteryComponent"
	])

	if days.is_empty():
		return

	var current_day = days[0]

	var combat = cs.get_component(current_day, "CombatStateComponent")
	var battery = cs.get_component(current_day, "BatteryComponent")
	if combat.state == CombatState.INACTIVE:
		if _player_left_safe_zone() and battery.current_budget > 0:
			combat.state = CombatState.ACTIVE
			print("combat_started")
			event_bus.emit("combat_started", { "current_day": current_day })
			
	if combat.state == CombatState.ACTIVE:
		var enemies = get_entities_with(["EnemyComponent"])
		if battery.current_budget <= 0 and enemies.is_empty() :
			combat.state = CombatState.COMPLETED
			print('combat_completed')
			event_bus.emit("combat_completed", { "current_day": current_day })
					
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

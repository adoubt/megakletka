class_name CombatSystem
extends BaseSystem


func update(_delta: float) -> void:
	var floors = get_entities_with([
	"FloorComponent",
	"CombatStateComponent",
	"CurrentFloorComponent",
	"BatteryComponent"
	])

	if floors.is_empty():
		return

	var current_floor = floors[0]

	var combat = cs.get_component(current_floor, "CombatStateComponent")
	var battery = cs.get_component(current_floor, "BatteryComponent")
	if combat.state == CombatState.INACTIVE:
		if _player_left_safe_zone() and battery.current_budget > 0:
			combat.state = CombatState.ACTIVE
			print("combat_started")
			event_bus.emit("combat_started", { "current_floor": current_floor })
			
	if combat.state == CombatState.ACTIVE:
		var enemies = get_entities_with(["EnemyComponent"])
		if battery.current_budget <= 0 and enemies.is_empty() :
			combat.state = CombatState.COMPLETED
			print('combat_finished')
			event_bus.emit("combat_finished", { "current_floor": current_floor })
					
func _player_left_safe_zone() -> bool:
	var players = get_entities_with(["PlayerComponent", "TransformComponent"])
	if players.is_empty():
		return false

	var floor_center: Vector3 = Vector3.ZERO
	var safe_radius: float = 10.0

	for p in players:
		var pos = cs.get_component(p, "TransformComponent").position
		if pos.distance_to(floor_center) > safe_radius:
			return true

	return false

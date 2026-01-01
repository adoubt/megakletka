# res://ecs/SystemManager.gd
class_name SystemManager
extends RefCounted

var systems: Array = []  # [system_instance, ...]
var profiling_enabled := true
var system_stats := {} # system_name -> { last, avg, max, calls }
var _timer := 0.0
const UI_UPDATE_INTERVAL := 1.0

## Adds a system to the ECS
func add_system(system: BaseSystem) -> void:
	if not systems.has(system):
		systems.append(system)
		if profiling_enabled:
			var name :String= system.get_script().get_path().get_file().get_basename()

			system_stats[name] = {
				"last": 0.0,
				"avg": 0.0,
				"max": 0.0,
				"calls": 0
			}

## Removes a system from the ECS
func remove_system(system: Object) -> void:
	if systems.has(system):
		systems.erase(system)

## Updates all systems (usually called once per frame)
func update_all(delta: float) -> void:
	_timer += delta
	for system in systems:
		if not system.has_method("update"):
			continue
		
		if profiling_enabled:
			_profile_call(system, "update", delta)
			if _timer >= UI_UPDATE_INTERVAL:
				_timer = 0.0
				_push_stats_to_ui()
		else:
			system.update(delta)
		

## Processes all systems that have a fixed_update() (physics step)
func fixed_update_all(delta: float) -> void:
	for system in systems:
		if system.has_method("fixed_update"):
			system.fixed_update(delta)
func _profile_call(system: Object, method: String, delta: float) -> void:
	var start := Time.get_ticks_usec()
	
	if method == "update":
		system.update(delta)
	else:
		system.fixed_update(delta)

	var elapsed := (Time.get_ticks_usec() - start) / 1000.0 # ms
	var name :String= system.get_script().get_path().get_file().get_basename()

	var stat : Dictionary = system_stats[name]
	stat.calls += 1
	stat.last = elapsed
	stat.avg += (elapsed - stat.avg) / stat.calls
	stat.max = max(stat.max, elapsed)
	
## Clears all registered systems
func clear() -> void:
	systems.clear()
	
func _push_stats_to_ui() -> void:
	#if UIManager == null:
		#return
	UIManager.dev_panel.update_system_profile(system_stats.duplicate(true))

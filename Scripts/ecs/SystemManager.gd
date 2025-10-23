# res://ecs/SystemManager.gd
class_name SystemManager
extends RefCounted

var systems: Array = []  # [system_instance, ...]

## Adds a system to the ECS
func add_system(system: BaseSystem) -> void:
	if not systems.has(system):
		systems.append(system)

## Removes a system from the ECS
func remove_system(system: Object) -> void:
	if systems.has(system):
		systems.erase(system)

## Updates all systems (usually called once per frame)
func update_all(delta: float) -> void:
	for system in systems:
		if system.has_method("update"):
			system.update(delta)


## Processes all systems that have a fixed_update() (physics step)
func fixed_update_all(delta: float) -> void:
	for system in systems:
		if system.has_method("fixed_update"):
			system.fixed_update(delta)

## Clears all registered systems
func clear() -> void:
	systems.clear()

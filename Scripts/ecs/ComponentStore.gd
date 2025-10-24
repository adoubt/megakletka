# res://ecs/ComponentStore.gd
extends RefCounted
class_name ComponentStore

var components: Dictionary = {} # { component_name: { entity_id: component_instance } }

## Adds a component instance to the specified entity
func add_component(entity_id: int, comp_name: String, instance: Object) -> void:
	if not components.has(comp_name):
		components[comp_name] = {}
	components[comp_name][entity_id] = instance

## Returns a specific component of an entity
func get_component(entity_id: int, comp_name: String) -> Object:
	if components.has(comp_name) and components[comp_name].has(entity_id):
		return components[comp_name][entity_id]
	return null

## Returns all components belonging to a given entity
func get_all_components_for_entity(entity_id: int) -> Dictionary:
	var result: Dictionary = {}
	for comp_name in components.keys():
		if components[comp_name].has(entity_id):
			result[comp_name] = components[comp_name][entity_id]
	return result

## Returns all entities that have this component type
func get_all_of_type(comp_name: String) -> Dictionary:
	return components.get(comp_name, {})

## Removes a component of a given type from an entity
func remove_component(entity_id: int, comp_name: String) -> void:
	if components.has(comp_name):
		components[comp_name].erase(entity_id)
		if components[comp_name].is_empty():
			components.erase(comp_name)

## Removes ALL components for a given entity
func remove_all_components_for_entity(entity_id: int) -> void:
	for comp_name in components.keys():
		if components[comp_name].has(entity_id):
			components[comp_name].erase(entity_id)
			if components[comp_name].is_empty():
				components.erase(comp_name)

## Checks if an entity has a specific component
func has_component(entity_id: int, comp_name: String) -> bool:
	return components.has(comp_name) and components[comp_name].has(entity_id)


## Clears all stored components
func clear() -> void:
	components.clear()

# res://ecs/BaseSystem.gd
extends RefCounted
class_name BaseSystem

var em: EntityManager
var cs: ComponentStore

func _init(_entity_manager: EntityManager, _component_store: ComponentStore):
	em = _entity_manager
	cs = _component_store


func get_entities_with(component_names: Array, exclude: Array = []) -> Array:
	if component_names.is_empty():
		return []

	# Начинаем с первого компонента
	var first_comp_entities = cs.get_all_of_type(component_names[0]).keys()
	var result_dict := {}
	for e in first_comp_entities:
		result_dict[e] = true

	# Пересечение с остальными
	for i in range(1, component_names.size()):
		var comp_entities = cs.get_all_of_type(component_names[i]).keys()
		var temp_dict := {}
		for e in comp_entities:
			if result_dict.has(e):
				temp_dict[e] = true
		result_dict = temp_dict

	# Исключаем unwanted-компоненты
	for comp_name in exclude:
		var exclude_entities = cs.get_all_of_type(comp_name).keys()
		for e in exclude_entities:
			result_dict.erase(e)

	return result_dict.keys()





func get_entities_in_radius(entity_id: int, radius: float) -> Array:
	var result = []

	# Берём позицию исходной сущности
	var pos_component = cs.get_component(entity_id, "TransformComponent")
	if pos_component == null:
		return result
	var origin = pos_component.position  # Vector3

	# Проходим все сущности с PositionComponent
	var all_entities = get_entities_with(["TransformComponent"])
	for other_id in all_entities:
		if other_id == entity_id:
			continue  # не учитываем себя

		var other_pos = cs.get_component(other_id, "TransformComponent")
		if other_pos == null:
			continue

		var distance = origin.distance_to(other_pos.position)
		if distance <= radius:
			result.append(other_id)

	return result

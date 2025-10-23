# res://ecs/BaseSystem.gd
extends RefCounted
class_name BaseSystem

var em: EntityManager
var cs: ComponentStore

func _init(_entity_manager: EntityManager, _component_store: ComponentStore):
	em = _entity_manager
	cs = _component_store




#func get_entities_in_radius(entity_id: int, radius: float) -> Array:
	#var result = []
#
	## Берём позицию исходной сущности
	#var pos_component = component_store.get_component(entity_id, "PositionComponent")
	#if pos_component == null:
		#return result
	#var origin = pos_component.position  # Vector3
#
	## Проходим все сущности с PositionComponent
	#var all_entities = get_entities_with("PositionComponent")
	#for other_id in all_entities:
		#if other_id == entity_id:
			#continue  # не учитываем себя
#
		#var other_pos = component_store.get_component(other_id, "PositionComponent")
		#if other_pos == null:
			#continue
#
		#var distance = origin.distance_to(other_pos.position)
		#if distance <= radius:
			#result.append(other_id)
#
	#return result

# res://ecs/EntityManager.gd
extends RefCounted
class_name EntityManager

var _next_id := 1
var entities := {}

## Creates a new unique entity and returns its ID.
## Each call increments the internal counter to ensure IDs never repeat.
func create_entity() -> int:
	var id = _next_id
	_next_id += 1
	entities[id] = true
	return id

## Destroys an entity by removing its ID from the registry.
## Note: this only removes the entity record — 
## components linked to it must be cleared separately in ComponentStore.
func destroy_entity(id: int):
	entities.erase(id)

## Clears all entities and resets the ID counter.
## Used when restarting the game or fully resetting the ECS world.
func clear():
	entities.clear()
	_next_id = 1

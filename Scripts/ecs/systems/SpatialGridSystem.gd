extends BaseSystem
class_name SpatialGridSystem

var grid: SpatialGrid

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _grid: SpatialGrid):
	super._init(_entity_manager, _component_store)

	grid = _grid
	
func update(_delta: float) -> void:
	grid.clear()
	var entities = get_entities_with(["TransformComponent"])
	for id in entities:
		var transform = cs.get_component(id, "TransformComponent")
		grid.add_entity(id, transform.position)

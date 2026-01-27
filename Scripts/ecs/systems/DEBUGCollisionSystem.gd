extends BaseSystem
class_name DEBUGCollisionSystem


var object_pool: ObjectPool


func _init(_entity_manager :EntityManager, _component_store :ComponentStore, _event_bus :EventBus,_object_pool:ObjectPool):
	super._init(_entity_manager, _component_store, _event_bus)
	object_pool = _object_pool



func update(_delta: float) -> void:
	var entities = get_entities_with(["TransformComponent", "CollisionComponent"],["DeadComponent"])

	for entity_id in entities:

		var transform = cs.get_component(entity_id, "TransformComponent")
		var collision = cs.get_component(entity_id, "CollisionComponent")
		if not collision.debug_collider:
			collision.debug_collider = object_pool.get_instance("res://Scenes/debug_collider.tscn")
			
			var mat = collision.debug_collider.mesh.material
			# гарантируем уникальный меш
			var mesh := CapsuleMesh.new()
			
			
			collision.debug_collider.mesh = mesh
			collision.debug_collider.mesh.material = mat
			collision.debug_collider.visible = true
			cs.add_component(entity_id, "ScaleRequestComponent", ScaleRequestComponent.new(1.0,true))
		collision.debug_collider.global_position = transform.position
		

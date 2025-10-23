# MovementSystem.gd
extends BaseSystem
class_name MovementSystem

func update(delta: float):
	for id in get_("TransformComponent", "VelocityComponent"):
		var transform = cs.get_component(id, "TransformComponent")
		var velocity = component_store.get_component(id, "VelocityComponent")
		transform.position += velocity.value * delta

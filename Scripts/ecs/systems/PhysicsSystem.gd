extends BaseSystem
class_name PhysicsSystem

func update(delta):
	var entities = get_entities_with([
		"TransformComponent",])

	for e in entities:
		var tf = cs.get_component(e, "TransformComponent")
		var phys = cs.get_component(e, "PhysicsComponent")

		if not phys.grounded:
			tf.velocity.y -= phys.gravity * delta
		else:
			tf.velocity.y = max(tf.velocity.y, 0)

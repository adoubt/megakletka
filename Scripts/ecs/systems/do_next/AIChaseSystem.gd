extends BaseSystem
class_name AIChaseSystem

func update(delta: float) -> void:
	for id in get_entities_with(
		["EnemyComponent", "TransformComponent", "TargetComponent", "MovementComponent"],["DeadComponent"]
	):
		var tf = cs.get_component(id,"TransformComponent")
		var target = cs.get_component(id,"TargetComponent")
		var movement = cs.get_component(id,"MovementComponent")
		if target.target_id != -1:
			var target_tf = cs.get_component(target.target_id,"TransformComponent")
			movement.direction = (target_tf.position - tf.position).normalized()

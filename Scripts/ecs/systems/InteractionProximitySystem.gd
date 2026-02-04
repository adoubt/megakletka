extends BaseSystem
class_name InteractionProximitySystem

var player_arch: Archetype

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)

	player_arch = cs.register_archetype(
		["PlayerComponent", "TransformComponent", "InRangeInteractionComponent"],
		["DeadComponent"]
	)

	arch = cs.register_archetype(
		["TransformComponent", "InteractionTargetComponent"],
		["DeadComponent"]
	)

func update(_delta: float) -> void:
	for p in player_arch.entities:
		var p_tf := cs.get_component(p, "TransformComponent")
		var ir   := cs.get_component(p, "InRangeInteractionComponent")


		var best_target := -1
		var best_score := -INF

		for t in arch.entities:
			var t_tf := cs.get_component(t, "TransformComponent")
			var target := cs.get_component(t, "InteractionTargetComponent")
			if not t_tf or not target:
				continue

			var dist_sq :float= p_tf.position.distance_squared_to(t_tf.position)
			if dist_sq > target.radius * target.radius:
				continue

			var score :float= target.priority * 1000 - dist_sq
			if score > best_score:
				best_score = score
				best_target = t

		_update_interaction(ir, best_target)

func _update_interaction(ir: InRangeInteractionComponent, new_target_id: int) -> void:
	if ir.target_id == new_target_id:
		return

	# сохраняем старый
	ir.previous_target_id = ir.target_id
	ir.target_id = new_target_id

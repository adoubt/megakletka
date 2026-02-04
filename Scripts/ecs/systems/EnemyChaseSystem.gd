extends BaseSystem
class_name EnemyChaseSystem

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus) 
	arch = cs.register_archetype([
		"EnemyComponent",
		"TransformComponent",
		"AimComponent",
		"MovementIntentComponent"
	],["DeadComponent"])	

func update(_delta: float) -> void:
	var enemies = arch.entities.duplicate()
	for e_id in enemies:
	
		var tf := cs.get_component(e_id, "TransformComponent")
		var aim := cs.get_component(e_id, "AimComponent")
		var move := cs.get_component(e_id, "MovementIntentComponent")
		#if not aim or not tf or not move:
			#continue
		if not aim.has_position:
			continue
		var dir :Vector3= aim.position - tf.position
		if dir.length_squared() < 0.1:
			continue
		dir.y = 0.0
		move.direction = dir.normalized()
		#cs.remove_component(e_id,"AimComponent")

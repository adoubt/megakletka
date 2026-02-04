extends BaseSystem
class_name InputSystem

func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus):
	super._init( _entity_manager, _component_store, _event_bus)
	
	arch = cs.register_archetype(["InputComponent"])
	
func update(_delta):
	

	for e in arch.entities:
		var input = cs.components["InputComponent"][e]

		input.move = Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_back")  - Input.get_action_strength("move_forward")
		)

		input.look = UIManager.consume_mouse_delta()

		input.jump = Input.is_action_just_pressed("jump")
		#input.attack = Input.is_action_pressed("attack")

		input.interact_held = Input.is_action_pressed("interact")
		input.interact_pressed = Input.is_action_just_pressed("interact")
		input.interact_released= Input.is_action_just_released("interact")

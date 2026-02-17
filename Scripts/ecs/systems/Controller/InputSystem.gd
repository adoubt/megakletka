extends BaseSystem
class_name InputSystem
var camera_arch: Archetype
var item_arch: Archetype

func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus):
	super._init( _entity_manager, _component_store, _event_bus)
	camera_arch = cs.register_archetype(["CameraComponent"])
	arch = cs.register_archetype(["InputComponent"])
	event_bus.subscribe("day_selected", _on_day_selected)
	event_bus.subscribe("hat_toggled", _on_hat_toggled)
	item_arch = cs.register_archetype(["ItemComponent"], ["DeadComponent"])
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

func _on_day_selected(data:Dictionary):
	var day_id = data.day_id
	cs.add_component(RUN, "DaySelectRequestComponent", DaySelectRequestComponent.new(day_id))

func _on_hat_toggled(data:Dictionary):
	var player_id = data.owner_id
	if not data.opened:
		_return_camera(player_id)
	else:
		_update_items_data(player_id)
		for camera in camera_arch.entities:
			var camera_comp = cs.get_component(camera, "CameraComponent")
			if camera_comp.owner_id == player_id:
				


				var player_pos = cs.get_component(player_id, "TransformComponent").position
				var focus_pos = player_pos + Vector3(0.0, 0.8, 0.0)
				
				var camera_pos = camera_comp.camera_instance.global_position
				
				var dir = (camera_pos - focus_pos).normalized()
				var target_distance := 0.9
				camera_comp.focus_target = focus_pos
				camera_comp.focus_from_pos = focus_pos + dir * target_distance
				camera_comp.mode = CameraComponent.Mode.LOCKED_FOLLOW
				return

func _return_camera(owner_id:int) -> void:
	for camera in camera_arch.entities:
				var camera_comp = cs.get_component(camera, "CameraComponent")
				if camera_comp.owner_id == owner_id:
					if camera_comp.mode == CameraComponent.Mode.LOCKED_FOLLOW:
						camera_comp.return_start_pos = camera_comp.camera_instance.global_position
						camera_comp.return_start_rot = camera_comp.camera_instance.global_basis
						camera_comp.transition_elapsed = 0.0
						camera_comp.mode = CameraComponent.Mode.BLEND_TO_FOLLOW
						
					return	
func _update_items_data(owner_id: int) ->void:
	for item in item_arch.entities:
		if cs.get_component(item, "ItemComponent").owner_id == owner_id:
			cs.add_component(item, "ItemViewBuildRequestComponent", ItemViewBuildRequestComponent.new())

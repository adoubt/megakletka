extends BaseSystem
class_name InputSystem
var camera_arch: Archetype
var item_arch: Archetype

func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus):
	super._init( _entity_manager, _component_store, _event_bus)
	camera_arch = cs.register_archetype(["CameraComponent"])
	arch = cs.register_archetype(["InputComponent"])
	event_bus.subscribe("day_selected", _on_day_selected)
	event_bus.subscribe("hat_opened", _on_hat_opened)
	event_bus.subscribe("slot_assignment_request",_on_slot_assignment_request)
	item_arch = cs.register_archetype(["ItemComponent"], ["DeadComponent"])
	event_bus.subscribe("use_request",_on_use_request)
	event_bus.subscribe("sell_request", _on_sell_request)
	event_bus.subscribe("purchase_request", _on_purchase_request)
	
func update(_delta):
	
	for e in arch.entities:
		var input = cs.get_component(e, "InputComponent")

		input.move = Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_back")  - Input.get_action_strength("move_forward")
		)

		input.look = UIManager.consume_mouse_delta()
		input.attack = Input.is_action_just_pressed("attack") and not UIManager._any_ui_open()
		input.jump = Input.is_action_just_pressed("jump")
		input.camera_toggle = Input.is_action_just_pressed("camera_toggle")
		#input.attack = Input.is_action_pressed("attack")

		input.interact_held = Input.is_action_pressed("interact")
		input.interact_pressed = Input.is_action_just_pressed("interact")
		input.interact_released= Input.is_action_just_released("interact")

func _on_day_selected(data:Dictionary):
	var day_id = data.day_id
	cs.add_component(RUN, "DaySelectRequestComponent", DaySelectRequestComponent.new(day_id))

func _on_hat_opened(data:Dictionary):
	var player_id = data.owner_id
	#if not data.opened:
		#_return_camera(player_id)
		#var render = cs.get_component(player_id, "RenderComponent")
		#if render and render.instance:
			#render.instance.slots_root.hide_slots()
	#else:
	var render = cs.get_component(player_id, "RenderComponent")
	if render and render.instance:
		render.instance.slots_root.show_slots()
	_update_items_data(player_id)
	for camera in camera_arch.entities:
		var camera_comp = cs.get_component(camera, "CameraComponent")
		if camera_comp.owner_id == player_id:
			

			var player_pos = cs.get_component(player_id, "TransformComponent").position
			var focus_pos = player_pos + Vector3(0.0, 0.8, 0.0)

			var camera_pos = camera_comp.camera_instance.global_position

			var flat_dir = camera_pos - focus_pos
			flat_dir.y = 0.0

			if flat_dir.length_squared() < 0.0001:
				flat_dir = Vector3.BACK  # fallback если камера ровно над игроком
			else:
				flat_dir = flat_dir.normalized()

			var orbit_radius := 0.5
			var orbit_height := 1.2

			var offset = flat_dir * orbit_radius
			offset.y = orbit_height

			camera_comp.focus_target = focus_pos
			camera_comp.focus_from_pos = focus_pos + offset
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

func _on_slot_assignment_request(data: Dictionary) -> void:
	var requested_instance: Node3D = data.item_instance
	var r = find_item_by_instance(requested_instance)
	var item_id:int= r[0]
	var owner_id = r[1]
	var slot_mask = r[2]
	var allowed = SlotMask.PLAYER | SlotMask.CAMPFIRE
	if (slot_mask & allowed) == 0:
		return
	var slot_index:int = data.slot_index
	var target_id:int = data.target_id
	var transaction := ItemTransactionComponent.new()
	transaction.target_id= target_id
	transaction.slot_index = slot_index
	transaction.source_id = owner_id
	cs.add_component(item_id, "ItemTransactionComponent", transaction)

func _on_use_request(data:Dictionary) ->void:
	var requested_instance: Node3D = data.item_instance
	var r = find_item_by_instance(requested_instance)
	var item_id:int= r[0]
	var owner_id = r[1]
	
	if item_id ==-1:
		return
	var event_e := em.create_entity()
	var event = TriggerEventComponent.new()
	event.event_id = AbilityTriggers.Events.USED
	var payload:Dictionary = {"item_id": item_id}
	event.payload = payload
	event.owner_id = owner_id
	cs.add_component(event_e, "TriggerEventComponent",event)
	
func _on_sell_request(data: Dictionary)-> void:
	var requested_instance: Node3D = data.item_instance
	var r = find_item_by_instance(requested_instance)
	var item_id:int= r[0]
	var owner_id = r[1]
	var slot_mask = r[2]
	var allowed = SlotMask.PLAYER | SlotMask.CAMPFIRE
	if (slot_mask & allowed) == 0:
		return
	var req:= SellRequestComponent.new()
	req.source_id = data.owner_id
	cs.add_component(item_id, "SellRequestComponent",req)
	
func _on_purchase_request(data: Dictionary)-> void:
	var requested_instance: Node3D = data.item_instance
	var r = find_item_by_instance(requested_instance)
	var item_id:int= r[0]
	var owner_id = r[1]
	var slot_mask = r[2]
	var allowed = SlotMask.MERCHANT
	if (slot_mask & allowed) == 0:
		return
	var req := PurchaseRequestComponent.new()
	req.source_id = data.owner_id
	cs.add_component(item_id, "PurchaseRequestComponent",req)	
	
func find_item_by_instance(instance:Node3D) -> Array[int]:
	
	for e in item_arch.entities:
		
		var render = cs.get_component(e,"RenderComponent")
		if not render or not render.instance: 
			continue
		var item_comp:= cs.get_component(e, "ItemComponent")
		if render.instance == instance:
			return [e, item_comp.owner_id, item_comp.slot_mask]

	return [-1,-1,-1]

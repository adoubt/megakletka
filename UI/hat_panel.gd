extends Control
var drag_plane: Plane

@onready var texture_rect: TextureRect = $TextureRect

@onready var sell_zone: Control = %SellZone
@onready var use_zone: Control = %UseZone

@onready var sell_value: Label = %SellValue

var current_zone: Control = null
var item_base_pos: Vector3
@onready var sell_container: HBoxContainer = %SellContainer


var hovered_item: ItemInstance = null
var dragged_item: ItemInstance = null
var drag_preview: Control = null

func _ready() -> void:
	sell_container.hide()
func _gui_input(event: InputEvent) -> void:

	if event is InputEventMouseMotion:
		if dragged_item:
			_update_drag_position()
		else:
			_update_hover(event.position)

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_try_start_drag()
			else:
				_try_drop()

func _try_start_drag():
	if hovered_item == null:
		return
	if UIManager.owner_id == -1:
		return

	dragged_item = hovered_item
	hovered_item.dragged = true
	dragged_item._kill_tweens()
	var camera = get_viewport().get_camera_3d()
	var cam_forward = -camera.global_transform.basis.z
	var item_pos = dragged_item.model.global_transform.origin
	
	item_base_pos = item_pos
	drag_plane = Plane(cam_forward, item_pos)
	sell_zone.set_drop_active(true)
	use_zone.set_drop_active(true)

func _update_drag_position():
	if dragged_item == null:
		return

	var camera = get_viewport().get_camera_3d()
	var mouse = get_viewport().get_mouse_position()

	var from = camera.project_ray_origin(mouse)
	var dir  = camera.project_ray_normal(mouse)

	var hit = drag_plane.intersects_ray(from, dir)
	if hit:
		dragged_item.model.global_position = dragged_item.model.global_position.lerp(hit, 0.9)

	_update_zone_hover()

func _update_zone_hover():
	var zone = _get_drop_zone(get_viewport().get_mouse_position())

	if zone == current_zone:
		return

	if current_zone:
		current_zone.set_hover_feedback(false)

	current_zone = zone

	if current_zone:
		current_zone.set_hover_feedback(true)


func _try_drop():
	if dragged_item == null:
		return

	var zone = _get_drop_zone(get_viewport().get_mouse_position())

	if zone:
		var accepted = zone.accept_drop(dragged_item)
		if accepted:
			_cleanup_drag()
			return

	_cancel_drag()

func _cleanup_drag():
	if dragged_item:
		dragged_item.model.global_position = item_base_pos
		dragged_item.dragged = false
		dragged_item = null

func _raycast_from_mouse(mouse_pos: Vector2) -> Object:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return null

	# Берём позицию мыши в координатах всего viewport
	var global_mouse_pos := get_viewport().get_mouse_position()

	var from := camera.project_ray_origin(global_mouse_pos)
	var dir  := camera.project_ray_normal(global_mouse_pos)

	var params := PhysicsRayQueryParameters3D.new()
	params.from = from
	params.to   = from + dir * 10.0
	params.collide_with_areas = true

	var res := camera.get_world_3d().direct_space_state.intersect_ray(params)

	return res.collider if res else null

func _get_drop_zone(mouse_pos: Vector2) -> Control:
	var controls = get_viewport().gui_get_hovered_control()
	
	while controls:
		if controls.has_method("accept_drop"):
			return controls
		controls = controls.get_parent()
	
	return null


func _update_hover(mouse_pos: Vector2) -> void:
	var hit := _raycast_from_mouse(mouse_pos)

	var new_hover: ItemInstance = null
	if hit:
		new_hover = hit.get_parent() as ItemInstance
	else: 
		UIManager.hud.hide_item_tool_tip()
		
	if new_hover == hovered_item:
		return


	if hovered_item:
		hovered_item.set_highlight(false)
	
	hovered_item = new_hover
	
	if hovered_item and hovered_item.data:
		hovered_item.set_highlight(true)
	
		UIManager.hud.show_item_tool_tip(hovered_item.data)
		sell_value.text = str(int(hovered_item.data.cost))
		sell_container.show()
	else:
		sell_container.hide()
		
func _cancel_drag():
	_cleanup_drag()
	sell_zone.set_drop_active(false)
	use_zone.set_drop_active(false)
	sell_container.hide()

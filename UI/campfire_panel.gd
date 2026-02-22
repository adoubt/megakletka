extends Control
var drag_plane: Plane
const SLOT_LAYER_MASK := 1 << 9
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
	
func _process(_delta):
	if dragged_item:
		_update_drag_position()   
		
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_try_start_drag()
		else:
			_try_drop()

	if event is InputEventMouseMotion and not dragged_item:
		_update_hover(event.position)

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

	# 1. Проверка UI зон
	var ui_zone = _get_drop_zone(get_viewport().get_mouse_position())
	if ui_zone:
		if ui_zone.accept_drop(dragged_item):
			_cleanup_drag()
			return

	# 2. Проверка 3D слота
	var slot_area = _get_slot_area_under_mouse()
	if slot_area:
		if _accept_slot_drop(dragged_item, slot_area):
			_cleanup_drag()
			return

	_cancel_drag()
func _accept_slot_drop(item_instance:ItemInstance, area: Area3D) -> bool:
	var slot_index:int = area.get_parent().slot_index

	var target_id: int = area.get_parent().owner_id

	UIManager.event_bus.emit("slot_assignment_request", {"item_instance": item_instance,"target_id":target_id, "slot_index": slot_index})

	return true

func _get_slot_area_under_mouse() -> Area3D:
	var camera := get_viewport().get_camera_3d()
	if not camera:
		return null

	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var dir  = camera.project_ray_normal(mouse_pos)

	var params := PhysicsRayQueryParameters3D.new()
	params.from = from
	params.to = from + dir * 20.0
	params.collide_with_areas = true
	params.collision_mask = SLOT_LAYER_MASK   

	var hit = camera.get_world_3d().direct_space_state.intersect_ray(params)

	if hit and hit.collider is Area3D:
		return hit.collider

	return null
func _cleanup_drag():
	if not dragged_item:
		return

	var item = dragged_item

	
	item.dragged = false
	item.set_highlight(false)	
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

	if new_hover == hovered_item:
		return

	# Снять старый hover
	if hovered_item:
		hovered_item.set_highlight(false)

	# Обновить состояние
	hovered_item = new_hover

	# Применить новое состояние
	if hovered_item and hovered_item.data:
		hovered_item.set_highlight(true)

		UIManager.hud.show_item_tool_tip(hovered_item.data)
		sell_value.text = str(int(hovered_item.data.cost))
		sell_container.show()
	else:
		UIManager.hud.hide_item_tool_tip()
		sell_container.hide()
		
func _cancel_drag():
	_cleanup_drag()
	sell_zone.set_drop_active(false)
	use_zone.set_drop_active(false)
	sell_container.hide()


func _on_hidden() -> void:
	_cancel_drag()

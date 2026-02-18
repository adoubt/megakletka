extends Node
@onready var sub_viewport: SubViewport = $SubViewport
@onready var camera: Camera3D = $SubViewport/CameraPivot/Camera3D

@onready var camera_pivot: Node3D = $SubViewport/CameraPivot

func _ready() -> void:
	#UIManager.merchant_panel.texture_rect.texture = sub_viewport.get_texture()
	#UIManager.merchant_panel.background_scene = self
	pass
var hovered_item: ItemInstance = null
var last_hit: Area3D
func _gui_input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:
		
		_update_hover(event.position)

	elif event is InputEventMouseButton and event.pressed and hovered_item:
		if UIManager.owner_id ==-1: return
		UIManager.event_bus.emit("purchase_request", {"owner_id": UIManager.owner_id, "item_instance": hovered_item})
		

func _raycast_from_mouse(mouse_pos: Vector2) -> Object:
	var uv :Vector2= mouse_pos / UIManager.merchant_panel.texture_rect.size
	
	var vp_pos :Vector2= uv * Vector2(sub_viewport.size)
	
	
	
	var from := camera.project_ray_origin(vp_pos)
	var dir  := camera.project_ray_normal(vp_pos)

	var params := PhysicsRayQueryParameters3D.new()
	params.from = from
	params.to   = from + dir * 100.0
	params.collide_with_areas = true

	var space := camera.get_world_3d().direct_space_state
	var res := space.intersect_ray(params)

	return res.collider if res else null

func _update_hover(mouse_pos: Vector2) -> void:
	var hit := _raycast_from_mouse(mouse_pos)
	var new_hover: ItemInstance = null

	if hit:
		new_hover = hit.get_parent() as ItemInstance

	if new_hover == hovered_item:
		return

	# Убираем старый hover
	if hovered_item:
		hovered_item.set_highlight(false)

	# Обновляем состояние
	hovered_item = new_hover

	# Применяем новое состояние
	if hovered_item and hovered_item.data:
		hovered_item.set_highlight(true)
		UIManager.hud.show_item_tool_tip(hovered_item.data)
	else:
		UIManager.hud.hide_item_tool_tip()

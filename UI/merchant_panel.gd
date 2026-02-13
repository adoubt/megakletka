extends Control

@onready var texture_rect: TextureRect = $TextureRect
var background_scene: Node

		
func setup_background(data: Array):
	background_scene.show_offer(data)




var hovered_item: ItemInstance = null

func _gui_input(event: InputEvent) -> void:
	
	if event is InputEventMouseMotion:
		
		_update_hover(event.position)

	elif event is InputEventMouseButton and event.pressed and hovered_item:
		if UIManager.owner_id ==-1: return
		UIManager.event_bus.emit("purchase_request", {"owner_id": UIManager.owner_id, "item_instance": hovered_item})
		

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

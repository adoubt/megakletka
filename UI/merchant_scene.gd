extends Node
@onready var sub_viewport: SubViewport = $SubViewport
@onready var camera: Camera3D = $SubViewport/CameraPivot/Camera3D

@onready var camera_pivot: Node3D = $SubViewport/CameraPivot
var DISTANCE := 1.0
var HEIGHT   := 1.4
func _ready() -> void:
	UIManager.merchant_panel.texture_rect.texture = sub_viewport.get_texture()
	UIManager.merchant_panel.background_scene = self
	update_size()
var hovered_item: ItemInstance = null

@onready var shelves := [
	$SubViewport/Pos/Board,
	$SubViewport/Pos/Board2
]
@export var ANGLE_OFFSET_DEG := 25.0
var cached_angle := 0.0
var spawned_items: Array[Node3D] = []
var dragged_item: Node3D = null
var drag_depth: float = 0.0
# ------------------------------------------------
# INPUT
# ------------------------------------------------

func update_camera_pos(campfire_pos: Vector3, poi_pos: Vector3) -> void:
	if not camera_pivot or not camera:
		return
	var look_offset: Vector3 =Vector3(1,0.0,1.0)
	# --- направление ТОЛЬКО по XZ ---
	var flat_dir := poi_pos - campfire_pos
	flat_dir.y = 0.0
	flat_dir = flat_dir.normalized()

	# --- позиция пивота ---
	var pivot_pos := poi_pos + flat_dir * DISTANCE
	pivot_pos.y = poi_pos.y + HEIGHT
	camera_pivot.global_position = pivot_pos

	# --- точка взгляда ТОЛЬКО по XZ ---
	var look_pos := campfire_pos +look_offset
	look_pos.y = camera.global_position.y

	camera.look_at(look_pos, Vector3.UP)


		
func update_size():
	var size := DisplayServer.window_get_size()
	sub_viewport.size = size		
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

	if hovered_item:
		hovered_item.set_highlight(false)

	hovered_item = new_hover
	
	if hovered_item:
		hovered_item.set_highlight(true)
		

extends Node
@onready var sub_viewport: SubViewport = $SubViewport
@onready var camera: Camera3D = $SubViewport/CameraPivot/Camera3D

@onready var camera_pivot: Node3D = $SubViewport/CameraPivot

func _ready() -> void:
	UIManager.merchant_panel.texture_rect.texture = sub_viewport.get_texture()
	UIManager.merchant_panel.background_scene = self
	var size := DisplayServer.window_get_size()
	sub_viewport.size = size

@onready var shelves := [
	$SubViewport/Pos/Board,
	$SubViewport/Pos/Board2
]

var spawned_items: Array[Node3D] = []
var dragged_item: Node3D = null
var drag_depth: float = 0.0
# ------------------------------------------------
# INPUT
# ------------------------------------------------

func update_camera_pos(pos : Vector3):
	if camera_pivot:
		camera_pivot.position = pos
		
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			_try_pick(event.position)
		else:
			_release_drag()

	elif event is InputEventMouseMotion and dragged_item:
		_drag_to(event.position)

# ------------------------------------------------
# PICK
# ------------------------------------------------

func _try_pick(mouse_pos: Vector2):
	var uv = mouse_pos / UIManager.level_up_panel.texture_rect.size
	mouse_pos = uv * Vector2(sub_viewport.size)

	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)

	var params = PhysicsRayQueryParameters3D.new()
	params.from = from
	params.to = from + dir * 100.0

	var space_state = camera.get_world_3d().direct_space_state
	var result = space_state.intersect_ray(params)

	if not result:
		return

	dragged_item = result.collider

	# 🔥 КЛЮЧЕВОЕ МЕСТО
	drag_depth = camera.global_position.distance_to(dragged_item.global_position)

# ------------------------------------------------
# DRAG
# ------------------------------------------------

func _drag_to(mouse_pos: Vector2):
	var uv = mouse_pos / UIManager.level_up_panel.texture_rect.size
	mouse_pos = uv * Vector2(sub_viewport.size)

	var from = camera.project_ray_origin(mouse_pos)
	var dir = camera.project_ray_normal(mouse_pos)

	var new_pos = from + dir * drag_depth
	dragged_item.global_position = new_pos

# ------------------------------------------------
# RELEASE
# ------------------------------------------------

func _release_drag():
	if not dragged_item:
		return

	var shelf = _get_shelf_under_item(dragged_item.global_position)
	if shelf:
		dragged_item.global_position = shelf.get_snap_position()

	dragged_item = null

# ------------------------------------------------
# SHELVES
# ------------------------------------------------

func _get_shelf_under_item(pos: Vector3) -> Node:
	pass
	for shelf in shelves:
		if shelf.is_point_inside(pos):
			return shelf
	return null

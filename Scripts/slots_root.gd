extends Node3D

@export var height : float = 0.8
@export var radius: float = 0.3
var inventory_open: bool = false

var slot_views: Array = []
var slot_states: Array = []


func rebuild_slots(owner_id:int, new_states: Array) -> void:
	slot_states = new_states.duplicate()

	var slots_count := slot_states.size()

	while slot_views.size() < slots_count:
		var view = preload("res://Scenes/slot_view.tscn").instantiate()
		add_child(view)
		slot_views.append(view)

	while slot_views.size() > slots_count:
		var v = slot_views.pop_back()
		v.queue_free()

	
	for i in slots_count:
		var view = slot_views[i]
		view.slot_index = i  
		view.owner_id = owner_id
	update_visual()


func show_slots() -> void:
	inventory_open = true
	update_visual()


func hide_slots() -> void:
	inventory_open = false
	update_visual()


func update_visual() -> void:
	var slots_count := slot_views.size()

	for i in slots_count:
		var view = slot_views[i]
		view.transform.origin = _get_hat_offset(i, slots_count)

		var is_free: bool = slot_states[i]
		var should_show := inventory_open and is_free

		_set_slot_enabled(should_show, view)


func _set_slot_enabled(enabled: bool, view: Node3D) -> void:
	view.get_node("Mesh").visible = enabled

	var area: Area3D = view.get_node("Area3D")
	var shape: CollisionShape3D = area.get_node("CollisionShape3D")

	area.monitoring = enabled
	area.set_collision_layer_value(1, enabled)
	area.set_collision_mask_value(1, enabled)
	shape.disabled = not enabled
	
func _get_hat_offset(
	slot_index: int,
	slots_count: int,
	
	_height: float = height,
	_radius: float = radius
) -> Vector3:

	if slots_count <= 1:
		return Vector3(0.0, height, 0.0)

	var angle := TAU * float(slot_index) / float(slots_count)
	return Vector3(
		cos(angle) * radius,
		height,
		sin(angle) * radius
	)

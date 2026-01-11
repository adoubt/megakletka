extends Node3D

@onready var area: Area3D = $Area3D
@onready var snap_point: Node3D = $SnapPoint

func is_point_inside(pos: Vector3) -> bool:
	return area.get_overlapping_bodies().size() > 0 \
		or area.get_overlapping_areas().size() > 0 \
		or area.global_transform.affine_inverse() * pos

func get_snap_position() -> Vector3:
	return snap_point.global_position

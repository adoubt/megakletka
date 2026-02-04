extends Node3D
class_name ItemInstance

@export var highlight_material: Material
@export var highlight_scale: float = 1.15
@export var rotate_duration: float = 0.2
@export var scale_duration: float = 0.15
@export var yaw_offset := -PI/2  # радианы

@onready var model: Node3D = $Model

var meshes: Array[MeshInstance3D] = []
var original_materials := {} # MeshInstance3D -> Array[Material]

var is_highlighted := false
var base_scale: Vector3
var base_rotation: Vector3

var rotate_tween: Tween
var scale_tween: Tween


func _ready() -> void:
	base_scale = model.scale
	base_rotation = model.rotation
	_collect_meshes(model)


# ------------------------------------------------
# HIGHLIGHT
# ------------------------------------------------

func set_highlight(enabled: bool) -> void:
	if is_highlighted == enabled:
		return

	is_highlighted = enabled
	_kill_tweens()

	# === SCALE ===
	scale_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	scale_tween.tween_property(
		model,
		"scale",
		base_scale * (highlight_scale if enabled else 1.0),
		scale_duration
	)

	# === ROTATION ===
	var target_rot := base_rotation

	if enabled:
		var cam: Camera3D = UIManager.merchant_panel.background_scene.camera
		if cam:
			var look_pos := cam.global_position
			look_pos.y = model.global_position.y

			var dir := look_pos - model.global_position
			target_rot = model.rotation
			target_rot.y = atan2(dir.x, dir.z) + yaw_offset

	rotate_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	rotate_tween.tween_property(
		model,
		"rotation",
		target_rot,
		rotate_duration
	)



# ------------------------------------------------
# INTERNAL
# ------------------------------------------------

func _kill_tweens() -> void:
	if rotate_tween and rotate_tween.is_running():
		rotate_tween.kill()
	if scale_tween and scale_tween.is_running():
		scale_tween.kill()


func _collect_meshes(node: Node) -> void:
	for c in node.get_children():
		if c is MeshInstance3D:
			meshes.append(c)

			var mats: Array[Material] = []
			for i in range(c.mesh.get_surface_count()):
				mats.append(c.get_active_material(i))
			original_materials[c] = mats

		elif c is Node:
			_collect_meshes(c)

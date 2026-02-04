extends BaseSystem
class_name TargetSystem

const CAMERA_ASSIST_DOT := 0.82
const TARGET_Y_OFFSET := 0.0
const ORIGIN_Y_OFFSET := 0.0

var camera_arch: Archetype
var player_arch: Archetype
var enemy_arch: Archetype

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)

	arch = cs.register_archetype(
		["TargetRequestComponent", "AimComponent", "TransformComponent"],
		[ "DeadComponent"]
	)

	camera_arch = cs.register_archetype(
		["CameraComponent"],
		["DeadComponent"]
	)

	player_arch = cs.register_archetype(
		["PlayerComponent", "TransformComponent"],
		["DeadComponent"]
	)

	enemy_arch = cs.register_archetype(
		["EnemyComponent", "TransformComponent"],
		["DeadComponent"]
	)


func update(_delta: float) -> void:
	var entities = arch.entities.duplicate()
	for e_id in entities:
		var req: TargetRequestComponent = cs.get_component(e_id, "TargetRequestComponent")
		if req == null:
			continue

		var tf: TransformComponent = cs.get_component(e_id, "TransformComponent")
		if tf == null:
			continue

		var origin := tf.position
		origin.y += ORIGIN_Y_OFFSET

		var use_camera := req.target_type == TargetType.CAMERA_ASSIST
		
		var cam_forward := Vector3.ZERO

		if use_camera:
			var owner_id = cs.get_component(e_id, "WeaponComponent").owner_id
			cam_forward = _get_camera_forward(owner_id)
			
			if cam_forward == Vector3.ZERO:
				use_camera = false

		var best_pos := Vector3.ZERO
		var best_dist := req.radius * req.radius
		var best_dot := -1.0
		var found := false

		if (req.target_layers & CollisionLayers.PLAYER) != 0:
			var r = _process_candidates(
				player_arch.entities,
				e_id,
				origin,
				cam_forward,
				use_camera,
				best_dist,
				best_dot,
				best_pos
			)
			found = r.found
			best_pos = r.best_pos
			best_dist = r.best_dist
			best_dot = r.best_dot

		if (req.target_layers & CollisionLayers.ENEMY) != 0:
			var r = _process_candidates(
				enemy_arch.entities,
				e_id,
				origin,
				cam_forward,
				use_camera,
				best_dist,
				best_dot,
				best_pos
			)
			found = r.found
			best_pos = r.best_pos
			best_dist = r.best_dist
			best_dot = r.best_dot
			
		var aim = cs.get_component(e_id, "AimComponent")
		aim.has_position = found
		if not found:
			continue
		
		aim.position = best_pos
		
		
		if req.one_shot:
			cs.remove_component(e_id, "TargetRequestComponent")


func _process_candidates(
	candidates: Array,
	owner_id: int,
	origin: Vector3,
	cam_forward: Vector3,
	use_camera: bool,
	best_dist: float,
	best_dot: float,
	best_pos: Vector3
) -> Dictionary:

	var found := false

	for c_id in candidates:
		if c_id == owner_id:
			continue

		var c_tf := cs.get_component(c_id, "TransformComponent")

		var target_pos : Vector3 = c_tf.position
		target_pos.y += TARGET_Y_OFFSET

		var to_target := target_pos - origin
		var dist_sq := to_target.length_squared()

		if dist_sq > best_dist:
			continue

		if use_camera:
			var dot := cam_forward.normalized().dot(to_target.normalized())
			if dot < CAMERA_ASSIST_DOT:
				continue

			if dot > best_dot or (dot == best_dot and dist_sq < best_dist):
				best_dot = dot
				best_dist = dist_sq
				best_pos = target_pos
				found = true
		else:
			best_dist = dist_sq
			best_pos = target_pos
			found = true

	return {
		"found": found,
		"best_pos": best_pos,
		"best_dist": best_dist,
		"best_dot": best_dot
	}



func _get_camera_forward(owner_id: int) -> Vector3:
	for cam_e in camera_arch.entities:
		var cam: CameraComponent = cs.get_component(cam_e, "CameraComponent")
		if cam != null and cam.owner_id == owner_id:
			return -cam.forward.normalized()
	return Vector3.ZERO

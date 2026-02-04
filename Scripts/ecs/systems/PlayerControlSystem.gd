extends BaseSystem
class_name PlayerControlSystem

var camera_arch: Archetype
func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus,):
	super._init( _entity_manager, _component_store, _event_bus)
	arch = cs.register_archetype([
		"InputComponent",
		"MovementIntentComponent"
	])
	camera_arch = cs.register_archetype(
		["CameraComponent"],
		["DeadComponent"]
	)
func update(_delta):


	for e in arch.entities:
		var input := cs.get_component(e, "InputComponent")
		var intent := cs.get_component(e, "MovementIntentComponent")

		# --- ищем камеру, которая смотрит на нас ---
		var cam_forward := Vector3.FORWARD
		var cam_right := Vector3.RIGHT
		var camera_id = -1
		for cam_e in camera_arch.entities:
			if cs.get_component(cam_e, "CameraComponent").owner_id == e:
				camera_id = cam_e
				break
					
		var cam = cs.components["CameraComponent"][camera_id]
		cam_forward = cam.forward
		cam_right = cam.right
		

		var forward := cam_forward
		forward.y = 0
		forward = forward.normalized()

		var right := cam_right
		right.y = 0
		right = right.normalized()

		var dir = forward * input.move.y + right * input.move.x


		if dir.length_squared() > 0.0001:
			dir = dir.normalized()

		intent.direction = dir

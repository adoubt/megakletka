extends BaseSystem
class_name CameraToggleSystem
var camera_arch :Archetype
func _init( _entity_manager: EntityManager, _component_store: ComponentStore,_event_bus: EventBus):
	super._init( _entity_manager, _component_store, _event_bus)
	camera_arch = cs.register_archetype(["CameraComponent"])
	arch = cs.register_archetype(["InputComponent"])

func update(_delta):
	
	for e in arch.entities:
		var input = cs.get_component(e, "InputComponent")
		if input.camera_toggle:
			_toogle_camera(e)
			

func _toogle_camera(e):
	var entities := camera_arch.entities
	for cam_e in entities:
		var cam_comp = cs.get_component(cam_e, "CameraComponent")
		if cam_comp.camera_instance.current:
			cs.get_component(e, "RenderComponent").instance.camera.current = true
		
		else:
			cam_comp.camera_instance.current = true
		return

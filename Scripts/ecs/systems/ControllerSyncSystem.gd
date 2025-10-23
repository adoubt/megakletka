# res://ecs/systems/ControllerSyncSystem.gd
extends BaseSystem
class_name ControllerSyncSystem

var cash_state 
# Called when the node enters the scene tree for the first time.
func update(_delta:float) -> void:
	var entities = get_entities_with(["ControllerStateComponent"])
	
	for entity_id in entities:
		var render = cs.get_component(entity_id, "RenderComponent")
		if render.instance == null: 
			continue
		## Обновляю позицию игрока
		cs.get_component(entity_id, "TransformComponent").position = render.instance.global_position
		
		## Обновляю STATE (На будущие модификаторы пригодится)
		var controller = cs.get_component(entity_id, "ControllerStateComponent")
		
		controller.current_state = render.instance.current_state 
		if controller.current_state != cash_state:
			print("state ", cash_state)
		cash_state = controller.current_state
	

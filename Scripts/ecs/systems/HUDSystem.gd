extends BaseSystem
class_name  HUDSystem

var event_bus:EventBus


func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store)
	event_bus = _event_bus

	event_bus.subscribe("level_up_offer_created", _on_level_up_offer_created)
	
func update(delta: float) -> void:
	var entities = get_entities_with(["HUDComponent"])
	for e_id in entities:
		var current_hp = cs.get_component(e_id,"CurrentHpComponent")
		var max_hp = cs.get_component(e_id,"MaxHpComponent")

		
		if current_hp and max_hp:
			UIManager.hud.current_hp = current_hp.final_value
			UIManager.hud.max_hp = max_hp.final_value
func _on_level_up_offer_created(callback_data: Dictionary):
		
	UIManager.hud.setup_upgrade_buttons(callback_data["offer_id"], callback_data["offer"])
		

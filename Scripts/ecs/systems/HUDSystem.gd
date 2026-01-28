extends BaseSystem
class_name  HUDSystem



func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)


	event_bus.subscribe("level_up_offer_created", _on_level_up_offer_created)
	event_bus.subscribe("level_up_panel_toggled", _on_level_up_panel_toggled)
	event_bus.subscribe("day_changed", _on_day_changed)
	event_bus.subscribe("phase_changed", _on_phase_changed)
	
	event_bus.subscribe("combat_started",_on_combat_started)
	event_bus.subscribe("combat_completed",_on_combat_completed)
	event_bus.subscribe("budget_changed",_on_budget_changed)
	
	
## TODO переделать под ивент из системы
func update(_delta: float) -> void:
	var entities = get_entities_with(["HUDComponent"])
	for e_id in entities:
		var current_hp = cs.get_component(e_id,"CurrentHpComponent")
		var max_hp = cs.get_component(e_id,"MaxHpComponent")

		
		if current_hp and max_hp:
			UIManager.hud.current_hp = current_hp.final_value
			UIManager.hud.max_hp = max_hp.final_value
		
func _on_level_up_offer_created(callback_data: Dictionary):
		
	
	UIManager.level_up_panel.setup_background(callback_data["offer"])

func _on_level_up_panel_toggled()-> void:
	var entities = get_entities_with(["LevelUpOfferComponent"])
	for entity_id in entities:
		var owner_id = cs.get_component(entity_id,"LevelUpOfferComponent").owner_id
		var instance = cs.get_component(owner_id, "RenderComponent").instance
		if not instance: 
			continue	
		if UIManager.is_panel_open("LevelUpPanel"):
			instance.hide_level_up() 
		else:
			instance.show_level_up()
			
func _on_day_changed(data: Dictionary = {}) -> void:
	var current_day = data.current_day
	UIManager.hud.set_current_day(current_day)	
			
func _on_phase_changed(data: Dictionary = {}) -> void:		
	var current_phase = data.current_phase
	UIManager.hud.set_current_phase(current_phase)	
	
func _on_combat_started(_data: Dictionary = {}) -> void:	
	UIManager.hud.show_combat_progress()
	UIManager.hud.set_current_combat_progress(1.0)
	
func _on_combat_completed(_data: Dictionary = {}) -> void:	
	UIManager.hud.hide_combat_progress()

func _on_budget_changed(data: Dictionary = {}) -> void:
	var progress: float = float(data.alive_budget) / float(data.max_budget)
	UIManager.hud.set_current_combat_progress(progress)

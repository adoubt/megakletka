extends BaseSystem
class_name  HUDSystem


var player_arch: Archetype
var level_offer_arch: Archetype

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)


	event_bus.subscribe("level_up_offer_created", _on_level_up_offer_created)
	event_bus.subscribe("level_up_panel_toggled", _on_level_up_panel_toggled)
	event_bus.subscribe("day_changed", _on_day_changed)
	event_bus.subscribe("phase_changed", _on_phase_changed)
	
	event_bus.subscribe("combat_started",_on_combat_started)
	event_bus.subscribe("combat_completed",_on_combat_completed)
	event_bus.subscribe("budget_changed",_on_budget_changed)
	event_bus.subscribe("hp_changed",_on_hp_changed)
	event_bus.subscribe("xp_changed", _on_xp_changed)
	event_bus.subscribe("players_list_changed",_on_players_list_changed)
	event_bus.subscribe("balance_changed",_on_balance_changed)

	level_offer_arch = cs.register_archetype(["LevelUpOfferComponent"])
	player_arch = cs.register_archetype(["PlayerComponent",])

		
func _on_level_up_offer_created(callback_data: Dictionary):
		
	
	UIManager.level_up_panel.setup_background(callback_data["offer"])

func _on_level_up_panel_toggled()-> void:
	for entity_id in level_offer_arch.entities:
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

func _on_hp_changed(data: Dictionary = {}) -> void:
	var e_id = data.e_id
	if e_id not in player_arch.entities:
		return
	if UIManager.owner_id != e_id:
		return
	var max_hp = data.get("max_hp", null)
	var current_hp = data.get("current_hp", null)
	if max_hp:
		UIManager.hud.set_max_hp(max_hp)
	if current_hp:
		UIManager.hud.set_current_hp(current_hp)
	
func _on_xp_changed(data: Dictionary = {}) -> void:
	var e_id = data.e_id
	if e_id not in player_arch.entities:
		return 
	if UIManager.owner_id != e_id:
		return
	var current_level = data.get("ceurrent_level", null)
	var current_xp = data.get("current_xp", null)
	var xp_to_next = data.get("xp_to_next", null)
	if xp_to_next: UIManager.hud.max_xp = xp_to_next
	UIManager.hud.current_xp = current_xp
	if current_level: UIManager.hud.current_level = current_level
	
	
	
func _on_players_list_changed(data:Dictionary = {}) ->void:
	pass
func _on_balance_changed(data: Dictionary):
	var current_balance: int = data.current_balance
	var value:int= data.value
	UIManager.hud.set_current_log_balance(current_balance)

extends BaseSystem
class_name  HUDSystem

var cached_stats := {} # entity_id -> Dictionary

var player_arch: Archetype
var level_offer_arch: Archetype

func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus: EventBus):
	super._init(_entity_manager, _component_store, _event_bus)

	
	event_bus.subscribe("level_up_offer_created", _on_level_up_offer_created)
	event_bus.subscribe("level_up_panel_toggled", _on_level_up_panel_toggled)
	event_bus.subscribe("day_changed", _on_day_changed)
	event_bus.subscribe("phase_changed", _on_phase_changed)
	event_bus.subscribe("map_snapshot_changed",_on_map_snaphot_changed)
	event_bus.subscribe("combat_started",_on_combat_started)
	event_bus.subscribe("combat_completed",_on_combat_completed)
	event_bus.subscribe("day_skipped",_on_combat_completed)
	event_bus.subscribe("budget_changed",_on_budget_changed)
	#event_bus.subscribe("hp_changed",_on_hp_changed)
	#event_bus.subscribe("xp_changed", _on_xp_changed)
	event_bus.subscribe("players_list_changed",_on_players_list_changed)
	event_bus.subscribe("balance_changed",_on_balance_changed)
	event_bus.subscribe("stats_snapshot_ready",_on_stats_snapshot_ready)
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
	UIManager.close_all()
	UIManager.open_hud()
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


func _on_balance_changed(data:Dictionary):
	UIManager.hud.balance = data.balance
	
func _on_players_list_changed(data:Dictionary = {}) ->void:
	pass

	
func _on_stats_snapshot_ready(data: Dictionary) -> void:
	var e_id :int= data.entity
	if UIManager.owner_id != e_id:
		return

	var snapshot :Dictionary= data.snapshot
	var prev = cached_stats.get(e_id, {})

	for stat_id in snapshot.keys():
		var new_val = snapshot[stat_id]
		var old_val = prev.get(stat_id, null)

		if old_val == null or not is_equal_approx(old_val, new_val):
			_on_stat_changed(stat_id, new_val)

	cached_stats[e_id] = snapshot.duplicate(true)
func _on_map_snaphot_changed(data: Dictionary) ->void:
	UIManager.map_panel.redraw_from_snapshot(data)
func _on_stat_changed(stat: int, value: float):
	match stat:

		# ===== DAMAGE / COMBAT =====
		Stats.PlayerStats.DAMAGE_MULT:
			UIManager.hud.damage = value

		Stats.PlayerStats.ARMOR:
			UIManager.hud.armor = value

		Stats.PlayerStats.CRIT_DAMAGE:
			pass

		Stats.PlayerStats.CRIT_CHANCE:
			pass

		Stats.PlayerStats.PIERCE:
			UIManager.hud.pierce = value

		Stats.PlayerStats.ATK_SPEED:
			UIManager.hud.attack_speed = value


		# ===== HP =====
		Stats.PlayerStats.MAX_HP:
			UIManager.hud.max_hp = value
		Stats.PlayerStats.CURRENT_HP:
			UIManager.hud.current_hp = value
			# если надо абсолютное HP:
			# UIManager.hud.set_current_hp(value * max_hp)


		# ===== MOVEMENT =====
		Stats.PlayerStats.MOVESPEED:
			UIManager.hud.movespeed = value

		Stats.PlayerStats.MOVESPEED_MULT:
			pass


		# ===== JUMPS =====
		Stats.PlayerStats.JUMPS_COUNT:
			UIManager.hud.jumps_count = value

		Stats.PlayerStats.JUMPS_LEFT:
			UIManager.hud.jumps_left = value

		Stats.PlayerStats.JUMP_HEIGHT:
			pass


		# ===== PROJECTILES =====
		Stats.PlayerStats.PROJ_COUNT:
			pass

		Stats.PlayerStats.PROJ_RADIUS:
			pass

		Stats.PlayerStats.WEAPON_RADIUS:
			pass


		# ===== XP / LEVEL =====
		Stats.PlayerStats.CURRENT_XP:
			UIManager.hud.current_xp = value

		Stats.PlayerStats.XP_LEFT:
			UIManager.hud.required_xp = value

		Stats.PlayerStats.XP_GAIN:
			UIManager.hud.xp_gain = value

		Stats.PlayerStats.LEVEL:
			UIManager.hud.current_level = value

		Stats.PlayerStats.UNUSED_LEVEL_POINTS:
			pass


		# ===== META / GAMEPLAY =====
		Stats.PlayerStats.SLOTS:
		
			UIManager.hud.slots_count = value
		Stats.PlayerStats.USED_SLOTS:
			UIManager.hud.used_slots_count = value
		Stats.PlayerStats.DURATION_MULT:
			UIManager.hud.duration = value

		Stats.PlayerStats.MERCHANT_DISCOUNT:
			pass

		
		_:
			# стат есть, но HUD его не отображает
			pass

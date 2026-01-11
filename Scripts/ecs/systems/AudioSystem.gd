extends BaseSystem
class_name AudioSystem



func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus : EventBus): 
	super._init(_entity_manager, _component_store, _event_bus)
	event_bus.subscribe("enemy_died", _on_enemy_died)
	event_bus.subscribe("enemy_damaged", _on_enemy_hitted)
	event_bus.subscribe("level_up", _on_level_up)
func _on_enemy_died(data: Dictionary):
	var _sounds = [
		"enemy_death",
		"enemy_death2",
		"enemy_death3",
		"enemy_death4",
		"enemy_death5",
		"enemy_death6"
	]

	var rand_index = randi() % _sounds.size()
	var chosen_sound = _sounds[rand_index]
	var pos = data["position"]
	AudioManager.play_sound(chosen_sound, pos)
	
func _on_enemy_hitted(data: Dictionary):
	var _sounds = [
		"enemy_hitted",
		"enemy_hitted2"
	]
	var rand_index = randi() % _sounds.size()
	var chosen_sound = _sounds[rand_index]
	var pos = data["position"]
	AudioManager.play_sound(chosen_sound, pos)
	
	#event_bus.subscribe("game_started", _on_game_started)
	#event_bus.subscribe("game_paused", _on_game_paused)
	#event_bus.subscribe("game_resumed", _on_game_resumed)
	#event_bus.subscribe("game_over", _on_game_over)
#
	#event_bus.subscribe("run_started", _on_run_started)
	#event_bus.subscribe("run_finished", _on_run_finished)
#
	#event_bus.subscribe("music_play", _on_music_play)
	#event_bus.subscribe("music_stop", _on_music_stop)
	#event_bus.subscribe("music_fade_out", _on_music_fade_out)
	#event_bus.subscribe("music_crossfade", _on_music_crossfade)
#
	#event_bus.subscribe("combat_started", _on_combat_music)
	#event_bus.subscribe("combat_finished", _on_combat_music_end)
#
	#event_bus.subscribe("floor_entered", _on_floor_entered)
	#event_bus.subscribe("floor_cleared", _on_floor_cleared)
	#event_bus.subscribe("boss_started", _on_boss_music)
	#event_bus.subscribe("boss_defeated", _on_boss_music_end)
#
	#event_bus.subscribe("enemy_created", _on_enemy_spawned)
	#event_bus.subscribe("player_attack", _on_player_attack)
	#event_bus.subscribe("enemy_attack", _on_enemy_attack)
#
	#event_bus.subscribe("projectile_fired", _on_projectile_fired)
	#event_bus.subscribe("projectile_hit", _on_projectile_hit)
#

	#event_bus.subscribe("critical_hit", _on_critical_hit)
	#event_bus.subscribe("execute_hit", _on_execute_hit)
#
	#event_bus.subscribe("hit_blocked", _on_hit_blocked)
	#event_bus.subscribe("hit_missed", _on_hit_missed)
#
	#event_bus.subscribe("player_damaged", _on_player_damaged)
	#event_bus.subscribe("player_healed", _on_player_healed)
	#event_bus.subscribe("player_died", _on_player_died)
#
	#event_bus.subscribe("enemy_damaged", _on_enemy_damaged)
	#event_bus.subscribe("enemy_executed", _on_enemy_executed)
#
	#event_bus.subscribe("player_step", _on_player_step)
	#event_bus.subscribe("player_landed", _on_player_landed)
	#event_bus.subscribe("player_jumped", _on_player_jumped)
	#event_bus.subscribe("player_dashed", _on_player_dashed)
#
	#event_bus.subscribe("object_fell", _on_object_fell)
	#event_bus.subscribe("object_bounced", _on_object_bounced)
#
	#event_bus.subscribe("item_picked", _on_item_picked)
	#event_bus.subscribe("item_dropped", _on_item_dropped)
	#event_bus.subscribe("item_used", _on_item_used)
#
	#event_bus.subscribe("upgrade_offered", _on_upgrade_offered)
	#event_bus.subscribe("upgrade_chosen", _on_upgrade_chosen)
	#event_bus.subscribe("upgrade_applied", _on_upgrade_applied)
#
	
	#event_bus.subscribe("xp_gained", _on_xp_gained)
#
	#event_bus.subscribe("poi_discovered", _on_poi_discovered)
	#event_bus.subscribe("poi_interacted", _on_poi_interacted)
	#event_bus.subscribe("dialog_started", _on_dialog_started)
	#event_bus.subscribe("dialog_finished", _on_dialog_finished)
#
	#event_bus.subscribe("ui_open", _on_ui_open)
	#event_bus.subscribe("ui_close", _on_ui_close)
	#event_bus.subscribe("ui_click", _on_ui_click)
	#event_bus.subscribe("ui_hover", _on_ui_hover)
	#event_bus.subscribe("ui_error", _on_ui_error)
#
	#event_bus.subscribe("menu_opened", _on_menu_opened)
	#event_bus.subscribe("menu_closed", _on_menu_closed)

func _on_level_up(data: Dictionary):
	var _sounds = [
		
		"level_up"
	]
	
	var rand_index = randi() % _sounds.size()
	var chosen_sound = _sounds[rand_index]
	AudioManager.play_ui_sound(chosen_sound)

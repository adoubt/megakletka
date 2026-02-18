extends BaseSystem
class_name AudioSystem



func _init(_entity_manager: EntityManager, _component_store: ComponentStore, _event_bus : EventBus): 
	super._init(_entity_manager, _component_store, _event_bus)
	event_bus.subscribe("enemy_died", _on_enemy_died)
	event_bus.subscribe("DAMAGE_RECIVED", _on_enemy_hitted)
	event_bus.subscribe("level_up", _on_level_up)
	event_bus.subscribe("campfire_created",_on_campfire_created)
	event_bus.subscribe("day_changed", _on_day_changed)
	event_bus.subscribe("combat_completed", _on_combat_completed)
	event_bus.subscribe("combat_started", _on_combat_started)
	event_bus.subscribe("player_died", _on_died)
	event_bus.subscribe("balance_changed",_on_balance_changed)
	event_bus.subscribe("purchased",_on_purchased)
func _on_enemy_died(data: Dictionary = {}) -> void:
	var enemy_name: String = data.get("_name", "")
	var pos: Vector3 = data.get("position", Vector3.ZERO)

	# формируем ключи
	var primary_key := "%s_died" % enemy_name       # goblin_died
	var fallback_key := "enemy_died"                # общий

	AudioManager.play_sound_with_fallback(
		primary_key,
		fallback_key,
		pos
	)
	
func _on_enemy_hitted(data: Dictionary = {}) -> void:
	var enemy_name: String = data.get("_name", "")
	var pos: Vector3 = data.get("position", Vector3.ZERO)

	# формируем ключи
	var primary_key := "%s_hitted" % enemy_name       # goblin_hitted
	var fallback_key := "enemy_hitted"                # общий

	AudioManager.play_sound_with_fallback(
		primary_key,
		fallback_key,
		pos,
		-20.0
	)
	
func _on_level_up(_data: Dictionary = {}):
	
	AudioManager.play_ui_sound("level_up")
	
func _on_campfire_created(_data: Dictionary = {})-> void:
	
	AudioManager.play_spatial_loop("campfire0", "campfire_crackling", Vector3.ZERO, -5.0, 50.0)

func _on_combat_started(_data: Dictionary = {}) -> void:
	AudioManager.play_music_delayed("combat_started_signal",0.0,0.0,false)
	
	AudioManager.play_music_delayed("combat_started",2.0,0.0,true)
	
	
func _on_combat_completed(_data: Dictionary = {}) -> void:
	AudioManager.play_music_delayed("combat_completed_signal",0.0,0.0,false)
	
	AudioManager.play_music_delayed("combat_completed",4.0,0.0,true)
	
func _on_day_changed(_data: Dictionary = {}) -> void:
	AudioManager.play_music_delayed("day_changed",0.5,-5.0,false)
	#AudioManager.play_music_delayed("idle",7.0,0.0,true)
func _on_died(_data: Dictionary = {}) -> void:
	AudioManager.play_music_delayed("death",0.0,-5.0,false)
func _on_balance_changed(data: Dictionary = {}) -> void:
	var value = data.value
	if value > 0:
		AudioManager.play_ui_sound("money_arrived")
func _on_purchased(_data: Dictionary = {}) -> void:
	AudioManager.play_ui_sound("purchased")

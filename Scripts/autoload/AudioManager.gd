extends Node3D
var music_generation: int = 0

var dynamic_sources: Array = []

var object_sources: Dictionary = {} # node -> AudioStreamPlayer3D

var music_players: Dictionary = {} # _name -> AudioStreamPlayer3D
var music_fades: Dictionary = {} # _name -> Tween
var ui_sources: Dictionary = {}

var spatial_loops: Dictionary = {} # key -> AudioStreamPlayer3D

func reset_audio_context():
	music_generation += 1

var ui_player: AudioStreamPlayer
func _ready() -> void:
	ui_player= AudioStreamPlayer.new()
	ui_player.bus = "SFX"
	add_child(ui_player)
	apply_volume("Master",SettingsManager.get_value("master_volume"))
	apply_volume("Music",SettingsManager.get_value("music_volume"))
	apply_volume("SFX",SettingsManager.get_value("sfx_volume"))
## One-shot UI sound
func play_ui_sound(_name: String, volume_db: float = -10.0, pitch_range: Vector2 = Vector2(0.9,1.1)) -> void:
	var entry = DatabaseManager.db.sound_configs["non_diegetic"]["ui"].get(_name, null)
	if entry == null:
		push_error("AudioManager: sound not found in DB: %s" % _name)
		return

	var path: String

	if entry is Array and entry.size()>0:
		path = entry.pick_random()
	elif entry is String:
		path = entry
	else:
		push_error("AudioManager: invalid sound entry: %s" % _name)
		return

	var new_ui_player = AudioStreamPlayer.new()
	new_ui_player.bus = "SFX"
	new_ui_player.stream = load(path)
	new_ui_player.volume_db = volume_db
	new_ui_player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)
	add_child(new_ui_player)
	
	new_ui_player.play()
	
	ui_sources[_name] = new_ui_player
	new_ui_player.connect("finished", Callable(self, "_on_ui_finished").bind(new_ui_player))

## One-shot sound within 3D Position
func play_sound(
	_name: String,
	_position: Vector3,
	volume_db: float = 0.0,
	pitch_range: Vector2 = Vector2(0.9,1.1),
	max_distance: float = 15.0) -> void:

	var entry = DatabaseManager.db.sound_configs["diegetic"]["one_shot"].get(_name, null)
	if entry == null:
		push_error("AudioManager: sound not found in DB: %s" % _name)
		return

	var path: String

	if entry is Array:
		path = entry.pick_random()
	elif entry is String:
		path = entry
	else:
		push_error("AudioManager: invalid sound entry: %s" % _name)
		return

	var player = AudioStreamPlayer3D.new()
	player.bus = "SFX"
	player.stream = load(path)
	player.global_transform.origin = _position
	player.volume_db = volume_db
	player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)
	player.max_distance = max_distance
	player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE

	add_child(player)
	player.play()
	dynamic_sources.append(player)
	player.connect("finished", Callable(self, "_on_dynamic_finished").bind(player))

func play_sound_with_fallback(
	primary_key: String,
	fallback_key: String,
	_position: Vector3,
	volume_db: float = 0.0,
	pitch_range: Vector2 = Vector2(0.9, 1.1),
	max_distance: float = 15.0) -> void:

	var one_shot = DatabaseManager.db.sound_configs["diegetic"]["one_shot"]

	var sounds: Array = []

	if one_shot.has(primary_key):
		sounds = one_shot[primary_key]
	elif one_shot.has(fallback_key):
		sounds = one_shot[fallback_key]
	else:
		push_error(
			"AudioManager: sound not found (%s, %s)" %
			[primary_key, fallback_key]
		)
		return

	var path :String = sounds.pick_random()

	_play_path(path, _position, volume_db, pitch_range, max_distance)


func _on_dynamic_finished(player: AudioStreamPlayer3D):
	if dynamic_sources.has(player):
		dynamic_sources.erase(player)
	if is_instance_valid(player):
		player.queue_free()



	

func _on_ui_finished(player: AudioStreamPlayer):
	if ui_sources.has(player):
		ui_sources.erase(player)
	if is_instance_valid(player):
		player.queue_free()

## UI play music
func play_music(_name: String, volume_db: float = 0.0, loop: bool = true, generation:int = music_generation) -> void:
	if generation!= music_generation:
		return
	_stop_non_diegetic_music()
	

	var entry = DatabaseManager.db.sound_configs["non_diegetic"]["music"].get(_name, null)
	if entry == null:
		push_error("AudioManager: sound not found in DB: %s" % _name)
		return

	var path: String

	if entry is Array and entry.size() > 0:
		path = entry.pick_random()
	elif entry is String:
		path = entry
	else:
		push_error("AudioManager: invalid sound entry: %s" % _name)
		return

	var player = AudioStreamPlayer.new()
	player.bus = "Music"
	player.stream = load(path)
	player.volume_db = volume_db
	player.stream.loop = loop
	
	add_child(player)
	player.play()
	music_players[_name] = player

func stop_all_music():
	_stop_diegetic_music()
	_stop_non_diegetic_music()
	
func _stop_non_diegetic_music():
	for s in music_players.keys():
		stop_music(s)
		
func _stop_diegetic_music():
	for s in spatial_loops.keys():
		stop_spatial_loop(s)
		
		
## UI stop music (with fade out)
func stop_music(_name: String) -> void:
	if not music_players.has(_name):
		return

	var player = music_players[_name]
	if is_instance_valid(player):
		player.stop()
		player.queue_free()
	music_players.erase(_name)


## Play persistent source sound, also check unregister_persistent()
func register_persistent(_name: String, node: Node3D, loop: bool = true, volume_db: float = 0.0) -> void:
	if object_sources.has(node):
		return

	var path = DatabaseManager.db.sound_configs["diegetic"]["persistent"][_name]
	if path == null:
		push_error("AudioManager: object sound not found: %s" % _name)
		return

	var player = AudioStreamPlayer3D.new()
	player.bus = "SFX"
	player.stream = load(path)
	player.loop = loop
	player.volume_db = volume_db
	player.transform = node.global_transform
	node.add_child(player)
	player.play()
	object_sources[node] = player
	
## Stop persistent source sound
func unregister_persistent(node: Node3D) -> void:
	if object_sources.has(node):
		var player = object_sources[node]
		if is_instance_valid(player):
			player.queue_free()
		object_sources.erase(node)
		
## Nodeless method for persistent source sound
func play_spatial_loop(
	key: String,
	sound_name: String,
	_position: Vector3,
	volume_db: float = 0.0,
	max_distance: float = 20.0
) -> void:
	if spatial_loops.has(key):
		var _player = spatial_loops[key]
		_player.global_position = _position
		if not _player.playing:
			_player.play()
		return

	var path = DatabaseManager.db.sound_configs["diegetic"]["persistent"].get(sound_name, null)
	if path == null:
		push_error("AudioManager: spatial loop not found: %s" % sound_name)
		return

	var player := AudioStreamPlayer3D.new()
	add_child(player)
	player.bus = "SFX"
	player.stream = load(path)
	player.stream.loop = true
	player.volume_db = volume_db
	player.global_position = position
	player.max_distance = max_distance
	player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE

	
	player.play()
	spatial_loops[key] = player

func stop_spatial_loop(key: String) -> void:
	if not spatial_loops.has(key):
		return

	var player = spatial_loops[key]
	if is_instance_valid(player):
		player.stop()
		player.queue_free()

	spatial_loops.erase(key)
## Useless method
func update_spatial_loop_position(key: String, _position: Vector3) -> void:
	if spatial_loops.has(key):
		spatial_loops[key].global_position = _position

func _play_path(
	path: String,
	_position: Vector3,
	volume_db: float,
	pitch_range: Vector2,
	max_distance: float
) -> void:
	var player := AudioStreamPlayer3D.new()
	add_child(player)
	player.bus = "SFX"
	player.stream = load(path)
	player.global_transform.origin = _position
	player.volume_db = volume_db
	player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)
	player.max_distance = max_distance
	player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE

	
	player.play()
	dynamic_sources.append(player)
	player.finished.connect(_on_dynamic_finished.bind(player))

func play_music_delayed(_name: String,delay: float,volume_db: float = 0.0,loop: bool = true) -> void:
	var timer := get_tree().create_timer(delay)
	var current_generation: int = music_generation
	timer.timeout.connect(func(): play_music(_name, volume_db, loop, current_generation))

	
func _resolve_audio_entry(entry) -> String:
	if entry == null:
		return ""

	if entry is Array:
		if entry.is_empty():
			return ""
		return entry.pick_random()

	if entry is String:
		return entry

	return ""


func play_ui_sound_with_fallback(
	primary_key: String,
	fallback_key: String,
	volume_db: float = -10.0,
	pitch_range: Vector2 = Vector2(1.0, 1.0)
) -> void:
	var ui_db = DatabaseManager.db.sound_configs["non_diegetic"]["ui"]

	var entry = null
	if ui_db.has(primary_key):
		entry = ui_db[primary_key]
	elif ui_db.has(fallback_key):
		entry = ui_db[fallback_key]
	else:
		push_error(
			"AudioManager: UI sound not found (%s, %s)" %
			[primary_key, fallback_key]
		)
		return

	var path := _resolve_audio_entry(entry)
	if path == "":
		push_error("AudioManager: invalid UI sound entry")
		return

	ui_player.stream = load(path)
	ui_player.volume_db = volume_db
	ui_player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)
	ui_player.play()

func play_music_with_fallback(
	primary_key: String,
	fallback_key: String,
	volume_db: float = 0.0,
	loop: bool = true
) -> void:
	if music_players.has(primary_key):
		var existing = music_players[primary_key]
		existing.volume_db = volume_db
		if not existing.playing:
			existing.play()
		return

	var music_db = DatabaseManager.db.sound_configs["non_diegetic"]["music"]

	var entry = null
	if music_db.has(primary_key):
		entry = music_db[primary_key]
	elif music_db.has(fallback_key):
		entry = music_db[fallback_key]
	else:
		push_error(
			"AudioManager: music not found (%s, %s)" %
			[primary_key, fallback_key]
		)
		return

	var path := _resolve_audio_entry(entry)
	if path == "":
		push_error("AudioManager: invalid music entry")
		return

	var player := AudioStreamPlayer.new()
	player.bus = "Music"
	add_child(player)
	player.stream = load(path)
	player.stream.loop = loop
	player.volume_db = volume_db

	
	player.play()

	music_players[primary_key] = player



func apply_volume(bus:String, value: float) -> void:
	value = clamp(value, 0.0, 1.0)

	var db := linear_to_db(value)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index(bus),
		db
	)

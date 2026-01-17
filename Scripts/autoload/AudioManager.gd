extends Node3D

var dynamic_sources: Array = []

var object_sources: Dictionary = {} # node -> AudioStreamPlayer3D

var music_players: Dictionary = {} # _name -> AudioStreamPlayer3D

var ui_sources: Array = []

var spatial_loops: Dictionary = {} # key -> AudioStreamPlayer3D


var ui_player: AudioStreamPlayer
func _ready() -> void:
	ui_player= AudioStreamPlayer.new()
	add_child(ui_player)
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

## One-shot UI sound
func play_ui_sound(_name: String, volume_db: float = -10.0, pitch_range: Vector2 = Vector2(1.0,1.0)) -> void:
	var path = DatabaseManager.db.sound_configs["non_diegetic"]["ui"][_name]
	if path == null:
		push_error("AudioManager: UI sound not found: %s" % _name)
		return

	
	ui_player.stream = load(path)
	ui_player.volume_db = volume_db
	ui_player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)

	
	ui_player.play()

	

func _on_ui_finished(player: AudioStreamPlayer):
	if ui_sources.has(player):
		ui_sources.erase(player)
	if is_instance_valid(player):
		player.queue_free()

## UI play music
func play_music(_name: String, volume_db: float = 0.0, loop: bool = true) -> void:
	if music_players.has(_name):
		var existing = music_players[_name]
		existing.volume_db = volume_db
		if not existing.playing:
			existing.play()
		return

	var path = DatabaseManager.db.sound_configs["non_diegetic"]["music"][_name]
	if path == null:
		push_error("AudioManager: music not found: %s" % _name)
		return

	var player = AudioStreamPlayer3D.new()
	player.stream = load(path)
	player.volume_db = volume_db
	player.stream.loop = true
	player.play()
	add_child(player)
	music_players[_name] = player
	
## UI stop music
func stop_music(_name: String) -> void:
	if music_players.has(_name):
		var player = music_players[_name]
		player.stop()
		if is_instance_valid(player):
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
		var player = spatial_loops[key]
		player.global_position = _position
		if not player.playing:
			player.play()
		return

	var path = DatabaseManager.db.sound_configs["diegetic"]["persistent"].get(sound_name, null)
	if path == null:
		push_error("AudioManager: spatial loop not found: %s" % sound_name)
		return

	var player := AudioStreamPlayer3D.new()
	player.stream = load(path)
	player.stream.loop = true
	player.volume_db = volume_db
	player.global_position = position
	player.max_distance = max_distance
	player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE

	add_child(player)
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
func update_spatial_loop_position(key: String, position: Vector3) -> void:
	if spatial_loops.has(key):
		spatial_loops[key].global_position = position

func _play_path(
	path: String,
	_position: Vector3,
	volume_db: float,
	pitch_range: Vector2,
	max_distance: float
) -> void:
	var player := AudioStreamPlayer3D.new()
	player.stream = load(path)
	player.global_transform.origin = _position
	player.volume_db = volume_db
	player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)
	player.max_distance = max_distance
	player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE

	add_child(player)
	player.play()
	dynamic_sources.append(player)
	player.finished.connect(_on_dynamic_finished.bind(player))

func play_music_delayed(_name: String,delay: float,volume_db: float = 0.0,loop: bool = true) -> void:
	var timer := get_tree().create_timer(delay)
	timer.timeout.connect(func(): play_music(_name, volume_db, loop))

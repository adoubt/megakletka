extends Node3D

# Чистый менеджер звука, работает с базой данных


# Динамические/однократные 3D звуки
var dynamic_sources: Array = []

# Объектные источники (постоянные, привязаны к нодам)
var object_sources: Dictionary = {} # node -> AudioStreamPlayer3D

# Фоновая музыка
var music_players: Dictionary = {} # name -> AudioStreamPlayer3D

# UI звуки (не позиционные)
var ui_sources: Array = []

var ui_player: AudioStreamPlayer
func _ready() -> void:
	ui_player= AudioStreamPlayer.new()
	add_child(ui_player)
# ==================== ПОЗИЦИОННЫЕ 3D ЗВУКИ ====================
func play_sound(name: String, position: Vector3, volume_db: float = 0.0, pitch_range: Vector2 = Vector2(0.9,1.1), max_distance: float = 15.0) -> void:
	var path = DatabaseManager.db.sound_configs["diegetic"]["one_shot"].get(name, null)
	if path == null:
		push_error("AudioManager: sound not found in DB: %s" % name)
		return

	var player = AudioStreamPlayer3D.new()
	player.stream = load(path)
	player.global_transform.origin = position
	player.volume_db = volume_db
	player.pitch_scale = randf_range(pitch_range.x, pitch_range.y)
	
	# ⚡ Ограничиваем дальность слышимости и ставим модель затухания
	player.max_distance = max_distance
	player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE

	add_child(player)
	player.play()
	dynamic_sources.append(player)

	player.connect("finished", Callable(self, "_on_dynamic_finished").bind(player))


func _on_dynamic_finished(player: AudioStreamPlayer3D):
	if dynamic_sources.has(player):
		dynamic_sources.erase(player)
	if is_instance_valid(player):
		player.queue_free()

# ==================== UI ЗВУКИ ====================
func play_ui_sound(name: String, volume_db: float = -10.0, pitch_range: Vector2 = Vector2(1.0,1.0)) -> void:
	var path = DatabaseManager.db.sound_configs["non_diegetic"]["ui"][name]
	if path == null:
		push_error("AudioManager: UI sound not found: %s" % name)
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

# ==================== ФОНОВАЯ МУЗЫКА ====================
func play_music(name: String, volume_db: float = 0.0, loop: bool = true) -> void:
	if music_players.has(name):
		var existing = music_players[name]
		existing.volume_db = volume_db
		if not existing.playing:
			existing.play()
		return

	var path = DatabaseManager.db.sound_configs["non_diegetic"]["music"][name]
	if path == null:
		push_error("AudioManager: music not found: %s" % name)
		return

	var player = AudioStreamPlayer3D.new()
	player.stream = load(path)
	player.volume_db = volume_db
	player.loop = loop
	player.play()
	add_child(player)
	music_players[name] = player

func stop_music(name: String) -> void:
	if music_players.has(name):
		var player = music_players[name]
		player.stop()
		if is_instance_valid(player):
			player.queue_free()
		music_players.erase(name)

# ==================== ПОСТОЯННЫЕ ОБЪЕКТНЫЕ ИСТОЧНИКИ ====================
func register_persistent(name: String, node: Node3D, loop: bool = true, volume_db: float = 0.0) -> void:
	if object_sources.has(node):
		return

	var path = DatabaseManager.db.sound_configs["diegetic"]["persistent"][name]
	if path == null:
		push_error("AudioManager: object sound not found: %s" % name)
		return

	var player = AudioStreamPlayer3D.new()
	player.stream = load(path)
	player.loop = loop
	player.volume_db = volume_db
	player.transform = node.global_transform
	node.add_child(player)
	player.play()
	object_sources[node] = player

func unregister_object_sound(node: Node3D) -> void:
	if object_sources.has(node):
		var player = object_sources[node]
		if is_instance_valid(player):
			player.queue_free()
		object_sources.erase(node)

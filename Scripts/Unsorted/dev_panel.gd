extends Control
class_name DevPanel

@export var weapons_path: String = "res://Resources/Weapons"
@onready var grid_container: GridContainer = $MarginContainer/VBoxContainer2/GridContainer
@onready var pool_bar: ProgressBar = $MarginContainer/VBoxContainer2/VBoxContainer/ProgressBar
@onready var label_3: Label = $MarginContainer/VBoxContainer2/VBoxContainer/Label3
@onready var label_2: Label = $MarginContainer/VBoxContainer2/VBoxContainer/Label2
@onready var dd: Label = $MarginContainer/VBoxContainer2/DD
@onready var killed_label: Label = $MarginContainer/VBoxContainer2/Killed

var ecs: ECS = null
var weapon_tres: Dictionary = {}   # name -> WeaponData
var equipped: Dictionary = {}      # name -> Weapon

var initialized := false

func _ready():
	# Ждём, пока ECS появится (например, при загрузке уровня)
	_load_weapons()
	set_process(true)


func _process(_delta):
	if not ecs:
		ecs = get_tree().get_root().find_child("ECS", true, false)
		if ecs:
			print("✅ ECS найден:", ecs)
			_initialize_from_ecs()
	elif ecs and not initialized:
		_initialize_from_ecs()

	if ecs:
		_update_enemy_info()


# --- Инициализация после того как ECS найден ---
func _initialize_from_ecs():
	if not ecs:
		return
	if initialized:
		return
	initialized = true

	print("⚙️  Инициализация DevPanel через ECS")
	_build_grid()


# --- Загружаем все WeaponData из папки ---
func _load_weapons():
	var dir := DirAccess.open(weapons_path)
	if dir == null:
		push_error("Can't open folder: " + weapons_path)
		return
	
	for file_name in dir.get_files():
		if file_name.ends_with(".tres") or file_name.ends_with(".res"):
			var data := load(weapons_path + "/" + file_name)
			if data is WeaponData:
				weapon_tres[data.name] = data
			else:
				push_warning("File " + file_name + " is not WeaponData")


# --- Создаём кнопки для каждого оружия ---
func _build_grid():
	for child in grid_container.get_children():
		child.queue_free()

	for weapon_name in weapon_tres.keys():
		var data: WeaponData = weapon_tres[weapon_name]

		var button := TextureButton.new()
		button.texture_normal = data.icon
		button.stretch_mode = TextureButton.STRETCH_SCALE
		button.toggle_mode = true
		button.tooltip_text = "%s\n%s".format([data.name, data.description])
		button.custom_minimum_size = Vector2(64, 64)
		button.focus_mode = Control.FOCUS_NONE



		grid_container.add_child(button)

		button.connect("toggled", func(pressed: bool):
			if pressed:
				button.modulate = Color(0.5, 1.0, 0.5) # зелёный оттенок
				_on_weapon_pressed(data, button)
			else:
				_on_weapon_unpressed(data, button)
				button.modulate = Color(1, 1, 1) # обычный
		)


# --- Когда нажали (экипировать) ---
func _on_weapon_pressed(data: WeaponData, button: TextureButton):
	if not ecs or not ecs.weapon_system:
		push_warning("⚠️ ECS или WeaponSystem не инициализированы")
		return
	if equipped.has(data.name):
		return
	print("🟢 Equip:", data.name)
	var weapon = ecs.weapon_system.equip(ecs.player_entity, ecs.player_node, data.name)
	if weapon:
		equipped[data.name] = weapon
	else:
		push_warning("Failed to equip " + data.name)
		button.button_pressed = false


# --- Когда выключили (снять) ---
func _on_weapon_unpressed(data: WeaponData, button: TextureButton):
	if not ecs or not ecs.weapon_system:
		push_warning("⚠️ ECS или WeaponSystem не инициализированы")
		return
	if not equipped.has(data.name):
		return
	print("🔻 Unequip:", data.name)
	var weapon = equipped[data.name]
	ecs.weapon_system.unequip(ecs.player_entity, ecs.player_node, weapon)
	equipped.erase(data.name)


# --- Отображаем состояние EnemyPool ---
func _update_enemy_info():
	if not ecs or not ecs.enemy_manager:
		return

	var active_count = ecs.enemy_manager.enemies.size()
	var killed = ecs.enemy_manager.enemy_killed
	
	var pooled_count := 0
	for pool in ecs.enemy_manager.enemy_pools.values():
		pooled_count += pool.size()

	var total = active_count + pooled_count
	pool_bar.value = (float(pooled_count) / max(1.0, float(total))) * 100.0

	label_2.text = "Active: %d" % active_count
	label_3.text = "Total: %d (Pooled: %d)" % [total, pooled_count]
	killed_label.text = "Enemies Killed : %d" % killed
	if pool_bar.value > 80:
		pool_bar.add_theme_color_override("fill_color", Color.RED)
	elif pool_bar.value > 50:
		pool_bar.add_theme_color_override("fill_color", Color.YELLOW)
	else:
		pool_bar.add_theme_color_override("fill_color", Color.GREEN)

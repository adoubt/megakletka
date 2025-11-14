
extends Control

const ANIMATION_DURATION: float = 0.7
var owner_id:int = -1
var has_upgrade: bool = false
var db: DataBase
@onready var fps_label: Label = $HUD/VBoxContainer/Control/FPS
@onready var upgrade_panel:ColorRect = $HUD/VBoxContainer/Control/MarginContainer/LeftPanel/ColorRect/UpgradeOffers
@onready var upgrade_offers: VBoxContainer = $HUD/VBoxContainer/Control/MarginContainer/LeftPanel/ColorRect/UpgradeOffers/VBoxContainer/Upgrades/MarginContainer/VBoxContainer

# === HP ===
@export var min_hp: float = 0.0
@export var max_hp: float = 100.0
@export var current_hp: float = 100.0:
	set = set_current_hp
@onready var current_hp_texture: ColorRect = $HUD/VBoxContainer/Control/MarginContainer/LeftPanel/Control2/HP/Control/MarginContainer/Control/CurrentHP
@onready var current_hp_label: Label = $HUD/VBoxContainer/Control/MarginContainer/LeftPanel/Control2/HP/Control/MarginContainer/Control/CurrentHPLabel
@onready var hp_shader: ShaderMaterial 

# === XP ===
@export var min_xp: float = 0.0
@export var max_xp: float = 100.0
@export var current_xp: float = 0.0:
	set = set_current_xp
@onready var current_xp_texture: ColorRect = $HUD/VBoxContainer/Header/HBoxContainer/MarginContainer/CurrentXP
@onready var current_xp_label: Label = $HUD/VBoxContainer/Header/HBoxContainer/MarginContainer/CurrentXPLabel
@onready var xp_shader: ShaderMaterial 
@onready var current_level: Label = $HUD/VBoxContainer/Header/HBoxContainer/MarginContainer/CurrentLevel

# === Technical ===
var _tween: Tween
var _time_passed := 0.0
var _refresh_interval := 0.5
var event_bus: EventBus

func _ready() -> void:
	hp_shader = current_hp_texture.material
	xp_shader =  current_xp_texture.material
	update_current_hp_texture(0)
	update_current_xp_texture(0)
	upgrade_panel.visible = false
	visible = false

# ================= HP =================
func set_current_hp(new_current_hp: float):
	var diff = new_current_hp - current_hp
	current_hp = clampf(new_current_hp, min_hp, max_hp)
	update_current_hp_texture(sign(diff))
	update_current_hp(current_hp)

func update_current_hp(_value: float):
	current_hp_label.text = "%d / %d" % [int(_value), int(max_hp)]

func update_current_hp_texture(direction: int):
	var progress = current_hp  / (max_hp - min_hp)
	if direction < 0:
		get_tween().tween_property(hp_shader, "shader_parameter/progress_tail", progress, ANIMATION_DURATION)
		hp_shader.set_shader_parameter("progress", progress)
	elif direction > 0:
		get_tween().tween_property(hp_shader, "shader_parameter/progress", progress, ANIMATION_DURATION)
		hp_shader.set_shader_parameter("progress_tail", progress)
	else:
		hp_shader.set_shader_parameter("progress_tail", progress)
		hp_shader.set_shader_parameter("progress", progress)


# ================= XP =================
func set_current_xp(new_current_xp: float):
	var diff = new_current_xp - current_xp
	current_xp = clampf(new_current_xp, min_xp, max_xp)
	update_current_xp_texture(sign(diff))
	update_current_xp(current_xp)

func update_current_xp(_value: float):
	current_xp_label.text = "%d / %d" % [int(_value), int(max_xp)]

func update_current_xp_texture(_direction: int):
	var progress = (current_xp - min_xp) / (max_xp - min_xp)
	# XP растёт только вперёд, поэтому анимируем только progress
	if _direction < 0:
		get_tween().tween_property(xp_shader, "shader_parameter/progress_tail", progress, 0.2)
		xp_shader.set_shader_parameter("progress", progress)
	elif _direction > 0:
		get_tween().tween_property(xp_shader, "shader_parameter/progress", progress, ANIMATION_DURATION)
		xp_shader.set_shader_parameter("progress_tail", progress)
	else:
		xp_shader.set_shader_parameter("progress_tail", progress)
		xp_shader.set_shader_parameter("progress", progress)

# ================= Misc =================
func _process(delta: float) -> void:
	_update_fps(delta)

func _update_fps(delta: float) -> void:
	_time_passed += delta
	if _time_passed >= _refresh_interval:
		_time_passed = 0.0
		fps_label.text = "FPS %d" % int(Engine.get_frames_per_second())

func get_tween() -> Tween:
	if _tween:
		_tween.kill()
	_tween = create_tween().set_ease(Tween.EASE_OUT)
	return _tween

	
func on_upgrade_button_pressed(index: int):
	print('Upgrade btn chosen(delete massage 107 )')
	# e_id — айдишник игрока (или оффера)
	event_bus.emit("upgrade_chosen", {
	"entity_id": owner_id,
	"choice_index": index
})
	UIManager.close_upgrade_menu()

	
	
func setup_upgrade_buttons(owner_id: int,offer: Array) -> void:
	# Перебираем все кнопки внутри контейнера
	for i in range(upgrade_offers.get_child_count()):
		var btn := upgrade_offers.get_child(i) as TextureButton

		if i < offer.size():
			btn.visible = true
			var data = db.card_configs[str(offer[i])]
			btn.choice_name.text = data["name"]
			btn.icon.texture = load(data["icon"])
			btn.choice_decs.text = data["description"]
			if btn.is_connected("pressed", Callable(self, "on_upgrade_button_pressed")):
				btn.disconnect("pressed", Callable(self, "on_upgrade_button_pressed"))
			btn.pressed.connect(func(): on_upgrade_button_pressed(i))
		else:
			btn.visible = false


func _on_button_pressed() -> void:
	print("REROLL")

extends Control
@onready var tab_container: TabContainer = $Control/HBoxContainer/TABCustom/TabContainer
# Базовое разрешение, под которое ты верстал
@onready var post_process_effects_button = $Control/HBoxContainer/TABCustom/TabContainer/Graphics2/Panel/MarginContainer/HBoxContainer/HBoxContainer/Effects

func _ready() -> void:
	_apply_settings(self)
	_load_effects()
	
func _apply_settings(node: Node) -> void:
	if "setting_key" in node and "setting_property" in node:
		node.set(node.setting_property,SettingsManager.get_value(node.setting_key))

	for child in node.get_children():
		_apply_settings(child)


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _load_effects()-> void:
	var effects = DatabaseManager.db.shaders_config.keys()
	var current_shader = SettingsManager.get_value("post_process_shader")
	post_process_effects_button.add_item("Off", 0)
	var i: int = 1
	
	for effect in effects:
		post_process_effects_button.add_item(effect, i)
		if effect == current_shader:
			post_process_effects_button.selected = i
		i+=1
	
	

func _on_back_pressed() -> void:
	
	UIManager.close_settings()
	_sound("menu_back")

func _on_general_pressed() -> void:
	
	tab_container.set_current_tab(0)
	_sound()

func _on_accessibility_pressed() -> void:
	tab_container.set_current_tab(1)
	_sound()

func _on_graphics_pressed() -> void:
	tab_container.set_current_tab(2)
	_sound()

func _on_audio_pressed() -> void:
	tab_container.set_current_tab(3)
	_sound()

func _on_debug_pressed() -> void:
	tab_container.set_current_tab(4)
	_sound()

func _on_effects_item_selected(index: int) -> void:
	UIManager.post_process_panel.set_shader_by_index(index)
	
func _sound(sound_name:String = "settings_select") -> void :
	
	AudioManager.play_ui_sound(sound_name)
	

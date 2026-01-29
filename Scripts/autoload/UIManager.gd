extends Node

# ========== PANELS ==========
@onready var escape_menu  = preload("res://UI/esc_menu.tscn").instantiate()
@onready var settings_menu = preload("res://UI/Settings.tscn").instantiate()

@onready var main_menu = preload("res://UI/main_menu.tscn").instantiate()
@onready var dev_panel = preload("res://UI/dev_panel.tscn").instantiate()
@onready var hud = preload("res://UI/hud.tscn").instantiate()
@onready var level_up_panel = preload("res://UI/level_up_panel.tscn").instantiate()
@onready var merchant_panel = preload("res://UI/merchant_panel.tscn").instantiate()
@onready var post_process_panel:  = preload("res://UI/post_process_panel.tscn").instantiate()
var event_bus: EventBus
var owner_id: int = -1
var player_camera
var upgrade_menu 
var panels: Dictionary = {}
var force_cursor_visible: bool = false
var last_mouse_state: bool = true
const BASE_RESOLUTION := Vector2(1152, 648)
var canvas :CanvasLayer
var post_process_canvas :CanvasLayer
var game_paused: bool = false
var _mouse_delta: Vector2 = Vector2.ZERO
# ========== PUBLIC API ==========

func set_owner_id(_owner_id : int) -> void:
	owner_id = _owner_id
	
func consume_mouse_delta() -> Vector2:
	var d := _mouse_delta
	_mouse_delta = Vector2.ZERO
	return d

func open_merchant_panel():
	open_panel("Merchant")
func close_merchant_panel():
	close_panel("Merchant")
	
func open_level_up_panel():
	
	open_panel("LevelUpPanel")
	level_up_panel.background_scene.show_anim_board()

func close_level_up_panel() -> void:
	level_up_panel.background_scene.hide_anim_board()
	close_panel("LevelUpPanel")	
	
func toggle_level_up_panel() -> void:
	if is_panel_open("LevelUpPanel"):
		close_level_up_panel()
	else:
		open_level_up_panel() 
		

	
func open_main_menu() -> void:
	open_panel("MainMenu")
	game_paused = false
	
		
func open_hud() -> void:
	open_panel("HUD")
	
func close_hud()-> void:
	close_panel("HUD")

func toggle_hud() -> void:
	
	if is_panel_open("HUD"):
		close_panel("HUD")
	else: open_panel("HUD")
	
func toggle_escape_menu() -> void:
	if SceneManager.current_scene_name == "GameTest": toggle_hud()
	if is_panel_open("EscapeMenu"):
		close_escape_menu()
		if is_panel_open("UpgradeMenu"):
			game_paused = true
	else:
		open_escape_menu()
func toggle_dev_panel() -> void:
	if dev_panel.visible:
		close_dev_panel()
	else:
		open_dev_panel()
	
func open_settings() -> void:
	var in_main_menu :bool = SceneManager.current_scene_name == "MainMenu"
	open_panel("Settings",true)
	if in_main_menu:
		close_panel("MainMenu")
	else:
		close_panel("EscapeMenu")

func close_settings() -> void:
	var in_main_menu := SceneManager.current_scene_name == "MainMenu"
	if in_main_menu:
		open_main_menu()
	else:
		open_escape_menu()
	
	close_panel("Settings")
	
func open_escape_menu() -> void:
	open_panel("EscapeMenu", true)
	
	game_paused = true
func close_escape_menu() -> void:
	close_panel("EscapeMenu")
	
	game_paused = false
func open_dev_panel() -> void:
	open_panel("DEV_PANEL")
	await get_tree().process_frame
	dev_panel.console_input.grab_focus()
func close_dev_panel() -> void:
	close_panel("DEV_PANEL")


func is_panel_open(_name: String) -> bool:
	if not panels.has(_name):
		return false

	var panel = panels[_name]
	return is_instance_valid(panel) and panel.visible

		
func open_panel(_name: String, use_tween: bool = false ) -> void:
	if panels.has(_name):
		var panel = panels[_name]
		
		
		if use_tween:
			panel.scale = Vector2.ZERO
			panel.pivot_offset = panel.size * 0.5
			panel.visible = true
			var tween : Tween = panel.create_tween()
			tween.set_trans(Tween.TRANS_BACK)
			tween.set_ease(Tween.EASE_OUT)
			tween.tween_property(panel, "scale", Vector2.ONE, 0.2)
			await tween.finished.connect(func(): tween.kill)
		else:
			panel.visible = true

			
		if panel.has_method("refresh"):
			panel.refresh()
			
		_update_ui_state()

func close_panel(_name: String, use_tween: bool = false ) -> void:
	if panels.has(_name):
		var panel = panels[_name]
		if use_tween:
			var tween:Tween = panel.create_tween()
			tween.set_trans(Tween.TRANS_BACK)
			tween.set_ease(Tween.EASE_IN)

			tween.tween_property(panel, "scale", Vector2.ZERO, 0.2)

			tween.finished.connect(func():
				panel.visible = false
			)
		else:	panel.visible = false
		_update_ui_state()

func close_all(incluse_hud : bool = false) -> void:
	for p in panels.values():
		if p == hud and not incluse_hud: continue
		p.visible = false
	game_paused = false	
	_update_ui_state()


# ========== INTERNAL ==========
func _ready() -> void:
	canvas = CanvasLayer.new()
	canvas.name = "Panels"
	add_child(canvas)
	canvas.add_child(hud)
	canvas.add_child(dev_panel)
	canvas.add_child(level_up_panel)
	canvas.add_child(merchant_panel)
	canvas.add_child(escape_menu)
	canvas.add_child(main_menu)
	canvas.add_child(settings_menu)
	
	
	post_process_canvas = CanvasLayer.new()
	add_child(post_process_canvas)
	post_process_canvas.name = "PostProcess"
	post_process_canvas.add_child(post_process_panel)
	
	panels = {
		
		"EscapeMenu": escape_menu,
		"MainMenu": main_menu,
		"Settings": settings_menu,
		"DEV_PANEL" : dev_panel,
		"LevelUpPanel": level_up_panel,
		"Merchant": merchant_panel,
		"HUD" :hud,
		
	}
	
	close_all()
	scale_margins_for_resolution()  # стартовая подгонка
	#connect("resized", Callable(self, "_on_resize"))  # если Control
	get_viewport().connect("size_changed", Callable(self, "_on_resize"))
	
func _update_ui_state() -> void:
	var ui_open := _any_ui_open() or force_cursor_visible
	#var active_node := ControllerManager.get_active()

	#if active_node and active_node.has_method("set_input_enabled"):
		#active_node.set_input_enabled(not ui_open)

	_show_mouse(ui_open)


func _any_ui_open() -> bool:
	for p in panels.values():
		if p == hud: continue
		if p.visible:
			return true
	return false

func _show_mouse(visible: bool) -> void:
	if visible == last_mouse_state:
		return
	last_mouse_state = visible
	Input.set_mouse_mode(
		Input.MOUSE_MODE_VISIBLE if visible else Input.MOUSE_MODE_CAPTURED
	)



func _on_resize():
	scale_margins_for_resolution()

func scale_margins_for_resolution():
	var current_res = get_viewport().get_visible_rect().size
	# коэффициенты по X и Y (берём среднее, чтобы сохранять пропорции)
	var scale_x = current_res.x / BASE_RESOLUTION.x
	var scale_y = current_res.y / BASE_RESOLUTION.y
	var scale = (scale_x + scale_y) / 2.0

	_apply_margin_scaling(self, scale)


func _apply_margin_scaling(node: Node, scale: float):
	# Если это MarginContainer, меняем его Constants
	if node is MarginContainer:
		for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
			if node.has_theme_constant_override(side):
				var value = node.get_theme_constant(side)
				node.add_theme_constant_override(side, int(value * scale))
	# Рекурсивно обходим детей
	for child in node.get_children():
		if child is Control:
			_apply_margin_scaling(child, scale)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Esc"):
		if is_panel_open("Settings"):
			close_settings()
			

		elif SceneManager.current_scene_name not in ["Intro","MainMenu"]:
			toggle_escape_menu()
			
	if event.is_action_pressed("DEV_PANEL"):
		if SceneManager.current_scene_name in ["BigRoomTest","GameTest"]:
			toggle_dev_panel()
	if event.is_action_pressed("upgrade_menu"):
		if hud.has_upgrade and SceneManager.current_scene_name in ["BigRoomTest","GameTest"] and not escape_menu.visible:
			toggle_level_up_panel()
			event_bus.emit("level_up_panel_toggled") 
			#toggle_upgrade_menu()

func _unhandled_input(event):
	if game_paused:
		return

	if event is InputEventMouseMotion \
	and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_mouse_delta += event.relative	
		

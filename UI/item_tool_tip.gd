extends Control

@onready var item_title: Label = %ItemTitle
@onready var item_description: Label = %ItemDescription
@onready var cost_label: Label = %ItemCostLabel
@onready var abilities_container: VBoxContainer = %Abilities
var offset := Vector2(80, -50)
var showing_tween: Tween
func _ready()->void:
	custom_minimum_size.x = 280
	
	hide()
func update_data(data: Dictionary) -> void:
	if data.is_empty():
		hide()
		set_process(false)
		return
	
	
	item_title.text = data.get("item_title", "")
	item_description.text = data.get("item_description", "")
	var cost: = int(data.get("cost", 0))
	var base_color:Color =  Color("d4af37")
	if cost > UIManager.hud.balance:
		base_color = Color("fd7a7a")
		
	cost_label.add_theme_color_override("font_color", base_color)	
	cost_label.text = str(cost)

	_clear_abilities()
	
	var abilities: Array = data.get("abilities", [])
	for ability_data in abilities:
		var ability_block = _create_ability_block(ability_data)
		abilities_container.add_child(ability_block)
	#await get_tree().process_frame
	#_update_pos()
	#
func _clear_abilities():
	for child in abilities_container.get_children():
		child.queue_free()
func _create_ability_block(data: Dictionary) -> Control:
	
	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 3)

	# ================= TITLE BLOCK =================
	var title_block := PanelContainer.new()

	var grad := Gradient.new()
	var grad_colors := PackedColorArray([
	Color8(36,53,50),
	Color8(28,38,36)])	
	grad.set_colors(grad_colors)
	

	var grad_tex := GradientTexture1D.new()
	grad_tex.gradient = grad
	grad_tex.width = 256   # критично

	var bg := TextureRect.new()
	bg.texture = grad_tex
	bg.anchor_left = 0
	bg.anchor_top = 0
	bg.anchor_right = 1
	bg.anchor_bottom = 1
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	title_block.add_child(bg)

	var title_style := StyleBoxFlat.new()

	title_style.content_margin_left = 8
	title_style.content_margin_right = 8
	title_style.bg_color = Color8(0,0,0,0) # промежуточный болотный
	
	var title := Label.new()
	
	title.add_theme_stylebox_override("normal", title_style)
	title.text = data.get("ability_title", "")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.anchor_left = 0
	title.anchor_top = 0
	title.anchor_right = 1
	title.anchor_bottom = 1
	
	title.add_theme_font_size_override("font_size", 14)
	#title.add_theme_color_override("font_color", Color8(184,169,76))
	title_block.add_child(title)
	
	var title_panel_style := StyleBoxFlat.new()
	title_panel_style.corner_radius_top_left = 10
	title_panel_style.corner_radius_top_right = 10
	title_block.add_theme_stylebox_override("normal",title_panel_style)
	
	
	# ================= DESCRIPTION =================
	var description := RichTextLabel.new()
	description.bbcode_enabled = true
	description.autowrap_mode = TextServer.AUTOWRAP_WORD
	
	
	var text :String= data.get("ability_description", "")
	description.text = format_text(text)
	description.add_theme_color_override("font_color",Color(0.78, 0.839, 0.816))
	description.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	description.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	description.fit_content = true

	var desc_block := PanelContainer.new()

	var desc_style := StyleBoxFlat.new()
	desc_style.bg_color = Color8(28,38,36)
	desc_style.content_margin_left = 8
	desc_style.content_margin_right = 8
	desc_style.corner_radius_bottom_left = 10
	desc_style.corner_radius_bottom_right = 10
	desc_block.add_theme_stylebox_override("panel", desc_style)
	desc_block.add_child(description)
	root.add_child(title_block)
	root.add_child(desc_block)
	return root



func _process(delta: float) -> void:
	_update_pos(delta)

func _update_pos(delta: float) -> void:
	var visible_rect = get_viewport().get_visible_rect()
	var mouse_pos = get_global_mouse_position()

	var tooltip_size = size
	var desired_pos = mouse_pos + offset

	
	var min_x = visible_rect.position.x
	var max_x = visible_rect.position.x + visible_rect.size.x - tooltip_size.x

	var min_y = visible_rect.position.y
	var max_y = visible_rect.position.y + visible_rect.size.y - tooltip_size.y


	desired_pos.x = clamp(desired_pos.x, min_x, max_x)
	desired_pos.y = clamp(desired_pos.y, min_y, max_y)

	var speed := 5.0
	global_position = global_position.lerp(
		desired_pos,
		1.0 - exp(-speed * delta)
	)

func format_text(text: String) -> String:
	var base_size := 14
	var base_color := "#c7d6d0"
	
	var keyword_colors := {
		"DAMAGE": "#d35b5b",
		"ARMOR": "#6fa8dc",
		"ATTACK SPEED": "#ffffff",
		"GOLD": "#d6c96a",
		"CRIT DAMAGE": "#ffffff",
		"PIERCE": "#ffffff",
		"CRIT CHANCE": "#ffffff",
		"JUMPS COUNT": "#ffffff",
		"JUMP HEIGHT": "#ffffff",
		"JUMPS LEFT": "#ffffff",
		"MOVESPEED": "#ffffff",
		"DURATION": "#ffffff",
		"ORB COUNT": "#ffffff",
		"WEAPON RADIUS": "#ffffff",
		"ORB RADIUS": "#ffffff",
		"SLOTS": "#ffffff",
		"USED SLOTS": "#ffffff",
		"UNUSED LEVEL POINTS": "#ffffff",
		"XP LEFT": "#ffffff",
		"CURRENT XP": "#ffffff",
		"LEVEL": "#ffffff",
		"XP GAIN": "#ffffff",
		"HP": "#ffffff",
		"CURRENT HP": "#ffffff",
		"MAX HP": "#ffffff",
		"X": "#ffffff",
		"COST":"#d6c96a",
	}
	
	var regex := RegEx.new()
	regex.compile("(\\d+|[A-Z][A-Z ]+[A-Z])")
	
	var result := "[color=" + base_color + "][font size=" + str(base_size) + "]"
	var last_end := 0
	
	for match in regex.search_all(text):
		result += text.substr(last_end, match.get_start() - last_end)
		
		var token := match.get_string()
		
		if token.is_valid_int():
			result += "[color=#ffffff][font size=18]" + token + "[/font][/color]"
		
		elif keyword_colors.has(token):
			var c :String= keyword_colors[token]
			result += "[color=" + c + "]" + token + "[/color]"
		
		else:
			result += token
		
		last_end = match.get_end()
	
	result += text.substr(last_end)
	result += "[/font][/color]"
	
	return result
func set_showing(active:bool):
	
	var panel = $Panel
	var base_scale = Vector2(0.1, 0.1)
	panel.pivot_offset = panel.size * 0.5
	if showing_tween:
		showing_tween.kill()

	showing_tween = create_tween()
	showing_tween.set_trans(Tween.TRANS_SINE)
	showing_tween.set_ease(Tween.EASE_OUT)

	if active:
		panel.scale = base_scale
		show()
		#showing_tween.tween_property(self, "modulate", Color(1,1,1,1), 0.15)
		showing_tween.tween_property(panel, "scale", Vector2(1.0,1.0), 0.05)
		
	else:
		#showing_tween.tween_property(self, "modulate", base_modulate, 0.15)
		showing_tween.tween_property(panel, "scale", base_scale, 0.05)
		showing_tween.tween_callback(hide)
		print("hide tween start")

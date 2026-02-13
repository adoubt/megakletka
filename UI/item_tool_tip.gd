extends Control

@onready var item_title: Label = %ItemTitle
@onready var item_description: Label = %ItemDescription
@onready var cost_label: Label = %ItemCostLabel
@onready var abilities_container: VBoxContainer = %Abilities
var offset := Vector2(100, -20)

func _ready()->void:
	custom_minimum_size.x = 280
	
	hide()
func update_data(data: Dictionary) -> void:
	if data.is_empty():
		hide()
		return
	
	
	item_title.text = data.get("item_title", "")
	item_description.text = data.get("item_description", "")
	cost_label.text = str(int(data.get("cost", 0)))
	
	_clear_abilities()
	
	var abilities: Array = data.get("abilities", [])
	for ability_data in abilities:
		var ability_block = _create_ability_block(ability_data)
		abilities_container.add_child(ability_block)
	await get_tree().process_frame
	_update_pos()
	
func _clear_abilities():
	for child in abilities_container.get_children():
		child.queue_free()
func _create_ability_block(data: Dictionary) -> Control:
	var root = VBoxContainer.new()
	root.add_theme_constant_override("separation", 2)
	
	var title = Label.new()
	title.mouse_filter = MOUSE_FILTER_IGNORE
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.text = data.get("ability_title", "")
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(0.9, 0.8, 0.4))
	root.add_child(title)
	
	var description = Label.new()
	description.mouse_filter = MOUSE_FILTER_IGNORE
	description.autowrap_mode = TextServer.AUTOWRAP_WORD
	description.text = data.get("ability_description", "")
	root.add_child(description)


	
	return root

func _update_pos() -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport_rect().size
	
	var desired_pos = mouse_pos + offset
	
	# если вылезает вправо — ставим слева
	if desired_pos.x + size.x > screen_size.x:
		desired_pos.x = mouse_pos.x - size.x 
	
	# если вылезает вниз — поднимаем вверх
	if desired_pos.y + size.y > screen_size.y:
		desired_pos.y = screen_size.y - size.y 
	
	global_position = desired_pos

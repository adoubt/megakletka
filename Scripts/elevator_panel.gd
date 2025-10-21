@tool
extends Control

@export var floors: int = 100:
	set = _set_floors

@export var buttons_per_row: int = 20:
	set = _set_buttons_per_row

@onready var v_box: VBoxContainer = $MarginContainer/VBoxContainer

func _ready() -> void:
	if Engine.is_editor_hint():
		_create_floor_buttons()

func _set_floors(value: int) -> void:
	floors = value
	if Engine.is_editor_hint():
		_create_floor_buttons()

func _set_buttons_per_row(value: int) -> void:
	buttons_per_row = value
	if Engine.is_editor_hint():
		_create_floor_buttons()

func _create_floor_buttons() -> void:
	if not is_instance_valid(v_box):
		await get_tree().process_frame
		if not is_instance_valid(v_box):
			return
	
	# очищаем старое
	for child in v_box.get_children():
		child.queue_free()

	for i in range(floors):
		if i % buttons_per_row == 0:
			var h_box = HBoxContainer.new()
			v_box.add_child(h_box)

		var button = Button.new()
		button.text = str(i + 1)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.connect("pressed", _on_floor_button_pressed.bind(i + 1))
		
		var last_row = v_box.get_child(v_box.get_child_count() - 1)
		last_row.add_child(button)

func _on_floor_button_pressed(floor_number: int) -> void:
	print("Нажата кнопка этажа:", floor_number)

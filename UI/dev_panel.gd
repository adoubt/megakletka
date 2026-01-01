extends Control
class_name DevPanel



@onready var list: VBoxContainer = $MarginContainer/HBoxContainer/MarginContainer/VBoxContainer2/List

@onready var systems_list: VBoxContainer = $MarginContainer/HBoxContainer/SystemsList

# кеш строк
var system_rows :Dictionary= {} # system_name -> HBoxContainer
# кеш строк чтобы не пересоздавать каждый апдейт
var rows: Dictionary = {} # scene_path -> HBoxContainer

func update_system_profile(stats: Dictionary) -> void:
	var alive := {}

	for system_name in stats.keys():
		alive[system_name] = true
		var data: Dictionary = stats[system_name]

		var row: HBoxContainer
		if system_rows.has(system_name):
			row = system_rows[system_name]
		else:
			row = _create_system_row(system_name)
			system_rows[system_name] = row
			systems_list.add_child(row)

		_update_system_row(row, data)

	# удалить исчезнувшие
	for name in system_rows.keys():
		if not alive.has(name):
			system_rows[name].queue_free()
			system_rows.erase(name)
			
func _create_system_row(name: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var label := Label.new()
	label.name = "Name"
	label.text = name
	
	label.custom_minimum_size.x = 160
	var settings := LabelSettings.new()
	settings.font_size = 10
	label.label_settings = settings
	row.add_child(label)

	var bar := ProgressBar.new()
	bar.name = "Bar"
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.min_value = 0
	bar.max_value = 5 # 5 ms дефолт
	row.add_child(bar)

	var value := Label.new()
	value.name = "Value"
	value.custom_minimum_size.x = 120
	row.add_child(value)

	return row
func _update_system_row(row: HBoxContainer, data: Dictionary) -> void:
	var last :float= data["last"]
	var avg :float= data["avg"]
	var maxv :float= data["max"]

	var bar: ProgressBar = row.get_node("Bar")
	bar.value = last
	bar.max_value = max(bar.max_value, maxv)

	var label: Label = row.get_node("Value")
	label.text = "%.2f ms | avg %.2f | max %.2f" % [last, avg, maxv]

	# визуальный алерт
	if last > 2.0:
		bar.modulate = Color(1, 0.4, 0.4)
	elif last > 1.0:
		bar.modulate = Color(1, 0.8, 0.4)
	else:
		bar.modulate = Color(0.4, 1, 0.4)


func update_pool_stats(stats: Dictionary) -> void:
	# 1. отмечаем какие ещё живы
	var alive := {}

	for scene_path in stats.keys():
		alive[scene_path] = true
		var data: Dictionary = stats[scene_path]

		var row: HBoxContainer
		if rows.has(scene_path):
			row = rows[scene_path]
		else:
			row = _create_row(scene_path)
			rows[scene_path] = row
			list.add_child(row)

		_update_row(row, scene_path, data)

	# 2. удаляем строки которых больше нет
	for scene_path in rows.keys():
		if not alive.has(scene_path):
			rows[scene_path].queue_free()
			rows.erase(scene_path)

func _create_row(scene_path: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name := Label.new()
	name.name = "Name"
	name.text = scene_path.get_file()
	name.custom_minimum_size.x = 180
	row.add_child(name)

	var bar := ProgressBar.new()
	bar.name = "Bar"
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.min_value = 0
	row.add_child(bar)

	var value := Label.new()
	value.name = "Value"
	value.custom_minimum_size.x = 80
	row.add_child(value)

	return row

func _update_row(row: HBoxContainer, scene_path: String, data: Dictionary) -> void:
	var used: int = data["used"]
	var free: int = data["free"]
	var total: int = max(1, data["total"]) # защита

	var bar: ProgressBar = row.get_node("Bar")
	bar.max_value = total
	bar.value = used

	var label: Label = row.get_node("Value")
	label.text = "%d / %d" % [used, total]

	# лёгкая визуальная подсказка
	if free == 0:
		bar.modulate = Color(1, 0.4, 0.4)
	else:
		bar.modulate = Color(0.4, 1, 0.4)

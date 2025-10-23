extends Node
class_name SaveManager

const SAVE_PATH := "res://Saves/world_save.json"

# ==========================
#  ДАННЫЕ СЕЙВА
# ==========================
var save_data: Dictionary = {
	"meta": {
		"version": 1,
		"timestamp": "",
	},
	"world": {
		"time": 0.0,
		"objects": []  # деревья, сундуки и т.п.
	},
	"players": {},  # {player_id: {позиция, инвентарь, статы}}
	"ecs": {         # ECS: все сущности и компоненты
		"entities": {},      # {id: {components: {...}}}
		"component_data": {} # для сериализации сложных типов
	}
}

# ==========================
#  PUBLIC API
# ==========================

func new_world():
	save_data = {
		"meta": {
			"version": 1,
			"timestamp": Time.get_datetime_string_from_system(),
		},
		"world": {"time": 0.0, "objects": []},
		"players": {},
		"ecs": {"entities": {}, "component_data": {}}
	}
	save_game()

func load_world():
	save_data = _load_json(SAVE_PATH, save_data)

func save_game():
	save_data["meta"]["timestamp"] = Time.get_datetime_string_from_system()
	_save_json(SAVE_PATH, save_data)

# ==========================
#  ИГРОКИ
# ==========================

func register_player(id: String):
	if not save_data["players"].has(id):
		save_data["players"][id] = {
			"position": Vector3.ZERO,
			"stats": {"hp": 100, "stamina": 100},
			"inventory": []
		}
	save_game()
	return save_data["players"][id]

func get_player(id: String) -> Dictionary:
	return save_data["players"].get(id, {})

func update_player(id: String, new_data: Dictionary):
	save_data["players"][id] = new_data
	save_game()

# ==========================
#  МИР
# ==========================
func get_world() -> Dictionary:
	return save_data["world"]

func update_world(data: Dictionary):
	save_data["world"] = data
	save_game()

# ==========================
#  ECS - СЕРИАЛИЗАЦИЯ
# ==========================

# Сохраняет все ECS сущности и компоненты
func save_ecs_state(ecs):
	var entities_dict = {}
	for entity_id in ecs.entity_manager.entities.keys():
		var comps = ecs.component_store.get_all_components_for_entity(entity_id)
		var serial = {}
		for comp_name in comps.keys():
			var c = comps[comp_name]
			serial[comp_name] = _serialize_component(c)
		entities_dict[entity_id] = serial
	save_data["ecs"]["entities"] = entities_dict
	save_game()

# Восстанавливает ECS мир из сейва
func load_ecs_state(ecs):
	if not save_data["ecs"].has("entities"):
		return
	for entity_id in save_data["ecs"]["entities"].keys():
		var comp_data = save_data["ecs"]["entities"][entity_id]
		var new_entity = ecs.entity_manager.create_entity()
		for comp_name in comp_data.keys():
			var comp_instance = _deserialize_component(comp_name, comp_data[comp_name])
			ecs.component_store.add_component(new_entity, comp_name, comp_instance)

# ==========================
#  INTERNAL HELPERS
# ==========================
func _save_json(path: String, data: Dictionary):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()

func _load_json(path: String, default_value = {}):
	if not FileAccess.file_exists(path):
		return default_value
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return default_value
	var text = file.get_as_text()
	file.close()
	var result = JSON.parse_string(text)
	return result if typeof(result) == TYPE_DICTIONARY else default_value

# --- Компоненты ---
func _serialize_component(component: Object) -> Dictionary:
	var data := {}
	for property in component.get_property_list():
		if property.name.begins_with("_"):
			continue
		data[property.name] = component.get(property.name)
	return data

func _deserialize_component(name: String, data: Dictionary) -> Object:
	var comp_class = load("res://ecs/components/%s.gd" % name)
	if not comp_class:
		push_warning("Компонент %s не найден при загрузке" % name)
		return null
	var comp_instance = comp_class.new()
	for key in data.keys():
		if comp_instance.has_property(key):
			comp_instance.set(key, data[key])
	return comp_instance

extends Control

var shader_materials := {}    # ключ = имя эффекта, значение = ShaderMaterial
var shader_names := []        # список имён эффектов в порядке добавления (для OptionButton)

func _ready() -> void:
	_load_all_shaders()
	#$ColorRect2.material = shader_materials["vignette"]
	# Получаем имя из настроек или дефолтное
	var current_effect = SettingsManager.get_value("post_process_shader")
	if current_effect == "off":
		current_effect = shader_names[0]  # берём первый ключ из списка
	_set_effect(current_effect)


func _load_all_shaders():
	shader_materials.clear()
	shader_names.clear()
	shader_names.append("Off")
	
	for effect_name in DatabaseManager.db.shaders_config.keys():
		var shader_path = DatabaseManager.db.shaders_config[effect_name]
		var shader_res = load(shader_path)
		if shader_res:
			var mat = ShaderMaterial.new()
			mat.shader = shader_res
			shader_materials[effect_name] = mat
			shader_names.append(effect_name)
		else:
			push_warning("Shader not found: %s" % shader_path)
	
	print("Loaded shaders:", shader_names)

func _set_effect(effect_name: String):
	SettingsManager.set_value("post_process_shader", effect_name) 
	if effect_name == "Off":
		self.hide()
		return
	if shader_materials.has(effect_name):
		$ColorRect.material = shader_materials[effect_name]
		print("Effect applied:", effect_name)
		self.show()
	else:
		push_warning("Effect not found:", effect_name)

func set_shader_by_index(index: int):
	var effect_name = shader_names[index]   # конвертируем индекс в имя
	
	_set_effect(effect_name)

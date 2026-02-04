extends Slider


@export var setting_key: String 
@export var setting_property := "value"

func _ready():
	value_changed.connect(_on_slider_changed)
	

func _on_slider_changed(value: float) -> void:
	value = clamp(value, min_value, max_value)

	AudioManager.apply_master_volume(value)

	if setting_key != "":
		SettingsManager.set_value(setting_key, value)
	get_parent().get_child(0).text = str(value)

extends LineEdit


@export var setting_key: String 
@export var setting_property := "value"
@export var min_value : float = 0.0
@export var max_value : float = 1.0
func _ready():
	text_submitted.connect(_on_text_submited)
	

func _on_text_submited(_text: String) -> void:
	var value := _text.to_float()
	value = clamp(value, min_value, max_value)
	text = str(value)
	AudioManager.apply_master_volume(value)

	if setting_key != "":
		SettingsManager.set_value(setting_key, value)
	
	var slider = get_parent().get_node_or_null("Slider")
	if slider:
		slider.value = value

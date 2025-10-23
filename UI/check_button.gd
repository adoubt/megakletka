extends CheckButton

@export var settings_key: String

func _ready():
	# Инициализация из конфига
	var _button_presed = SettingsManager.get_value(settings_key)
	if _button_presed != null:
		button_pressed = _button_presed# false по умолчанию
	_update_text()

	# Подключаем сигнал через Callable
	toggled.connect(Callable(self, "_on_toggled"))

func _on_toggled() -> void:
	_update_text()
	
	SettingsManager.set_value(settings_key, button_pressed)

func _update_text():
	text = "ON" if button_pressed else "OFF"

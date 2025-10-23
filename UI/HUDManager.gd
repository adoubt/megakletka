extends Control
class_name HUDManager

@onready var fps_label: Label = $HUD/FPS


var _time_passed := 0.0
var _refresh_interval := 0.5  # обновляем FPS раз в 0.5 сек

	# FPS обновится на первом цикле _process

func _process(delta: float) -> void:

	# FPS с интервалом
	_update_fps(delta)

func _update_fps(delta: float) -> void:
	_time_passed += delta
	if _time_passed >= _refresh_interval:
		_time_passed = 0.0
		fps_label.text = "FPS " + str(int(Engine.get_frames_per_second()))

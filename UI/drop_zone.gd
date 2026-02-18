extends Control 

@export var request: String = ""

var base_scale: Vector2
var base_modulate: Color
@onready var panel: Panel = $Panel

var pulse_tween: Tween
var modulate_tween: Tween

func _ready():
	base_scale = panel.scale
	base_modulate = modulate
	
	panel.pivot_offset = panel.size * 0.5

func accept_drop(item: ItemInstance) -> bool:
	if request == "":
		return false
		
	UIManager.event_bus.emit(request, {"item_instance": item, "owner_id":UIManager.owner_id})
	return true


func set_drop_active(active: bool):
	if modulate_tween:
		modulate_tween.kill()

	modulate_tween = create_tween()
	modulate_tween.set_trans(Tween.TRANS_SINE)
	modulate_tween.set_ease(Tween.EASE_OUT)

	if active:
		#modulate_tween.tween_property(self, "modulate", Color(1,1,1,1), 0.15)
		modulate_tween.tween_property(panel, "scale", base_scale* 1.1, 0.15)
	else:
		#modulate_tween.tween_property(self, "modulate", base_modulate, 0.15)
		modulate_tween.tween_property(panel, "scale", base_scale, 0.15)


func set_hover_feedback(active: bool):
	if pulse_tween:
		pulse_tween.kill()

	if not active:
		modulate = base_modulate
		panel.scale = base_scale
		return

	var overshoot = base_scale * 1.12
	var settle    = base_scale * 1.06

	pulse_tween = create_tween()
	pulse_tween.set_loops()

	# ИМПУЛЬС (быстрый вход)
	pulse_tween.tween_property(panel, "scale", overshoot, 0.12)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)

	pulse_tween.parallel().tween_property(self, "modulate", base_modulate * 1.25, 0.12)

	# УПРУГАЯ СТАБИЛИЗАЦИЯ
	pulse_tween.tween_property(panel, "scale", settle, 0.18)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

	pulse_tween.parallel().tween_property(self, "modulate", base_modulate * 1.15, 0.18)

	# IDLE-ПУЛЬС (медленный живой эффект)
	pulse_tween.tween_property(panel, "scale", base_scale * 1.08, 0.05)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	pulse_tween.parallel().tween_property(self, "modulate", base_modulate * 1.2, 0.05)

	pulse_tween.tween_property(panel, "scale", settle, 0.45)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	pulse_tween.parallel().tween_property(self, "modulate", Color(1,1,1,1), 0.45)

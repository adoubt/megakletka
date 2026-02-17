extends Control 

@export var request: String = ""

var base_scale: Vector2
var base_modulate: Color

var scale_tween: Tween
var modulate_tween: Tween

func _ready():
	base_scale = scale
	base_modulate = modulate


func accept_drop(item: ItemInstance) -> bool:
	if request == "":
		return false
		
	UIManager.event_bus.emit(request, {"item_instance": item, "owner_id":UIManager.owner_id})
	return true


func set_scale_highlight(active: bool):
	if scale_tween:
		scale_tween.kill()

	scale_tween = create_tween()
	scale_tween.set_trans(Tween.TRANS_BACK)
	scale_tween.set_ease(Tween.EASE_OUT)

	if active:
		scale_tween.tween_property(self, "scale", base_scale * 1.12, 0.12)
		scale_tween.tween_property(self, "scale", base_scale * 1.08, 0.08)
	else:
		scale_tween.tween_property(self, "scale", base_scale, 0.14)


func set_color_highlight(active: bool):
	if modulate_tween:
		modulate_tween.kill()

	modulate_tween = create_tween()
	modulate_tween.set_trans(Tween.TRANS_SINE)
	modulate_tween.set_ease(Tween.EASE_OUT)

	if active:
		modulate_tween.tween_property(self, "modulate", Color(1.2, 1.2, 1.2, 1.0), 0.18)
	else:
		modulate_tween.tween_property(self, "modulate", base_modulate, 0.14)
	

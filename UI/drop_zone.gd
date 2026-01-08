extends Control
class_name DropZone

@export var zone_type: String # "sell" | "use"

var enabled: bool = true
var hovered: bool = false

func set_enabled(state: bool) -> void:
	if enabled == state:
		return
	enabled = state
	hovered = false
	queue_redraw()

func set_hover(state: bool) -> void:
	if not enabled:
		state = false
	if hovered == state:
		return
	hovered = state
	_update_anim()
	queue_redraw()

func _update_anim():
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	if hovered:
		tween.tween_property(self, "scale", Vector2.ONE * 1.05, 0.12)
	else:
		tween.tween_property(self, "scale", Vector2.ONE, 0.12)

func _draw() -> void:
	var col: Color

	if not enabled:
		col = Color(0.2, 0.2, 0.2, 0.45) # disabled
	elif hovered:
		col = Color(1.0, 1.0, 1.0, 0.22) # hover
	else:
		col = Color(0.1, 0.1, 0.1, 0.25) # idle

	draw_rect(Rect2(Vector2.ZERO, size), col, true)

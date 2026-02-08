extends Control

var connections: Array = []

@export var dash_length := 7.0
@export var dash_gap := 8.0
@export var jitter_pos := 2.5
@export var jitter_rot := 0.15
@export var line_color := Color(1.0, 1.0, 1.0, 0.341)
@export var line_width := 1.0
@export var endpoint_inset := 0.0
@export var draw_steps := 10


var _raw_progress := 0.0
var draw_progress := 0.0:
	set(value):
		_raw_progress = value

		var step := 1.0 / draw_steps
		var snapped = floor(value / step) * step

		if !is_equal_approx(snapped, draw_progress):
			draw_progress = snapped
			queue_redraw()
var draw_tween: Tween
func _draw():
	for c in connections:
		var from_pos = c.from.get_global_rect().get_center() 
		var to_pos   = c.to.get_global_rect().get_center()
		
		_draw_dashed_connection(
			from_pos - global_position,
			to_pos - global_position
		)

func _draw_dashed_connection(from: Vector2, to: Vector2) -> void:
	var full_dir := to - from
	var full_len := full_dir.length()
	if full_len < 1:
		return

	var dir := full_dir.normalized()

	var start = from + dir * endpoint_inset
	var end   = to   - dir * endpoint_inset

	var max_len = (end - start).length()
	var len = max_len * draw_progress
	if len <= 0:
		return

	var step := dash_length + dash_gap
	var t := 0.0

	while t < len:
		var seg_start = start + dir * t
		var seg_end = start + dir * min(t + dash_length, len)

		var offset := Vector2(
			randf_range(-jitter_pos, jitter_pos),
			randf_range(-jitter_pos, jitter_pos)
		)
		var rot := randf_range(-jitter_rot, jitter_rot)

		var s = seg_start + offset
		var e = s + (seg_end - seg_start).rotated(rot)

		draw_line(s, e, line_color, line_width, true)
		t += step



func animate_connections(duration := 3.2):
	if draw_tween:
		draw_tween.kill()

	draw_progress = 0.0
	queue_redraw()

	draw_tween = create_tween()
	draw_tween.tween_interval(0.3)
	draw_tween.tween_property(
		self,
		"draw_progress",
		1.0,
		duration
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

	draw_tween.tween_callback(queue_redraw)

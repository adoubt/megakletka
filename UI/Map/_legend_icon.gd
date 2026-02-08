extends TextureButton

@export var day_type: int = DayType.BOSS
@export var hover_scale := 1.55
@export var tween_time := 0.12
@export var legend: bool = false
@export var hover_modulate := Color(0.97, 0.992, 0.984, 1.0)
@export var normal_modulate := Color(1.0, 1.0, 1.0, 0.741)
@export var unhover_modulate:=Color(1.0, 1.0, 1.0, 0.251)
##Custom trash

func _ready() -> void:
	modulate = normal_modulate
@export var _texture_normal :Texture2D:
	set(value):
		_texture_normal = value
		if value: texture_normal = value
		
		
@export var _texture_hover :Texture2D:
	set(value):
		_texture_hover = value
		if value: texture_hover = value
		
var hover_tween: Tween

func set_unhover() -> void:
	
	modulate = unhover_modulate	
	
func set_hover(from_legend := false) -> void:
	if from_legend:
		texture_normal = _texture_hover
	
	if hover_tween:
		hover_tween.kill()

	hover_tween = create_tween()
	hover_tween.set_trans(Tween.TRANS_CIRC)
	hover_tween.set_ease(Tween.EASE_OUT)

	hover_tween.parallel().tween_property(
		get_parent(),
		"scale",
		Vector2.ONE * hover_scale,
		tween_time
	)

	hover_tween.parallel().tween_property(
		self,
		"modulate",
		hover_modulate,
		tween_time
	)
	hover_tween.parallel().tween_property(
	get_parent(),
	"rotation",
	randf_range(-0.3, 0.3),
	tween_time
)





func set_normal(from_legend := false) -> void:
	if from_legend:
		texture_normal = _texture_normal
	
	if hover_tween:
		hover_tween.kill()

	hover_tween = create_tween()
	hover_tween.set_trans(Tween.TRANS_QUAD)
	hover_tween.set_ease(Tween.EASE_IN)

	hover_tween.parallel().tween_property(
		get_parent(),
		"scale",
		Vector2.ONE,
		tween_time
	)

	hover_tween.parallel().tween_property(
		self,
		"modulate",
		normal_modulate,
		tween_time
	)
	hover_tween.parallel().tween_property(
	get_parent(),
	"rotation",
	0.0,
	tween_time
)

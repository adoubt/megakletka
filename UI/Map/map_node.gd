extends Control
var day_id: int = -1
var texture: TextureButton 
@export var completed: bool = false:
	set(value):
		completed = value
		
		if completed: _complete() 
var completed_texture: TextureRect 
func _ready() -> void:
	texture= get_node_or_null("TextureButton")
	completed_texture= get_node_or_null("CompletedTexture")
@export var reachable: bool = false:
	set(value):
		reachable = value
		if reachable: _show_reachable()
var reachable_tween: Tween

func _on_texture_button_mouse_entered() -> void:
	if completed:
		return
	texture.set_hover()
	if texture.legend:
		find_parent("Map").hover_all_of_type(texture.day_type)
func _on_texture_button_mouse_exited() -> void:
	if completed:
		return
	texture.set_normal()
	if texture.legend:
		find_parent("Map").normal_all_of_type(texture.day_type)
	
func _complete() -> void:
	completed_texture.show()
	
func _show_reachable() -> void:
	_start_reachable_pulse()
	
func _start_reachable_pulse():
	pivot_offset = size / 2
	scale = Vector2.ONE
	if reachable_tween:
		reachable_tween.kill()
	reachable_tween = create_tween()
	reachable_tween.set_loops() # бесконечно
	reachable_tween.tween_interval(randf_range(0.0,0.3))
	reachable_tween.tween_property(
		self,
		"scale",
		Vector2(1.5, 1.5),
		0.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	reachable_tween.tween_property(
		self,
		"scale",
		Vector2.ONE,
		0.8
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_texture_button_pressed() -> void:
	if not reachable: return
	_sound()
	_complete()
	await get_tree().create_timer(1.0).timeout
	UIManager.event_bus.emit("day_selected", {"day_id": day_id})
	

func _sound()-> void:
	AudioManager.play_ui_sound("map_node_selected",5.0)

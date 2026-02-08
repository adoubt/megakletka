extends Control

@onready var texture: TextureButton = $TextureButton


func _on_texture_button_mouse_entered() -> void:

	texture.set_hover()
	if texture.legend:
		find_parent("Map").hover_all_of_type(texture.day_type)
func _on_texture_button_mouse_exited() -> void:
	
	texture.set_normal()
	if texture.legend:
		find_parent("Map").normal_all_of_type(texture.day_type)
	

extends SubViewport

func _ready() -> void:
	UIManager.wagon_panel.sub_view_texture.texture = get_texture()

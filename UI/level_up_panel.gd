extends Control

@onready var texture_rect: TextureRect = $TextureRect
var background_scene: Node = null

		
func setup_background(data: Array):
	if background_scene: background_scene.show_offer(data)

func _gui_input(event: InputEvent):
	
	if background_scene:
		background_scene._gui_input(event)

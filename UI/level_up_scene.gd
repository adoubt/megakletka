extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sub_viewport: SubViewport = $CameraPivot/SubViewport

func show_anim_board()-> void:
	animation_player.play("show_board")
	
func hide_anim_board() -> void:
	animation_player.play("hide_board")

func _ready() -> void:
	UIManager.level_up_panel.texture_rect.texture = sub_viewport.get_texture()
	UIManager.level_up_panel.scene = self
	

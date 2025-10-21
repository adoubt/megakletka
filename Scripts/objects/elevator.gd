extends StaticBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var doors_opened: bool = false


func open_doors():
	if doors_opened:
		return
	animation_player.play("open_doors")
	doors_opened = true


func close_doors():
	if not doors_opened:
		return
	animation_player.play("close_doors")
	doors_opened = false


func toggle_doors():
	if doors_opened:
		close_doors()
	else:
		open_doors()

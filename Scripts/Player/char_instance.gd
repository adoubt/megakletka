extends Node3D
#class_name Player

@onready var level_up_pop_up: Node3D = $LevelUpPopUp

@onready var camera: Camera3D = $Model/Camera3D

@onready var slots_root: Node3D = $SlotsRoot
#@export_group("Controller")
###if true this player will registred as 1st player
#@export var main_player : bool = false
#@export var input_enabled: bool = false
#
#@export_group("Multiplayer")
#@export var is_local_player := false

@onready var model: Node3D = $Model
#@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var death_anim: AnimationPlayer = $DeathAnim


func show_level_up():
	level_up_pop_up.show()
func hide_level_up():
	level_up_pop_up.hide()

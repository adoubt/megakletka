extends CharacterBody3D
class_name Player

@onready var level_up_pop_up: Node3D = $LevelUpPopUp

var current_state : String
@export var max_speed: float = 3.0
@export var acceleration: float = 125.0
@export var jump_velocity : float = 5.0
@export var gravity: float = -9.8
@export_group("Controller")
##if true this player will registred as 1st player
@export var main_player : bool = false
@export var input_enabled: bool = false

@export_group("Multiplayer")
@export var is_local_player := false

@onready var model: Node3D = $Model
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var camera_controller: Node3D = $CameraController
@onready var death_anim: AnimationPlayer = $DeathAnim

func _ready() -> void:
	ControllerManager.register(self)
	ControllerManager.activate_default(self)
func set_input_enabled(state: bool) -> void:
	input_enabled = state

func get_current_camera() -> Camera3D:
	return camera_controller.camera
	
func show_level_up():
	level_up_pop_up.show()
func hide_level_up():
	level_up_pop_up.hide()

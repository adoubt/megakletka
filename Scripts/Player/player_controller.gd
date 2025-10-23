extends CharacterBody3D
class_name Player

@export var max_speed: float = 3.0
@export var acceleration: float = 25.0
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

func _ready() -> void:
	ControllerManager.register(self)
	
func set_input_enabled(state: bool) -> void:
	input_enabled = state

func get_current_camera() -> Camera3D:
	return camera_controller.camera
	

# GameManager.gd
extends Node
class_name GameManager

var ecs :ECS

func _ready():
	print("Game started")
	ecs.new()

func _physics_process(delta: float) -> void:
	ecs.update(delta)

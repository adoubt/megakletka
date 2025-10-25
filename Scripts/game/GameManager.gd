# GameManager.gd
extends Node
class_name GameManager

var ecs: ECS

func _ready():
	print("Game started")
	
	# Создаём ECS при старте уровня
	ecs = ECS.new()
	add_child(ecs)  # если ECS Node, чтобы он был в сцене и мог вызывать _ready/_process при необходимости
	ecs.initialize()  # инициализация EntityManager, ComponentStore, SystemManager


func _process(delta: float) -> void:
	ecs.update(delta)

# GameManager.gd
extends Node
class_name GameManager

var ecs: ECS

func _ready():
	print("ECS started")

	# Создаём ECS при старте уровня
	ecs = ECS.new()
	add_child(ecs)  # если ECS Node, чтобы он был в сцене и мог вызывать _ready/_process при необходимости
	var run_seed = randi()
	ecs.initialize(run_seed)  # инициализация EntityManager, ComponentStore, SystemManager
	
	#ecs.event_bus.emit("run_started", {"seed": run_seed})
	
	
	
	
func _physics_process(delta: float) -> void:
	ecs.update(delta)

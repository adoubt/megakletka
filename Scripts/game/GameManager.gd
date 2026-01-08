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
	var run_seed = randi()
	ecs.event_bus.emit("run_started", { "seed": run_seed })
	ecs.event_bus.emit("create_char", { "char_name": "Rigman", "position": Vector3(-2.0,0,0)})
	ecs.event_bus.emit("create_poi",{ "poi_name": "wagon", "floor_id" :0, "position": Vector3.ZERO})
func _process(delta: float) -> void:
	ecs.update(delta)

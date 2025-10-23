extends Resource
class_name RenderComponent

## Path to the scene that represents this entity visually
var scene_path: String = "res://Scenes/Entity.tscn"

## Reference to instantiated scene (Node3D or Node2D)
var instance: Node = null

func _init(_scene_path : String = scene_path):
	scene_path = _scene_path

extends Resource
class_name RenderComponent

## Path to the scene that represents this entity visually
var scene_path: String = "res://Scenes/Entity.tscn"

## Reference to instantiated scene (Node3D or Node2D)
var instance: Node = null
var scale: Vector3 = Vector3(1.0, 1.0, 1.0)
func _init(_scene_path : String = scene_path, _scale:Vector3 = Vector3(1.0, 1.0, 1.0)):
	scene_path = _scene_path
	scale = _scale

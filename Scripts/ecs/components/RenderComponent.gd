extends Resource
class_name RenderComponent

## Path to the scene that represents this entity visually
var scene_path: String = "res://Scenes/Entity.tscn"

## Reference to instantiated scene (Node3D or Node2D)
var instance: Node = null
var scale: Vector3 = Vector3(1.0, 1.0, 1.0)
var shadow_instance: Node3D = null
var shadow: bool = false
var hit_flash_material: StandardMaterial3D
func _init(_scene_path : String = scene_path, _shadow : bool = false, _scale:Vector3 = Vector3(1.0, 1.0, 1.0)):
	scene_path = _scene_path
	shadow = _shadow
	scale = _scale
	

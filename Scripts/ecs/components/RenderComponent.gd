extends Resource
class_name RenderComponent

## Path to the scene that represents this entity visually
var scene_path: String = "res://Scenes/Entity.tscn"
var time_to_render : float = 0.3
## Reference to instantiated scene (Node3D or Node2D)
var instance: Node = null
var shadow_instance: Node3D = null
var shadow: bool = false
var hit_flash_material: StandardMaterial3D
func _init(_scene_path : String = scene_path, _shadow : bool = false):
	scene_path = _scene_path
	shadow = _shadow

	

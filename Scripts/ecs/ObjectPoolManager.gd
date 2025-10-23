extends RefCounted
class_name ObjectPool

var pool: Dictionary = {} # {scene_path: Array[Node3D]}
var root_node: Node3D

func _init(_root_node:Node):
	root_node = _root_node	

func get_from_pool(scene_path: String) -> Node3D:
	if not pool.has(scene_path):
		pool[scene_path] = []

	var arr = pool[scene_path]
	if arr.size() > 0:
		var node = arr.pop_back()
		node.visible = true
		return node

	# если пул пуст — создаём новый экземпляр
	var scene = load(scene_path)
	var instance = scene.instantiate()
	root_node.add_child(instance)
	return instance


func return_to_pool(scene_path: String, node: Node3D) -> void:
	if not pool.has(scene_path):
		pool[scene_path] = []

	node.visible = false
	node.set_physics_process(false)
	node.set_process(false)
	node.position = Vector3.ZERO
	pool[scene_path].append(node)

extends Node
class_name VFXSystem

# Здесь можно хранить префабы эффектов
@export var hit_effect_scene: PackedScene
@export var death_effect_scene: PackedScene

func spawn_hit_effect(pos: Vector3):
	if hit_effect_scene:
		var fx = hit_effect_scene.instantiate()
		fx.global_position = pos
		get_tree().current_scene.add_child(fx)

func spawn_death_effect(pos: Vector3):
	if death_effect_scene:
		var fx = death_effect_scene.instantiate()
		fx.global_position = pos
		get_tree().current_scene.add_child(fx)

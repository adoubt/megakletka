extends Resource
class_name WeaponData

@export var id: String = "-1"
@export var name: String = "No Name"
@export var icon: Texture2D = preload("uid://sto2c1qbfdg3")

@export var description: String ="No Desctiprion"
@export var base_stats: WeaponStatsComponent  

## Визуал (например, аура, меч, staff)
@export var packed_scene: PackedScene   

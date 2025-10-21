extends Resource
class_name EnemyData



@export var name: String
@export var can_fly: bool
@export var base_stats: StatsComponent
@export var packed_scene: PackedScene
@export var weapons: Array[WeaponData] = []

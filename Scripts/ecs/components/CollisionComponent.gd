extends Resource
class_name CollisionComponent

# Простая сфера для коллизий
var radius: float = 0.5
var collision_layer: int = 1
var collision_mask: int = 1

# Тип: "dynamic" - движущаяся сущность, "static" - неподвижная, "projectile" - снаряд
## "dynamic" — враги, игрок, которые двигаются
## "static" — мир, стены
## "projectile" — снаряды
var type: String = "dynamic"

func _init(_radius: float = 0.5, _collision_layer: int = 1, _collision_mask: int = 1, _type: String = "dynamic") -> void:
	radius = _radius
	collision_layer = _collision_layer
	collision_mask = _collision_mask
	type =  _type

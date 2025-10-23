extends Resource
class_name WeaponComponent

# Тип оружия
enum WeaponType { MELEE, RANGED, AURA, SPINNING }

var type: WeaponType = WeaponType.MELEE

# Общие поля
var cooldown: float = 1.0
var timer: float = 0.0
var damage: float = 10.0

# Для стрелкового оружия
var projectile_scene: String = ""

# Для ауры и вращения
var radius: float = 0.0
var speed: float = 0.0

func _init(_type: WeaponType = WeaponType.MELEE, _cooldown: float = 1.0, _damage: float = 10.0, _projectile_scene: String = "", _radius: float = 0.0, _speed: float = 0.0):
	type = _type
	cooldown = _cooldown
	damage = _damage
	projectile_scene = _projectile_scene
	radius = _radius
	speed = _speed

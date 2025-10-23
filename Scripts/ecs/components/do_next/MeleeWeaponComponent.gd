extends Resource
class_name MeleeWeaponComponent

@export var damage: float = 10.0
@export var range: float = 100.0
@export var cooldown: float = 0.5
@export var attack_angle: float = 120.0 # сектор удара
@export var time_since_attack: float = 0.0
@export var is_aura: bool = false       # если true — постоянный урон в радиусе

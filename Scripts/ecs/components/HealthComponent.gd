extends Resource
class_name HealthComponent

## Current and max HP
var current_hp: float 
var max_hp: float

## Natural regeneration rate (HP per second)
var regen_rate: float = 0.0

## Temporary overheal pool
var overheal: float = 0.0

func _init(_hp :float = 10.0):
	max_hp = _hp
	current_hp = _hp

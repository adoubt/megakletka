extends Resource
class_name ShieldComponent

## Shield capacity
var max_shield: float = 50.0
var current_shield: float = 50.0

## Regen properties
var regen_rate: float = 5.0
var regen_delay: float = 2.0
var time_since_hit: float = 0.0

extends Resource
class_name DamageOverTimeComponent

## Damage per second
var dps: float = 5.0

## Duration of effect
var duration: float = 3.0

## Source of effect
var source_id: int = -1

## Internal timer
var time_left: float = 3.0

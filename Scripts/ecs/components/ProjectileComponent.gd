extends Resource
class_name ProjectileComponent

## Velocity direction (normalized)
var direction: Vector3 = Vector3.ZERO

## Projectile current speed (from stats, but can change mid-flight)
var speed: float = 300.0

## Entity ID that fired this projectile
var owner_id: int = -1

## Time since spawn
var lifetime: float = 0.0

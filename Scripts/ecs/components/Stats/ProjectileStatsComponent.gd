extends Resource
class_name ProjectileStatsComponent

## How many projectiles this weapon fires at once
var projectile_count: int = 1

## Projectile base speed
var projectile_speed: float = 400.0

## How many times it can bounce
var projectile_bounces: int = 0

## Visual and collision scale multiplier
var size_mult: float = 1.0

## Knockback applied on hit
var knockback: float = 50.0

## Projectile lifetime (seconds)
var duration: float = 1.0

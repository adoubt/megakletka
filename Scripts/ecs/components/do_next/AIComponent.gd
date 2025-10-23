extends Resource
class_name AIComponent

## Current AI state (could be "idle", "chase", "attack", "flee", etc.)
var state: String = "idle"

## Time spent in the current state
var state_timer: float = 0.0

## Delay before switching to next state (for cooldowns, decision making)
var think_delay: float = 0.5

## Internal cooldown between AI decisions
var think_timer: float = 0.0

## Movement speed multiplier (can differ per state)
var speed_multiplier: float = 1.0

## Optional target position (for patrolling, chasing, fleeing)
var target_position: Vector3 = Vector3.ZERO

## Whether AI can currently make new decisions
var can_think: bool = true

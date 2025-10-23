extends Resource
class_name InputComponent

## Directional input vector from player (normalized)
var move_dir: Vector2 = Vector2.ZERO

## Whether attack button is pressed
var is_attacking: bool = false

## Whether dash or special action is pressed
var is_dashing: bool = false

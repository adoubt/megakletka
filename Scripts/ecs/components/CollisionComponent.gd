extends Resource
class_name CollisionComponent



var radius: float = 0.5
var collision_layer: int
var collision_mask: int

func _init(layer: int, mask: int, _radius: float = 0.5):
	collision_layer = layer
	collision_mask = mask
	radius = _radius

# Удобные проверки:
func is_player() -> bool: 
	return (collision_layer & CollisionLayers.Layer.PLAYER) != 0

func is_enemy() -> bool: 
	return (collision_layer & CollisionLayers.Layer.ENEMY) != 0

func is_player_projectile() -> bool: 
	return (collision_layer & CollisionLayers.Layer.PLAYER_PROJECTILE) != 0

func is_enemy_projectile() -> bool: 
	return (collision_layer & CollisionLayers.Layer.ENEMY_PROJECTILE) != 0

func is_projectile() -> bool: 
	return is_player_projectile() or is_enemy_projectile()

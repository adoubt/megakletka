extends Resource
class_name CollisionLayers

enum Layer {
	WORLD = 1 << 0,
	PLAYER = 1 << 1,
	ENEMY = 1 << 2,
	PLAYER_PROJECTILE = 1 << 3,
	ENEMY_PROJECTILE = 1 << 4,
}

extends Node
class_name SpawnSystem

@export var spawn_radius: float = 30.0        # Радиус появления
@export var spawn_interval: float = 5.0       # Каждые 5 секунд
@export var spawn_batch_size: int = 10        # По 10 за раз
@export var max_height := 5.0
@export var min_spawn_distance: float = 10.0

var _timer: float = 0.0               # Внутренний таймер
@export var enemy_probabilities := {
	"aboba": 0.3,   # 80%
	"fuflan": 0.7   # 20%
}
func _pick_enemy_type() -> String:
	var roll = randf()
	var cumulative := 0.0
	for enemy_type in enemy_probabilities.keys():
		cumulative += enemy_probabilities[enemy_type]
		if roll <= cumulative:
			return enemy_type
	return enemy_probabilities.keys()[0]

func update(delta: float, manager: EnemyManager, player_entity: Entity):
	_timer -= delta
	if _timer <= 0:
		_timer = spawn_interval

		for i in range(spawn_batch_size):
			var pos = _get_valid_spawn_position(player_entity.position)
			manager.spawn_enemy(_pick_enemy_type(), pos)
			
			
func _get_valid_spawn_position(center: Vector3) -> Vector3:
	var pos: Vector3
	var dist: float

	while true:
		var angle = randf() * TAU
		var radius = randf_range(min_spawn_distance, spawn_radius)
		var x = cos(angle) * radius
		var z = sin(angle) * radius
		var y = randf() * max_height
		pos = center + Vector3(x, y, z)

		dist = center.distance_to(pos)
		if dist >= min_spawn_distance:
			break
	
	return pos

extends Resource
class_name SpawnComponent

## ID спавнера, из которого появилась сущность
var spawner_id: int = -1

## Задержка перед появлением (для анимации)
var spawn_delay: float = 0.0

## Флаг что существо уже активировано
var active: bool = false

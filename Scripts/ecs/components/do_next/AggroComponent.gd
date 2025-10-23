extends Resource
class_name AggroComponent

## Радиус в котором враг "видит" игрока
var detection_radius: float = 600.0

## Кого враг преследует (entity id)
var target_id: int = -1

## Таймер потери цели
var lose_target_time: float = 2.0
var time_since_seen: float = 0.0
